export default defineEventHandler((event) => {
  if (getRequestURL(event).pathname.startsWith('/share/')) {
    setResponseHeader(event, 'X-Robots-Tag', 'noindex, nofollow')
  }
})
