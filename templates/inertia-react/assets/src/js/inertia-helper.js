// An Inertia helper for resolving page component.
//
// # Usage
//
// ## Resolve page component
// 
//     resolvePageComponent(
//       `./Pages/${name}.jsx`,
//       import.meta.glob('./Pages/**/*.jsx', { eager: true })
//     )
//
// ## Resolve page component with a fallback name
// 
//     resolvePageComponent(
//       `./Pages/${name}.jsx`,
//       import.meta.glob('./Pages/**/*.jsx', { eager: true }),
//       {
//         fallbackName: `./Pages/404.jsx`
//       }
//     )
//
export async function resolvePageComponent(name, pages, options) {
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
