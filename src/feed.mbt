///|
/// Builds an RSS 2.0 feed for one language. Links are absolute when `site_url`
/// is configured and fall back to base-url relative paths otherwise, so the
/// feed is still usable for local previews.
pub fn build_feed_for_lang(
  config : SiteConfig,
  pages : Array[PagePlan],
  lang : String,
) -> String {
  let home = feed_link(config, lang, "/")
  let out = StringBuilder::new()
  out.write_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  out.write_string(
    "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\n",
  )
  out.write_string("<channel>\n")
  out.write_string("  <title>" + escape_xml(config.title) + "</title>\n")
  out.write_string("  <link>" + escape_xml(home) + "</link>\n")
  out.write_string(
    "  <description>" + escape_xml(config.description) + "</description>\n",
  )
  out.write_string("  <language>" + escape_xml(lang) + "</language>\n")
  out.write_string(
    "  <generator>MoonPress " + escape_xml(version()) + "</generator>\n",
  )
  out.write_string(
    "  <atom:link href=\"" +
    escape_xml(feed_link(config, lang, "/feed.xml")) +
    "\" rel=\"self\" type=\"application/rss+xml\"/>\n",
  )
  for page in pages {
    let link = feed_link(config, lang, page.route)
    out.write_string("  <item>\n")
    out.write_string("    <title>" + escape_xml(page.title) + "</title>\n")
    out.write_string("    <link>" + escape_xml(link) + "</link>\n")
    out.write_string(
      "    <guid isPermaLink=\"false\">" + escape_xml(link) + "</guid>\n",
    )
    if page.description != "" {
      out.write_string(
        "    <description>" + escape_xml(page.description) + "</description>\n",
      )
    }
    out.write_string("  </item>\n")
  }
  out.write_string("</channel>\n</rss>\n")
  out.to_string()
}

///|
fn feed_link(config : SiteConfig, lang : String, route : String) -> String {
  let absolute = canonical_url(config, lang, route)
  if absolute == "" {
    localized_href_with_base_url(config.base_url, lang, route)
  } else {
    absolute
  }
}

///|
/// Builds the body of the generated 404 page.
pub fn not_found_body(config : SiteConfig, lang : String) -> String {
  let heading = if lang == "zh" { "页面不存在" } else { "Page not found" }
  let message = if lang == "zh" {
    "请求的页面已被移动或从未存在。"
  } else {
    "The page you requested was moved or never existed."
  }
  let action = if lang == "zh" { "返回首页" } else { "Back to home" }
  "<h1 class=\"mp-404-title\">" +
  escape_html(heading) +
  "</h1>\n<p>" +
  escape_html(message) +
  "</p>\n<p><a class=\"mp-404-home\" href=\"" +
  escape_html(localized_href_with_base_url(config.base_url, lang, "/")) +
  "\">" +
  escape_html(action) +
  "</a></p>\n"
}

///|
/// Title used by the generated 404 page.
pub fn not_found_title(lang : String) -> String {
  if lang == "zh" {
    "页面不存在"
  } else {
    "Page not found"
  }
}
