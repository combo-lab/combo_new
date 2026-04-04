import { defineConfig } from "vite"
import combo from "vite-plugin-combo"

export default defineConfig({
  plugins: [
    combo({
      input: ["src/css/app.css", "src/js/app.js"],
      assets: ["src/images/**"],
      staticDir: "../priv/static",
    }),
  ],
})
