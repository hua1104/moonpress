///|
pub(all) struct OutputFile {
  path : String
  content : String
}

///|
pub(all) struct BuildResult {
  files : Array[OutputFile]
  page_count : Int
}

///|
pub fn build_site(sources : Array[PageSource]) -> BuildResult {
  build_site_with_config(sources, default_config())
}

///|
pub fn build_site_with_config(
  sources : Array[PageSource],
  config : SiteConfig,
) -> BuildResult {
  build_site_for_lang(sources, config, "en")
}

///|
pub fn build_site_for_lang(
  sources : Array[PageSource],
  config : SiteConfig,
  lang : String,
) -> BuildResult {
  let pages = collect_pages_for_lang(sources, lang)
  let sidebar = render_sidebar_with_base_url(
    navigation_from_pages(pages),
    lang,
    config.base_url,
  )
  let files : Array[OutputFile] = []
  for index, page in pages {
    let markdown = page_source_body(sources, page.source_path)
    let navigation = render_language_switcher_with_base_url(
        lang,
        page.route,
        config.base_url,
      ) +
      sidebar
    files.push({
      path: localized_output_path(lang, page.output_path),
      content: render_page_with_meta(
        config,
        {
          title: page.title,
          description: page.description,
          lang,
          route: page.route,
          navigation,
          footer: render_pager_with_base_url(
            pages,
            index,
            lang,
            config.base_url,
          ),
          toc: render_toc_for_markdown(markdown, lang),
        },
        markdown,
      ),
    })
  }
  files.push({
    path: localized_output_path(lang, "search-index.json"),
    content: build_search_index_for_lang(pages, sources, config.base_url, lang),
  })
  files.push({
    path: localized_output_path(lang, "sitemap.xml"),
    content: build_sitemap_for_lang(pages, config.base_url, lang),
  })
  files.push({
    path: localized_output_path(lang, "feed.xml"),
    content: build_feed_for_lang(config, pages, lang),
  })
  files.push({
    path: localized_output_path(lang, "404.html"),
    content: page_shell_with_meta(
      config,
      {
        title: not_found_title(lang),
        description: "",
        lang,
        route: "/404",
        navigation: render_language_switcher_with_base_url(
          lang,
          "/",
          config.base_url,
        ) +
        sidebar,
        footer: "",
        toc: "",
      },
      not_found_body(config, lang),
    ),
  })
  files.push({
    path: localized_output_path(lang, "assets/moonpress.css"),
    content: default_stylesheet(),
  })
  files.push({
    path: localized_output_path(lang, "assets/moonpress-search.js"),
    content: search_script(config.base_url, lang),
  })
  files.push({
    path: localized_output_path(lang, "robots.txt"),
    content: build_robots_txt(config, lang),
  })
  let result = { files, page_count: pages.length() }
  files.push({
    path: localized_output_path(lang, "moonpress-manifest.txt"),
    content: build_manifest(result),
  })
  { files, page_count: pages.length() }
}

///|
pub fn merge_build_results(results : Array[BuildResult]) -> BuildResult {
  let files : Array[OutputFile] = []
  let mut page_count = 0
  for result in results {
    page_count = page_count + result.page_count
    for file in result.files {
      files.push(file)
    }
  }
  { files, page_count }
}

///|
fn localized_output_path(lang : String, path : String) -> String {
  if lang == "en" {
    path
  } else {
    lang + "/" + path
  }
}

///|
fn build_robots_txt(config : SiteConfig, lang : String) -> String {
  let sitemap = if lang == "en" {
    "/sitemap.xml"
  } else {
    "/" + lang + "/sitemap.xml"
  }
  let location = if config.site_url == "" {
    with_base_url(config.base_url, sitemap)
  } else {
    canonical_url(config, lang, "/") + "sitemap.xml"
  }
  "User-agent: *\nAllow: /\nSitemap: " + location + "\n"
}

///|
/// Colour tokens shared by the light and dark themes. The dark values are
/// applied both by the `prefers-color-scheme` media query and by the explicit
/// `data-theme` attribute set by the theme switch.
fn dark_theme_tokens() -> String {
  "--mp-bg:#0f171e;--mp-surface:#151f28;--mp-surface-2:#1b2732;--mp-text:#e6edf3;" +
  "--mp-muted:#9db0c0;--mp-border:#2b3a47;--mp-accent:#7cc6e8;--mp-accent-soft:#1c2c38;" +
  "--mp-strong:#cfe6f2;--mp-shadow:rgba(0,0,0,.45);" +
  "--mp-kw:#e59ac9;--mp-str:#7fd6a8;--mp-com:#7d8f9e;--mp-num:#e7b177;--mp-fn:#8ac6f0"
}

