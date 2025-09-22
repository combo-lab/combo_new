import "@fontsource-variable/instrument-sans"
import "../css/app.css"

import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";
import { resolvePageComponent } from "./inertia-helper";

import axios from "axios";
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
