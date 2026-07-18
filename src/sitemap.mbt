///|
pub fn build_sitemap(pages : Array[PagePlan], base_url : String) -> String {
  build_sitemap_for_lang(pages, base_url, "en")
}

///|
pub fn build_sitemap_for_lang(
  pages : Array[PagePlan],
  base_url : String,
  lang : String,
) -> String {
  let mut xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  xml = xml + "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
  for page in pages {
    xml = xml +
      "  <url><loc>" +
      escape_xml(localized_href_with_base_url(base_url, lang, page.route)) +
      "</loc></url>\n"
  }
  xml + "</urlset>\n"
}

///|
fn escape_xml(input : String) -> String {
  input
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
}
