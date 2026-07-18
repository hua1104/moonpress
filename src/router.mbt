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

///|
pub fn normalize_base_url(base_url : String) -> String {
  if base_url == "" || base_url == "/" {
    ""
  } else {
    let trimmed = if base_url.has_suffix("/") {
      base_url[:base_url.length() - 1].to_owned()
    } else {
      base_url
    }
    if trimmed.has_prefix("/") ||
      trimmed.has_prefix("http://") ||
      trimmed.has_prefix("https://") {
      trimmed
    } else {
      "/" + trimmed
    }
  }
}

///|
pub fn with_base_url(base_url : String, path : String) -> String {
  let base = normalize_base_url(base_url)
  let normalized_path = if path == "" || path == "/" {
    "/"
  } else if path.has_prefix("/") {
    path
  } else {
    "/" + path
  }
  if base == "" {
    normalized_path
  } else if normalized_path == "/" {
    base + "/"
  } else {
    base + normalized_path
  }
}
