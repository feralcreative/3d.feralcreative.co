import { defineConfig } from "vite";
import { ModelManagement, modelManagementMiddleware, localModelAdmin } from "./utils/model-management.js";
import { copyFileSync, createReadStream, mkdirSync, readFileSync, writeFileSync } from "fs";
import { extname, resolve, sep } from "path";
import { readdir, realpath, stat } from "fs/promises";

// cad/utils/library.py writes catalog.json and symlinks to the selected meshes
// here; production publishes the same flat set to the NAS models mount.
const SITE_MODELS_DIR = resolve(process.env.SITE_MODELS_DIR || "cad/_work/site-models");
const MODEL_TYPES = {
  ".stl": "model/stl",
  ".glb": "model/gltf-binary",
  ".gltf": "model/gltf+json",
  ".3mf": "model/3mf",
  ".obj": "model/obj",
  ".json": "application/json",
};

// Model directories in lookup order: generated staging first, then the
// hand-placed public/models (or its copy in dist/ for preview).
function modelDirectories(publicDir) {
  return [SITE_MODELS_DIR, resolve(publicDir, "models")];
}

function isInside(path, root) {
  return path === root || path.startsWith(root + sep);
}

// A staged symlink may point into cad/library, but never outside the repository
// or the staging directory itself.
async function findModelFile(publicDir, name) {
  const allowed = await Promise.all([resolve("."), SITE_MODELS_DIR].map((root) => realpath(root).catch(() => root)));
  for (const directory of modelDirectories(publicDir)) {
    try {
      const path = await realpath(resolve(directory, name));
      if (!allowed.some((root) => isInside(path, root))) continue;
      const info = await stat(path);
      if (info.isFile()) return { path, info };
    } catch {
      // Missing here; try the next directory.
    }
  }
  return null;
}

async function listModelDirectory(directory) {
  let names;
  try {
    names = await readdir(directory);
  } catch {
    return null;
  }
  const entries = await Promise.all(names.filter((name) => !name.startsWith(".")).map(async (name) => {
    try {
      const info = await stat(resolve(directory, name));
      return { name, type: info.isFile() ? "file" : "directory", size: info.size };
    } catch {
      return null; // An unavailable symlink is not a usable model.
    }
  }));
  return entries.filter(Boolean);
}

function notFound(res) {
  res.writeHead(404, { "Content-Type": "text/plain", "Cache-Control": "no-store" }).end("Not found");
}

// Match the runtime Nginx model routes without starting the printer proxy.
function modelCatalogMiddleware(server) {
  const management = new ModelManagement({ catalogPath: resolve(SITE_MODELS_DIR, "catalog.json"), statePath: resolve("data/model-organization.json"), extraDirectories: [resolve(server.config.publicDir, "models")] });
  server.middlewares.use(modelManagementMiddleware(management, localModelAdmin));
  server.middlewares.use(async (req, res, next) => {
    const path = req.url.split("?")[0];
    // /models would otherwise resolve to models.js in Vite's extension lookup.
    if (/^\/models\/?$/.test(path)) {
      req.url = req.url.replace(/^\/models\/?/, "/index.html");
      return next();
    }
    // The CAD tree sits inside Vite's root but is not part of the site.
    if (path === "/data" || path.startsWith("/data/")) return notFound(res);
    if (path === "/cad" || path.startsWith("/cad/")) return notFound(res);

    if (path.startsWith("/models/")) {
      if (req.method !== "GET" && req.method !== "HEAD") {
        res.writeHead(405, { Allow: "GET, HEAD" }).end();
        return;
      }
      let name;
      try {
        name = decodeURIComponent(path.slice("/models/".length));
      } catch {
        return notFound(res);
      }
      // Flat directory: one basename, no traversal, no dotfiles.
      if (!name || name.startsWith(".") || /[\/\\\0]/.test(name)) return notFound(res);
      if (name === "catalog.json") {
        try {
          const catalog = localModelAdmin(req)?.admin ? (await management.read()).catalog : await management.publicCatalog();
          res.writeHead(200, { "Content-Type": "application/json", "Cache-Control": "no-store" });
          return res.end(req.method === "HEAD" ? undefined : JSON.stringify(catalog));
        } catch { return notFound(res); }
      }
      try {
        if (!localModelAdmin(req)?.admin && !await management.fileVisible(name)) return notFound(res);
      } catch { return notFound(res); }
      const file = await findModelFile(server.config.publicDir, name);
      if (!file) return notFound(res);
      res.writeHead(200, {
        "Content-Type": MODEL_TYPES[extname(name).toLowerCase()] || "application/octet-stream",
        "Content-Length": file.info.size,
        "Cache-Control": name === "catalog.json" ? "no-store" : "no-cache",
      });
      if (req.method === "HEAD") return res.end();
      createReadStream(file.path).on("error", () => res.destroy()).pipe(res);
      return;
    }

    if (path !== "/model-catalog/") return next();
    if (req.method !== "GET" && req.method !== "HEAD") {
      res.writeHead(405, { Allow: "GET, HEAD" }).end();
      return;
    }
    // Production lists the one models mount; here the staging and public
    // directories together stand in for it, staging winning on a name clash.
    const listings = await Promise.all(modelDirectories(server.config.publicDir).map(listModelDirectory));
    if (listings.every((listing) => listing === null)) {
      res.writeHead(503, { "Content-Type": "application/json", "Cache-Control": "no-store" });
      res.end(JSON.stringify({ error: "Model directory unavailable" }));
      return;
    }
    const entries = new Map();
    for (const listing of listings) {
      for (const entry of listing || []) if (!entries.has(entry.name)) entries.set(entry.name, entry);
    }
    const visible = [];
    try {
      const { catalog } = await management.read();
      for (const entry of entries.values()) if (await management.fileVisible(entry.name, catalog)) visible.push(entry);
    } catch { return notFound(res); }
    res.writeHead(200, { "Content-Type": "application/json", "Cache-Control": "no-store" });
    res.end(req.method === "HEAD" ? undefined : JSON.stringify(visible));
  });
}