///|
pub fn default_stylesheet() -> String {
  ":root{--mp-bg:#f7f9fb;--mp-surface:#ffffff;--mp-surface-2:#f2f6f9;--mp-text:#17202a;" +
  "--mp-muted:#5b7284;--mp-border:#dbe4ea;--mp-accent:#075b7d;--mp-accent-soft:#eaf3f7;" +
  "--mp-strong:#0f3d5e;--mp-shadow:rgba(15,61,94,.12);" +
  "--mp-kw:#8a2f6b;--mp-str:#0a6b4a;--mp-com:#78899a;--mp-num:#9a5b12;--mp-fn:#0f5f8f}" +
  "@media(prefers-color-scheme:dark){:root:not([data-theme=\"light\"]){" +
  dark_theme_tokens() +
  "}}" +
  ":root[data-theme=\"dark\"]{" +
  dark_theme_tokens() +
  "}" +
  "*{box-sizing:border-box}" +
  ".mp-page{display:flex;align-items:flex-start;gap:32px;width:min(1140px,calc(100% - 32px));margin:0 auto}" +
  ".mp-aside{position:sticky;top:104px;flex:0 0 220px;padding:36px 0;font-size:.9rem}" +
  ".mp-toc-title{margin:0 0 8px;color:var(--mp-muted);font-size:.78rem;letter-spacing:.08em;text-transform:uppercase}" +
  ".mp-toc ul{margin:0;padding:0;list-style:none;border-left:1px solid var(--mp-border)}" +
  ".mp-toc li{margin:0}.mp-toc a{display:block;padding:5px 12px;color:var(--mp-muted);text-decoration:none}" +
  ".mp-toc a:hover,.mp-toc a:focus-visible,.mp-toc a.active{color:var(--mp-accent);background:var(--mp-accent-soft)}" +
  ".mp-toc-l3 a{padding-left:26px;font-size:.86em}" +
  ".mp-nav-group{margin:0}.mp-nav-group-title{cursor:pointer;padding:6px 10px;color:var(--mp-muted);font-size:.82rem;letter-spacing:.06em;text-transform:uppercase}" +
  ".mp-nav-group[open] .mp-nav-group-title{color:var(--mp-strong)}" +
  ".mp-theme{min-height:32px;padding:0 10px;border:1px solid var(--mp-border);background:var(--mp-surface);color:var(--mp-muted);font:inherit;font-size:.85rem;cursor:pointer}" +
  ".mp-theme:hover,.mp-theme:focus-visible{color:var(--mp-accent);border-color:var(--mp-accent)}" +
  ".mp-code{margin:20px 0;border:1px solid var(--mp-border);background:var(--mp-surface)}" +
  ".mp-code-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:6px 12px;border-bottom:1px solid var(--mp-border);background:var(--mp-surface-2);color:var(--mp-muted);font-size:.78rem;letter-spacing:.06em}" +
  ".mp-code pre{margin:0;border:0}" +
  ".mp-copy{min-height:28px;padding:0 10px;border:1px solid var(--mp-border);background:var(--mp-surface);color:var(--mp-muted);font:inherit;font-size:.78rem;cursor:pointer}" +
  ".mp-copy:hover,.mp-copy:focus-visible{color:var(--mp-accent);border-color:var(--mp-accent)}" +
  ".mp-tok-keyword{color:var(--mp-kw)}.mp-tok-string{color:var(--mp-str)}.mp-tok-comment{color:var(--mp-com);font-style:italic}" +
  ".mp-tok-number{color:var(--mp-num)}.mp-tok-function{color:var(--mp-fn)}" +
  ".mp-task{list-style:none;margin-left:-20px}.mp-task input{margin-right:6px}" +
  ".mp-fn-ref a{text-decoration:none}.mp-footnotes{margin-top:48px;color:var(--mp-muted);font-size:.92rem}" +
  ".mp-fn-back{margin-left:6px;text-decoration:none}" +
  ".mp-404-title{margin-top:8px}" +
  ":root{font-family:Inter,ui-sans-serif,system-ui,sans-serif;color:var(--mp-text);background:var(--mp-bg);line-height:1.6}" +
  "body{margin:0}.mp-header{position:sticky;top:0;z-index:10;border-bottom:1px solid var(--mp-border);background:var(--mp-surface)}" +
  ".mp-lang-switch{display:flex;align-items:center;justify-content:flex-end;gap:6px;padding:8px max(16px,calc((100% - 1140px)/2));border-bottom:1px solid var(--mp-border)}" +
  ".mp-lang{padding:5px 9px;color:var(--mp-muted);text-decoration:none}.mp-lang.active{color:var(--mp-strong);font-weight:700;background:var(--mp-accent-soft)}" +
  ".mp-sidebar{display:flex;align-items:center;gap:6px;flex-wrap:wrap;max-width:1140px;margin:0 auto;padding:10px 16px}" +
  ".mp-nav-item{min-height:40px;display:inline-flex;align-items:center;padding:0 12px;border:1px solid var(--mp-border);color:var(--mp-strong);text-decoration:none}" +
  ".mp-nav-item:hover,.mp-nav-item:focus-visible{background:var(--mp-accent-soft);border-color:var(--mp-accent)}" +
  ".mp-doc{flex:1 1 auto;min-width:0;max-width:760px;margin:0 auto;padding:42px 0 72px}" +
  "h1,h2,h3,h4,h5,h6{line-height:1.25;scroll-margin-top:96px}.mp-doc a{color:var(--mp-accent);text-underline-offset:3px}" +
  ".mp-anchor{margin-left:8px;color:var(--mp-muted);text-decoration:none;opacity:0;transition:opacity .15s}" +
  "h1:hover .mp-anchor,h2:hover .mp-anchor,h3:hover .mp-anchor,h4:hover .mp-anchor,h5:hover .mp-anchor,h6:hover .mp-anchor,.mp-anchor:focus-visible{opacity:1}" +
  "code,pre{font-family:ui-monospace,Consolas,monospace}" +
  "pre{overflow-x:auto;padding:14px 16px;border:1px solid var(--mp-border);background:var(--mp-surface)}" +
  ":not(pre)>code{padding:2px 5px;border:1px solid var(--mp-border);background:var(--mp-surface-2)}" +
  "blockquote{margin:20px 0;padding:2px 18px;border-left:4px solid var(--mp-accent);background:var(--mp-surface-2);color:var(--mp-muted)}" +
  "img{max-width:100%;height:auto}hr{margin:32px 0;border:0;border-top:1px solid var(--mp-border)}" +
  "table{width:100%;border-collapse:collapse;margin:20px 0}th,td{padding:8px 12px;border:1px solid var(--mp-border);text-align:left}" +
  "thead th{background:var(--mp-surface-2)}" +
  ".mp-search{position:relative;max-width:1140px;margin:0 auto;padding:0 16px 10px}" +
  ".mp-search-input{width:100%;min-height:40px;padding:0 12px;border:1px solid var(--mp-border);background:var(--mp-surface);color:inherit;font:inherit}" +
  ".mp-search-input:focus-visible{outline:2px solid var(--mp-accent);outline-offset:1px}" +
  ".mp-search-results{position:absolute;left:16px;right:16px;z-index:20;max-height:60vh;overflow-y:auto;margin:4px 0 0;padding:0;list-style:none;border:1px solid var(--mp-border);background:var(--mp-surface);box-shadow:0 8px 24px var(--mp-shadow)}" +
  ".mp-search-results li{display:flex;flex-direction:column;gap:2px;padding:10px 12px;border-bottom:1px solid var(--mp-border)}" +
  ".mp-search-results li:last-child{border-bottom:0}.mp-search-results a{color:var(--mp-strong);font-weight:600;text-decoration:none}" +
  ".mp-search-excerpt{color:var(--mp-muted);font-size:.875rem}.mp-search-empty{color:var(--mp-muted)}" +
  ".mp-pager{display:flex;justify-content:space-between;gap:12px;margin-top:40px;padding-top:20px;border-top:1px solid var(--mp-border)}" +
  ".mp-pager a{display:inline-flex;align-items:center;min-height:40px;padding:0 12px;border:1px solid var(--mp-border);color:var(--mp-strong);text-decoration:none}.mp-pager a:hover,.mp-pager a:focus-visible{background:var(--mp-accent-soft)}" +
  "@media(max-width:1080px){.mp-aside{display:none}}" +
  "@media(max-width:600px){.mp-doc{padding-top:28px}.mp-sidebar{flex-wrap:nowrap;overflow-x:auto}.mp-nav-item{flex:0 0 auto}.mp-pager{align-items:stretch;flex-direction:column}.mp-pager a{justify-content:center}}"
}

///|
fn page_source_body(sources : Array[PageSource], path : String) -> String {
  for source in sources {
    if source.path == path {
      return strip_front_matter(source.source)
    }
  }
  ""
}
