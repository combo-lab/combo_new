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