export default defineConfig({
  root: ".",
  server: {
    fs: { deny: [".env", ".env.*", "*.{crt,pem}", "**/.git/**", "**/cad/**", "**/data/**"] },
    port: 5501,
    open: true,
    watch: {
      // The ./3d symlink points into Dropbox (which has self-referential
      // symlinks); excluding it prevents chokidar ELOOP crashes on startup.
      // cad/ holds the model library and its generated work, none of it site source.
      ignored: ["**/3d/**", "**/cad/**", "**/data/**"],
    },
  },
  optimizeDeps: {
    // Without this, dependency scanning crawls every HTML file under the root,
    // including the ones archived in cad/.
    entries: ["index.html"],
  },
  build: {
    outDir: "dist",
    assetsDir: "assets",
    rollupOptions: {
      input: {
        main: "./index.html",
      },
    },
  },
  plugins: [
    {
      name: "model-catalog",
      configureServer: modelCatalogMiddleware,
      configurePreviewServer(server) {
        // Preview reads the built assets, just as Nginx does.
        modelCatalogMiddleware({ ...server, config: { publicDir: resolve("dist") } });
      },
    },
    {
      name: "copy-js-files",
      closeBundle() {
        // Copy JavaScript files that are loaded via script tags
        const filesToCopy = ["config.js", "logger.js", "printer.js", "stream.js", "auth.js"];
        filesToCopy.forEach((file) => {
          try {
            copyFileSync(resolve(file), resolve("dist", file));
            console.log(`Copied ${file} to dist/`);
          } catch (err) {
            console.error(`Failed to copy ${file}:`, err);
          }
        });

        // Copy PWA manifest to root of dist
        try {
          copyFileSync(resolve("site.webmanifest"), resolve("dist", "site.webmanifest"));
          console.log("Copied site.webmanifest to dist/");
        } catch (err) {
          console.error("Failed to copy site.webmanifest:", err);
        }

        // Inject PWA manifest links into dist/index.html
        try {
          const indexPath = resolve("dist", "index.html");
          let html = readFileSync(indexPath, "utf-8");

          // PWA manifest links to inject
          const pwaLinks = `    <!-- PWA Manifest -->
    <link rel="manifest" href="/site.webmanifest">
    <link rel="apple-touch-icon" sizes="192x192" href="/images/web-app-manifest-192x192.png">
    <link rel="apple-touch-icon" sizes="512x512" href="/images/web-app-manifest-512x512.png">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="apple-mobile-web-app-title" content="Feral 3D">
`;

          // Inject before </head>
          html = html.replace("</head>", pwaLinks + "\n</head>");

          writeFileSync(indexPath, html);
          console.log("Injected PWA manifest links into dist/index.html");
        } catch (err) {
          console.error("Failed to inject PWA links:", err);
        }
      },
    },
  ],
});
