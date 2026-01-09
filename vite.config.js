import { defineConfig } from "vite";
import { copyFileSync, mkdirSync } from "fs";
import { resolve } from "path";

export default defineConfig({
  root: ".",
  server: {
    port: 5501,
    open: true,
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
        const filesToCopy = ["config.js", "logger.js", "printer.js", "auth.js"];
        filesToCopy.forEach((file) => {
          try {
            copyFileSync(resolve(file), resolve("dist", file));
            console.log(`Copied ${file} to dist/`);
          } catch (err) {
            console.error(`Failed to copy ${file}:`, err);
          }
        });
      },
    },
  ],
});
