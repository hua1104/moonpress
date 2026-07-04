pub fn build_sitemap(pages : Array[PagePlan], base_url : String) -> String {
  let base = normalize_base_url(base_url)
  let mut xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  xml = xml + "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
  for page in pages {
    xml = xml + "  <url><loc>" + escape_xml(base + page.route) + "</loc></url>\n"
  }
  xml + "</urlset>\n"
}

fn normalize_base_url(base_url : String) -> String {
  if base_url == "" {
    ""
  } else if base_url.has_suffix("/") {
    base_url[:base_url.length() - 1].to_owned()
  } else {
    base_url
  }
}

fn escape_xml(input : String) -> String {
  input
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
}

