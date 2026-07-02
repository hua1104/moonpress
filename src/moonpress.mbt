pub fn version() -> String {
  "0.1.0"
}

pub fn render_document(path : String, source : String) -> RenderedPage {
  let body = strip_front_matter(source)
  let title = read_title(source)
  {
    route: normalize_route(path),
    title: if title == "" { "Untitled" } else { title },
    html: render_page(if title == "" { "Untitled" } else { title }, body),
  }
}

