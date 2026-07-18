///|
pub(all) struct NavItem {
  title : String
  route : String
  depth : Int
}

///|
pub fn navigation_from_pages(pages : Array[PagePlan]) -> Array[NavItem] {
  let items : Array[NavItem] = []
  for page in pages {
    items.push({
      title: page.title,
      route: page.route,
      depth: route_depth(page.route),
    })
  }
  items
}

///|
pub fn route_depth(route : String) -> Int {
  if route == "/" {
    0
  } else {
    let parts = route.split("/")
    let mut depth = 0
    for part in parts {
      if part.trim() != "" {
        depth = depth + 1
      }
    }
    depth - 1
  }
}

///|
pub fn render_sidebar(items : Array[NavItem]) -> String {
  render_sidebar_for_lang(items, "en")
}

///|
pub fn render_sidebar_for_lang(items : Array[NavItem], lang : String) -> String {
  render_sidebar_with_base_url(items, lang, "/")
}

///|
pub fn render_sidebar_with_base_url(
  items : Array[NavItem],
  lang : String,
  base_url : String,
) -> String {
  let mut html = "<nav class=\"mp-sidebar\">\n"
  for item in items {
    html = html +
      "  <a class=\"mp-nav-item depth-" +
      item.depth.to_string() +
      "\" href=\"" +
      escape_html(localized_href_with_base_url(base_url, lang, item.route)) +
      "\">" +
      escape_html(item.title) +
      "</a>\n"
  }
  html + "</nav>\n"
}

///|
pub fn render_language_switcher(
  current_lang : String,
  route : String,
) -> String {
  render_language_switcher_with_base_url(current_lang, route, "/")
}

///|
pub fn render_language_switcher_with_base_url(
  current_lang : String,
  route : String,
  base_url : String,
) -> String {
  let en_href = localized_href_with_base_url(base_url, "en", route)
  let zh_href = localized_href_with_base_url(base_url, "zh", route)
  let en_class = if current_lang == "en" { " active" } else { "" }
  let zh_class = if current_lang == "zh" { " active" } else { "" }
  "<div class=\"mp-lang-switch\">" +
  "<a class=\"mp-lang" +
  en_class +
  "\" href=\"" +
  escape_html(en_href) +
  "\">English</a>" +
  "<a class=\"mp-lang" +
  zh_class +
  "\" href=\"" +
  escape_html(zh_href) +
  "\">中文</a>" +
  "</div>\n"
}

///|
pub fn localized_href(lang : String, route : String) -> String {
  localized_href_with_base_url("/", lang, route)
}

///|
pub fn localized_href_with_base_url(
  base_url : String,
  lang : String,
  route : String,
) -> String {
  let localized_route = if lang == "en" {
    route
  } else if route == "/" {
    "/" + lang + "/"
  } else {
    "/" + lang + route
  }
  with_base_url(base_url, localized_route)
}
