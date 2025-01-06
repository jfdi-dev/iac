function handler(event) {
  const { request } = event
  if (!request.uri.includes('.')) {
    request.uri = '/index.html'
  }
  return request
}