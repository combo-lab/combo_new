import "@fontsource-variable/instrument-sans"
import "../css/app.css"

import axios from "axios";
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";

axios.defaults.xsrfHeaderName = "x-csrf-token";

createInertiaApp({
  resolve: (name) => resolvePageComponent(
    `./Pages/${name}.jsx`, 
    import.meta.glob('./Pages/**/*.jsx', { eager: true })
  ),
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
});

async function resolvePageComponent(name, pages, options) {
  if (typeof pages[name] === 'undefined' && options?.fallbackName) {
    name = options.fallbackName
  }
  
  const page = pages[name]
  
  if (typeof page !== 'undefined') {
    return typeof page === 'function' ? page() : page
  } else {
    throw new Error(`Page not found: ${name}`)
  }
}
