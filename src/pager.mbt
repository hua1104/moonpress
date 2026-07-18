///|
pub fn render_pager(pages : Array[PagePlan], index : Int) -> String {
  render_pager_for_lang(pages, index, "en")
}

///|
pub fn render_pager_for_lang(
  pages : Array[PagePlan],
  index : Int,
  lang : String,
) -> String {
  render_pager_with_base_url(pages, index, lang, "/")
}

///|
pub fn render_pager_with_base_url(
  pages : Array[PagePlan],
  index : Int,
  lang : String,
  base_url : String,
) -> String {
  let prev = if index > 0 { Some(pages[index - 1]) } else { None }
  let next = if index + 1 < pages.length() {
    Some(pages[index + 1])
  } else {
    None
  }
  if prev is None && next is None {
    ""
  } else {
    let mut html = "<nav class=\"mp-pager\">\n"
    match prev {
      Some(page) =>
        html = html +
          "  <a class=\"mp-prev\" href=\"" +
          escape_html(localized_href_with_base_url(base_url, lang, page.route)) +
          "\">Previous: " +
          escape_html(page.title) +
          "</a>\n"
      None => ()
    }
    match next {
      Some(page) =>
        html = html +
          "  <a class=\"mp-next\" href=\"" +
          escape_html(localized_href_with_base_url(base_url, lang, page.route)) +
          "\">Next: " +
          escape_html(page.title) +
          "</a>\n"
      None => ()
    }
    html + "</nav>\n"
  }
}
