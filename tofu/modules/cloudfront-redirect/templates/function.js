function handler(event) {
  const DESTINATION = "${destination}";
  const STATIC = ${static};
  const STATUS_CODE = ${status_code};

  const request = event.request;

  return {
    statusCode: STATUS_CODE,
    statusDescription: 'Moved Permanently',
    headers: {
      "location": { "value": DESTINATION + (STATIC ? '' : request.uri) }
    }
  };
}
