// Permanently redirect www.petersouter.xyz to the apex domain, keeping the
// path and query string. Templated by Terraform: ${canonical_host}
function handler(event) {
  var request = event.request;
  var host = request.headers.host ? request.headers.host.value : "";

  if (host === "${canonical_host}") {
    return request;
  }

  // rawQueryString() keeps the query exactly as received (order, encoding,
  // and empty values), so the redirect doesn't alter it
  var query = request.rawQueryString();
  var location = "https://${canonical_host}" + request.uri;
  if (query) {
    location += "?" + query;
  }

  return {
    statusCode: 301,
    statusDescription: "Moved Permanently",
    headers: {
      location: { value: location },
      "cache-control": { value: "max-age=3600" },
    },
  };
}
