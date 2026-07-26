///|
pub(all) struct PageMeta {
  title : String
  description : String
  lang : String
  route : String
  navigation : String
  footer : String
  toc : String
}

///|
pub fn page_shell(title : String, body : String) -> String {
  page_shell_with_navigation(title, "", body)
}

///|
pub fn page_shell_with_navigation(
  title : String,
  navigation : String,
  body : String,
) -> String {
  page_shell_with_navigation_and_footer(title, "en", navigation, body, "")
}

///|
pub fn page_shell_with_navigation_and_footer(
  title : String,
  lang : String,
  navigation : String,
  body : String,
  footer : String,
) -> String {
  page_shell_with_base_url(title, lang, navigation, body, footer, "/")
}

///|
pub fn page_shell_with_base_url(
  title : String,
  lang : String,
  navigation : String,
  body : String,
  footer : String,
  base_url : String,
) -> String {
  page_shell_with_meta(
    { ..default_config(), base_url, },
    { title, description: "", lang, route: "/", navigation, footer, toc: "" },
    body,
  )
}

///|
pub fn page_shell_with_meta(
  config : SiteConfig,
  meta : PageMeta,
  body : String,
) -> String {
  let head = StringBuilder::new()
  head.write_string("<!doctype html>\n")
  head.write_string("<html lang=\"" + escape_html(meta.lang) + "\">\n")
  head.write_string("<head>\n")
  head.write_string("  <meta charset=\"utf-8\">\n")
  head.write_string(
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
  )
  head.write_string("  <meta name=\"color-scheme\" content=\"light dark\">\n")
  head.write_string(theme_bootstrap_script())
  let full_title = if meta.title == "" || meta.title == config.title {
    config.title
  } else {
    meta.title + " | " + config.title
  }
  head.write_string("  <title>" + escape_html(full_title) + "</title>\n")
  let description = if meta.description == "" {
    config.description
  } else {
    meta.description
  }
  if description != "" {
    head.write_string(
      "  <meta name=\"description\" content=\"" +
      escape_html(description) +
      "\">\n",
    )
  }
  if config.author != "" {
    head.write_string(
      "  <meta name=\"author\" content=\"" +
      escape_html(config.author) +
      "\">\n",
    )
  }
  let canonical = canonical_url(config, meta.lang, meta.route)
  if canonical != "" {
    head.write_string(
      "  <link rel=\"canonical\" href=\"" + escape_html(canonical) + "\">\n",
    )
    head.write_string(
      "  <link rel=\"alternate\" hreflang=\"en\" href=\"" +
      escape_html(canonical_url(config, "en", meta.route)) +
      "\">\n",
    )
    head.write_string(
      "  <link rel=\"alternate\" hreflang=\"zh\" href=\"" +
      escape_html(canonical_url(config, "zh", meta.route)) +
      "\">\n",
    )
    head.write_string(
      "  <link rel=\"alternate\" hreflang=\"x-default\" href=\"" +
      escape_html(canonical_url(config, config.default_lang, meta.route)) +
      "\">\n",
    )
  }
  head.write_string(
    "  <meta property=\"og:type\" content=\"website\">\n" +
    "  <meta property=\"og:site_name\" content=\"" +
    escape_html(config.title) +
    "\">\n" +
    "  <meta property=\"og:title\" content=\"" +
    escape_html(full_title) +
    "\">\n",
  )
  if description != "" {
    head.write_string(
      "  <meta property=\"og:description\" content=\"" +
      escape_html(description) +
      "\">\n",
    )
  }
  if canonical != "" {
    head.write_string(
      "  <meta property=\"og:url\" content=\"" +
      escape_html(canonical) +
      "\">\n",
    )
  }
  head.write_string(
    "  <meta name=\"twitter:card\" content=\"summary\">\n" +
    "  <meta name=\"generator\" content=\"MoonPress " +
    version() +
    "\">\n",
  )
  head.write_string(
    "  <link rel=\"stylesheet\" href=\"" +
    escape_html(with_base_url(config.base_url, "/assets/moonpress.css")) +
    "\">\n",
  )
  head.write_string("</head>\n<body>\n")
  if meta.navigation != "" {
    head.write_string("  <header class=\"mp-header\">\n")
    head.write_string(meta.navigation)
    head.write_string("  </header>\n")
  }
  head.write_string("  <div class=\"mp-page\">\n")
  head.write_string("  <main class=\"mp-doc\">\n")
  head.write_string(body)
  head.write_string(meta.footer)
  head.write_string("  </main>\n")
  if meta.toc != "" {
    head.write_string("  <aside class=\"mp-aside\">\n")
    head.write_string(meta.toc)
    head.write_string("  </aside>\n")
  }
  head.write_string("  </div>\n")
  head.write_string(
    "  <script src=\"" +
    escape_html(with_base_url(config.base_url, "/assets/moonpress-search.js")) +
    "\" defer></script>\n",
  )
  head.write_string("</body>\n</html>\n")
  head.to_string()
}

///|
/// Inline script that restores the stored colour scheme before the first paint,
/// so switching to the dark theme never flashes the light one.
pub fn theme_bootstrap_script() -> String {
  "  <script>(function(){try{var t=localStorage.getItem(\"moonpress-theme\");" +
  "if(t===\"dark\"||t===\"light\"){document.documentElement.setAttribute(\"data-theme\",t);}}catch(e){}})();</script>\n"
}

///|
/// Builds an absolute canonical URL when `site_url` is configured.
/// Returns an empty string when the site has no absolute origin.
pub fn canonical_url(
  config : SiteConfig,
  lang : String,
  route : String,
) -> String {
  if config.site_url == "" {
    return ""
  }
  let origin = if config.site_url.has_suffix("/") {
    config.site_url[:config.site_url.length() - 1].to_owned()
  } else {
    config.site_url
  }
  let path = localized_href_with_base_url(config.base_url, lang, route)
  if path.has_prefix("http://") || path.has_prefix("https://") {
    path
  } else {
    origin + path
  }
}

///|
pub fn render_page(title : String, markdown : String) -> String {
  page_shell(title, render_markdown(markdown))
}

///|
pub fn render_page_with_navigation(
  title : String,
  navigation : String,
  markdown : String,
) -> String {
  page_shell_with_navigation(title, navigation, render_markdown(markdown))
}

///|
pub fn render_page_with_chrome(
  title : String,
  lang : String,
  navigation : String,
  markdown : String,
  footer : String,
) -> String {
  page_shell_with_navigation_and_footer(
    title,
    lang,
    navigation,
    render_markdown(markdown),
    footer,
  )
}

///|
pub fn render_page_with_base_url(
  title : String,
  lang : String,
  navigation : String,
  markdown : String,
  footer : String,
  base_url : String,
) -> String {
  page_shell_with_base_url(
    title,
    lang,
    navigation,
    render_markdown(markdown),
    footer,
    base_url,
  )
}

///|
pub fn render_page_with_meta(
  config : SiteConfig,
  meta : PageMeta,
  markdown : String,
) -> String {
  page_shell_with_meta(config, meta, render_markdown(markdown))
}
