function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // If the request is being made to a directory (e.g. / or /docs), we want to
  // append "index.html" so that S3 serves the proper object. If the path
  // doesn't contain a file extension, we assume it's a directory as well.
  if (uri.endsWith('/')) {
    request.uri += 'index.html';
  }
  else if (!uri.includes('.')) {
    request.uri += '/index.html'
  }

  return request;
}
