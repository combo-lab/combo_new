import { defineConfig } from "vite"
import combo from "vite-plugin-combo"
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [
    combo({
      input: ["src/js/app.jsx"],
      staticDir: "../priv/static",
    }),
    react(),
  ],
})
