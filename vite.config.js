import { defineConfig } from "vite";
import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import { resolve } from "path";

export default defineConfig({
  root: ".",
  server: {
    port: 5501,
    open: true,
    watch: {
      // The ./3d symlink points into Dropbox (which has self-referential
      // symlinks); excluding it prevents chokidar ELOOP crashes on startup.
      ignored: ["**/3d/**"],
    },
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
      name: "copy-js-files",
      closeBundle() {
        // Copy JavaScript files that are loaded via script tags
        const filesToCopy = ["config.js", "logger.js", "notifications.js", "printer.js", "auth.js"];
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
