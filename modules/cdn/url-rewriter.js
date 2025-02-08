function handler(event) {
  var request = event.request
  var mountedPaths= ['login', 'logout', 'callback']
  if (!request.uri.includes('.') && !mountedPaths.some(path => request.uri.includes(path))) {
    request.uri = '/index.html'
  }
  return request
}