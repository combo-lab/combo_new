// An Inertia helper for resolving page component.
//
// # Usage
//
// ## Resolve page component
//
//     resolvePageComponent(
//       `./pages/${name}.jsx`,
//       import.meta.glob('./pages/**/*.jsx', { eager: true })
//     )
//
// ## Resolve page component with a fallback name
//
//     resolvePageComponent(
//       `./pages/${name}.jsx`,
//       import.meta.glob('./pages/**/*.jsx', { eager: true }),
//       {
//         fallbackName: `./pages/404.jsx`
//       }
//     )
//
export async function resolvePageComponent(name, pages, options) {
  if (typeof pages[name] === "undefined" && options?.fallbackName) {
    name = options.fallbackName
  }

  const page = pages[name]

  if (typeof page !== "undefined") {
    return typeof page === "function" ? page() : page
  } else {
    throw new Error(`Page not found: ${name}`)
  }
}
