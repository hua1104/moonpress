pub fn page_shell(title : String, body : String) -> String {
  page_shell_with_navigation(title, "", body)
}

pub fn page_shell_with_navigation(
  title : String,
  navigation : String,
  body : String
) -> String {
  page_shell_with_navigation_and_footer(title, "en", navigation, body, "")
}

pub fn page_shell_with_navigation_and_footer(
  title : String,
  lang : String,
  navigation : String,
  body : String,
  footer : String
) -> String {
  "<!doctype html>\n" +
  "<html lang=\"" + escape_html(lang) + "\">\n" +
  "<head>\n" +
  "  <meta charset=\"utf-8\">\n" +
  "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
  "  <title>" + escape_html(title) + "</title>\n" +
  "  <link rel=\"stylesheet\" href=\"/assets/moonpress.css\">\n" +
  "</head>\n" +
  "<body>\n" +
  navigation +
  "  <main class=\"mp-doc\">\n" +
  body +
  footer +
  "  </main>\n" +
  "</body>\n" +
  "</html>\n"
}

pub fn render_page(title : String, markdown : String) -> String {
  page_shell(title, render_markdown(markdown))
}

pub fn render_page_with_navigation(
  title : String,
  navigation : String,
  markdown : String
) -> String {
  page_shell_with_navigation(title, navigation, render_markdown(markdown))
}

pub fn render_page_with_chrome(
  title : String,
  lang : String,
  navigation : String,
  markdown : String,
  footer : String
) -> String {
  page_shell_with_navigation_and_footer(
    title,
    lang,
    navigation,
    render_markdown(markdown),
    footer,
  )
}
