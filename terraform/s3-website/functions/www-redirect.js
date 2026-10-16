// Permanently redirect www.petersouter.xyz to the apex domain, keeping the
// path and query string. Templated by Terraform: ${canonical_host}
function handler(event) {
  var request = event.request;
  var host = request.headers.host ? request.headers.host.value : "";

  if (host === "${canonical_host}") {
    return request;
  }

  var query = [];
  for (var key in request.querystring) {
    var param = request.querystring[key];
    var values = param.multiValue ? param.multiValue : [param];
    for (var i = 0; i < values.length; i++) {
      query.push(values[i].value === "" ? key : key + "=" + values[i].value);
    }
  }

  var location = "https://${canonical_host}" + request.uri;
  if (query.length > 0) {
    location += "?" + query.join("&");
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
