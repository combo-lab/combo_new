import { createInertiaApp } from "@inertiajs/react"
import ReactDOMServer from "react-dom/server"

export function render(page) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    title: (title) => (title ? `${title} - MyApp` : "MyApp"),
    resolve: (name) => {
      const page = `./pages/${name}.jsx`
      const pages = import.meta.glob("./pages/**/*.jsx", { eager: true })
      return pages[page]
    },
    setup: ({ App, props }) => <App {...props} />,
  })
}
