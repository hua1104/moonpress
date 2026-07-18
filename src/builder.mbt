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
    files.push({
      path: localized_output_path(lang, page.output_path),
      content: render_page_with_base_url(
        page.title,
        lang,
        render_language_switcher_with_base_url(
          lang,
          page.route,
          config.base_url,
        ) +
        sidebar,
        markdown,
        render_pager_with_base_url(pages, index, lang, config.base_url),
        config.base_url,
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
    path: localized_output_path(lang, "assets/moonpress.css"),
    content: default_stylesheet(),
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
pub fn default_stylesheet() -> String {
  ":root{font-family:Inter,ui-sans-serif,system-ui,sans-serif;color:#17202a;background:#f7f9fb;line-height:1.6}" +
  "body{margin:0}.mp-header{position:sticky;top:0;z-index:10;border-bottom:1px solid #dbe4ea;background:#ffffff}" +
  ".mp-lang-switch{display:flex;justify-content:flex-end;gap:4px;padding:8px max(16px,calc((100% - 960px)/2));border-bottom:1px solid #edf1f5}" +
  ".mp-lang{padding:5px 9px;color:#496273;text-decoration:none}.mp-lang.active{color:#0f3d5e;font-weight:700;background:#eaf3f7}" +
  ".mp-sidebar{display:flex;gap:6px;flex-wrap:wrap;max-width:960px;margin:0 auto;padding:10px 16px}" +
  ".mp-nav-item{min-height:40px;box-sizing:border-box;display:inline-flex;align-items:center;padding:0 12px;border:1px solid #dbe4ea;color:#0f3d5e;text-decoration:none}" +
  ".mp-nav-item:hover,.mp-nav-item:focus-visible{background:#eaf3f7;border-color:#79aabd}.mp-doc{width:min(760px,calc(100% - 32px));margin:0 auto;padding:42px 0 72px}" +
  "h1,h2,h3{line-height:1.2}.mp-doc a{color:#075b7d;text-underline-offset:3px}code,pre{font-family:ui-monospace,Consolas,monospace}" +
  "pre{overflow-x:auto;padding:14px 16px;border:1px solid #dbe4ea;background:#ffffff}.mp-pager{display:flex;justify-content:space-between;gap:12px;margin-top:40px;padding-top:20px;border-top:1px solid #dbe4ea}" +
  ".mp-pager a{display:inline-flex;align-items:center;min-height:40px;padding:0 12px;border:1px solid #9db7c4;color:#0f3d5e;text-decoration:none}.mp-pager a:hover,.mp-pager a:focus-visible{background:#eaf3f7}@media(max-width:600px){.mp-doc{padding-top:28px}.mp-sidebar{flex-wrap:nowrap;overflow-x:auto}.mp-nav-item{flex:0 0 auto}.mp-pager{align-items:stretch;flex-direction:column}.mp-pager a{justify-content:center}}"
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
