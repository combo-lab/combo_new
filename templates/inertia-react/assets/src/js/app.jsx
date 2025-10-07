import "vite/modulepreload-polyfill"
import "@fontsource-variable/instrument-sans"
import "../css/app.css"

import { createInertiaApp } from "@inertiajs/react";
import { createRoot, hydrateRoot } from "react-dom/client";
import { resolvePageComponent } from "./inertia-helper";

import axios from "axios";
axios.defaults.xsrfHeaderName = "x-csrf-token";

function ssr_mode() {
  return document.documentElement.hasAttribute("ssr");
}

createInertiaApp({
  title: title => title ? `${title} - MyApp` : 'MyApp',
  resolve: (name) => resolvePageComponent(
    `./pages/${name}.jsx`, 
    import.meta.glob('./pages/**/*.jsx', { eager: true })
  ),
  setup({ el, App, props }) {
    if (ssr_mode()) {
      hydrateRoot(el, <App {...props} />);
    } else {
      createRoot(el).render(<App {...props} />)    
    }
  },
});
