import { createInertiaApp } from "@inertiajs/react"
import ReactDOMServer from "react-dom/server"
import { resolvePageComponent } from "./inertia-helper"

export function render(page) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    title: (title) => (title ? `${title} - MyApp` : "MyApp"),
    resolve: (name) =>
      resolvePageComponent(
        `./pages/${name}.jsx`,
        import.meta.glob("./pages/**/*.jsx", { eager: true }),
      ),
    setup: ({ App, props }) => <App {...props} />,
  })
}
