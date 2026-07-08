///|
pub fn normalize_route(path : String) -> String {
  let mut route = path.replace_all(old="\\", new="/")
  if route.has_suffix(".md") {
    route = route[:route.length() - 3].to_owned()
  }
  if route == "index" {
    route = ""
  } else if route.has_suffix("/index") {
    route = route[:route.length() - 6].to_owned()
  }
  if route == "" {
    "/"
  } else if route.has_prefix("/") {
    route
  } else {
    "/" + route
  }
}

///|
pub fn route_to_output_path(route : String) -> String {
  if route == "/" {
    "index.html"
  } else {
    route[1:].to_owned() + "/index.html"
  }
}
