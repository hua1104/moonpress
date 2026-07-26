///|
/// Collects every link target written in a Markdown document: inline links,
/// images, and reference definitions. Fenced code blocks are skipped. Targets
/// are returned verbatim so callers decide what counts as internal.
pub fn collect_link_targets(markdown : String) -> Array[String] {
  let targets : Array[String] = []
  let mut fenced = false
  for line in lines_of(markdown) {
    let text = line.trim().to_owned()
    if text.has_prefix("```") {
      fenced = !fenced
      continue
    }
    if fenced {
      continue
    }
    if text.has_prefix("[") && !text.has_prefix("[^") {
      match text.find("]:") {
        Some(at) =>
          if at >= 1 {
            let value = text[at + 2:].trim().to_owned()
            if value != "" {
              targets.push(first_token(value))
              continue
            }
          }
        None => ()
      }
    }
    let chars = chars_of(text)
    let end = chars.length()
    let mut in_code = false
    let mut i = 0
    while i < end {
      if chars[i] == '`' {
        in_code = !in_code
        i = i + 1
        continue
      }
      if !in_code && i + 1 < end && chars[i] == ']' && chars[i + 1] == '(' {
        let close = find_char(chars, i + 2, end, ')')
        if close > 0 {
          targets.push(chars_to_string(chars, i + 2, close).trim().to_owned())
          i = close + 1
          continue
        }
      }
      i = i + 1
    }
  }
  targets
}

///|
/// Validates the internal links of every non-draft page and returns one
/// human-readable message per broken link. Two shapes of links are checked:
/// `.md` targets, which must resolve to an existing non-draft source file, and
/// absolute extensionless paths, which must match a generated route (with or
/// without the configured base URL and a trailing slash). External links,
/// bare anchors, and asset paths with file extensions are left alone.
pub fn check_internal_links(
  sources : Array[PageSource],
  base_url : String,
) -> Array[String] {
  let valid_md : Array[String] = []
  let valid_routes : Array[String] = []
  for source in sources {
    let page = plan_page(source.path, source.source)
    if page.draft {
      continue
    }
    valid_md.push(normalize_path_key(source.path))
    valid_routes.push(localized_route_key(page.lang, page.route))
  }
  let issues : Array[String] = []
  for source in sources {
    let page = plan_page(source.path, source.source)
    if page.draft {
      continue
    }
    for target in collect_link_targets(strip_front_matter(source.source)) {
      let bare = strip_fragment(target)
      if bare == "" || is_external_link(bare) {
        continue
      }
      if bare.has_suffix(".md") {
        let resolved = if bare.has_prefix("/") {
          normalize_path_key(bare[1:].to_owned())
        } else {
          resolve_relative_path(source_dir(source.path), bare)
        }
        if !contains_string(valid_md, resolved) {
          issues.push(source.path + ": broken link " + target)
        }
      } else if bare.has_prefix("/") && !has_file_extension(bare) {
        let route = route_key(strip_base_url_prefix(bare, base_url))
        if !contains_string(valid_routes, route) {
          issues.push(source.path + ": broken link " + target)
        }
      }
    }
  }
  issues
}

///|
fn is_external_link(target : String) -> Bool {
  target.has_prefix("http://") ||
  target.has_prefix("https://") ||
  target.has_prefix("mailto:") ||
  target.has_prefix("//")
}

///|
/// Drops a `#fragment` or `?query` suffix so only the path is validated.
fn strip_fragment(target : String) -> String {
  let mut path = target
  match path.find("#") {
    Some(at) => path = path[:at].to_owned()
    None => ()
  }
  match path.find("?") {
    Some(at) => path = path[:at].to_owned()
    None => ()
  }
  path.trim().to_owned()
}

///|
fn source_dir(path : String) -> String {
  let normalized = path.replace_all(old="\\", new="/")
  let mut dir = ""
  let mut consumed = ""
  for part in normalized.split("/") {
    let text = part.to_owned()
    if consumed != "" {
      dir = consumed
    }
    consumed = if consumed == "" { text } else { consumed + "/" + text }
  }
  dir
}

///|
/// Resolves `./` and `../` segments of a relative link against the directory
/// of the document that contains it.
fn resolve_relative_path(from_dir : String, target : String) -> String {
  let combined = if from_dir == "" { target } else { from_dir + "/" + target }
  let segments : Array[String] = []
  for part in combined.replace_all(old="\\", new="/").split("/") {
    let text = part.to_owned()
    if text == "" || text == "." {
      continue
    }
    if text == ".." {
      if segments.length() > 0 {
        segments.pop() |> ignore
      }
      continue
    }
    segments.push(text)
  }
  segments.join("/")
}

///|
fn normalize_path_key(path : String) -> String {
  resolve_relative_path("", path)
}

///|
fn has_file_extension(path : String) -> Bool {
  let mut last = ""
  for part in path.split("/") {
    let text = part.to_owned()
    if text != "" {
      last = text
    }
  }
  last.find(".") is Some(_)
}

///|
fn strip_base_url_prefix(path : String, base_url : String) -> String {
  if base_url != "" && base_url != "/" && path.has_prefix(base_url) {
    let rest = path[base_url.length():].to_owned()
    if rest.has_prefix("/") {
      rest
    } else {
      "/" + rest
    }
  } else {
    path
  }
}

///|
/// Canonical comparison form of a route: leading slash, no trailing slash
/// except for the root route itself.
fn route_key(path : String) -> String {
  let mut route = if path.has_prefix("/") { path } else { "/" + path }
  while route.length() > 1 && route.has_suffix("/") {
    route = route[:route.length() - 1].to_owned()
  }
  route
}

///|
fn localized_route_key(lang : String, route : String) -> String {
  if lang == "en" {
    route_key(route)
  } else if route == "/" {
    route_key("/" + lang)
  } else {
    route_key("/" + lang + route)
  }
}

///|
fn contains_string(values : Array[String], needle : String) -> Bool {
  for value in values {
    if value == needle {
      return true
    }
  }
  false
}
