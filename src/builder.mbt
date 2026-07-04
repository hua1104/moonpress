pub(all) struct OutputFile {
  path : String
  content : String
}

pub(all) struct BuildResult {
  files : Array[OutputFile]
  page_count : Int
}

pub fn build_site(sources : Array[PageSource]) -> BuildResult {
  build_site_with_config(sources, default_config())
}

pub fn build_site_with_config(
  sources : Array[PageSource],
  config : SiteConfig
) -> BuildResult {
  build_site_for_lang(sources, config, "en")
}

pub fn build_site_for_lang(
  sources : Array[PageSource],
  config : SiteConfig,
  lang : String
) -> BuildResult {
  let pages = collect_pages_for_lang(sources, lang)
  let sidebar = render_sidebar_for_lang(navigation_from_pages(pages), lang)
  let files : Array[OutputFile] = []
  for index, page in pages {
    let markdown = page_source_body(sources, page.source_path)
    files.push({
      path: localized_output_path(lang, page.output_path),
      content: render_page_with_chrome(
        page.title,
        lang,
        render_language_switcher(lang, page.route) + sidebar,
        markdown,
        render_pager_for_lang(pages, index, lang),
      ),
    })
  }
  files.push({
    path: localized_output_path(lang, "search-index.json"),
    content: build_search_index(pages, sources),
  })
  files.push({
    path: localized_output_path(lang, "sitemap.xml"),
    content: build_sitemap(pages, config.base_url),
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

fn localized_output_path(lang : String, path : String) -> String {
  if lang == "en" {
    path
  } else {
    lang + "/" + path
  }
}

pub fn default_stylesheet() -> String {
  ":root{font-family:system-ui,sans-serif;color:#17202a;background:#f7f9fb}" +
  "body{margin:0}.mp-doc{width:min(760px,calc(100% - 32px));margin:0 auto;padding:48px 0 72px}" +
  ".mp-sidebar{display:flex;gap:12px;flex-wrap:wrap;padding:16px 24px;border-bottom:1px solid #dbe4ea}" +
  ".mp-nav-item{color:#0f3d5e;text-decoration:none}.mp-nav-item:hover{text-decoration:underline}" +
  ".mp-pager{display:flex;justify-content:space-between;gap:16px;margin-top:40px;padding-top:20px;border-top:1px solid #dbe4ea}" +
  ".mp-pager a{color:#0f3d5e;text-decoration:none}"
}

fn page_source_body(sources : Array[PageSource], path : String) -> String {
  for source in sources {
    if source.path == path {
      return strip_front_matter(source.source)
    }
  }
  ""
}
