import { defineConfig } from "vite"
import combo from "vite-plugin-combo"
import tailwindcss from "@tailwindcss/vite"

export default defineConfig({
  plugins: [
    combo({
      input: ["css/app.css", "js/app.js"],
      staticDir: "../../priv/admin_web/static",
    }),
    tailwindcss(),
  ],
})
