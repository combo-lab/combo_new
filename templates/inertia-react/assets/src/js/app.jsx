import "vite/modulepreload-polyfill"

import "@fontsource-variable/instrument-sans"
import "../css/app.css"

import { createInertiaApp } from "@inertiajs/react"
import { createRoot, hydrateRoot } from "react-dom/client"

import axios from "axios"
axios.defaults.xsrfHeaderName = "x-csrf-token"

const appName = "MyApp"

function ssr_mode() {
  return document.documentElement.hasAttribute("data-ssr")
}

createInertiaApp({
  title: (title) => (title ? `${title} - ${appName}` : appName),
  resolve: (name) => {
    const page = `./pages/${name}.jsx`
    const pages = import.meta.glob("./pages/**/*.jsx", { eager: true })
    return pages[page]
  },
  setup({ el, App, props }) {
    if (ssr_mode()) {
      hydrateRoot(el, <App {...props} />)
    } else {
      createRoot(el).render(<App {...props} />)
    }
  },
})
