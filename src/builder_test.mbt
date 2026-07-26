///|
test "build site renders pages and default asset" {
  let result = build_site([
    { path: "index.md", source: "---\ntitle: Home\n---\n# Home\nWelcome." },
    { path: "guide/start.md", source: "# Start" },
  ])
  inspect(result.page_count, content="2")
  let paths : Array[String] = []
  for file in result.files {
    paths.push(file.path)
  }
  inspect(
    paths.join("\n"),
    content=(
      #|index.html
      #|guide/start/index.html
      #|search-index.json
      #|sitemap.xml
      #|feed.xml
      #|404.html
      #|assets/moonpress.css
      #|assets/moonpress-search.js
      #|robots.txt
      #|moonpress-manifest.txt
    ),
  )
}

///|
test "build site skips draft pages" {
  let result = build_site([
    { path: "draft.md", source: "---\ntitle: Draft\ndraft: true\n---\n# Draft" },
  ])
  inspect(result.page_count, content="0")
  inspect(result.files.length(), content="8")
}

///|
test "build site emits a localized feed and 404 page" {
  let result = build_site_for_lang(
    [
      {
        path: "zh/index.md",
        source: "---\ntitle: 首页\nlang: zh\n---\n# 首页",
      },
    ],
    { ..default_config(), base_url: "/moonpress/" },
    "zh",
  )
  let mut feed = ""
  let mut not_found = ""
  for file in result.files {
    if file.path == "zh/feed.xml" {
      feed = file.content
    }
    if file.path == "zh/404.html" {
      not_found = file.content
    }
  }
  inspect(feed.find("<rss version=\"2.0\"") is Some(_), content="true")
  inspect(feed.find("<link>/moonpress/zh/</link>") is Some(_), content="true")
  inspect(not_found.find("页面不存在") is Some(_), content="true")
  inspect(not_found.find("href=\"/moonpress/zh/\"") is Some(_), content="true")
}

///|
test "build site renders an on-page toc for long documents" {
  let result = build_site([
    {
      path: "index.md",
      source: "---\ntitle: Home\n---\n# Home\n\n## Alpha\n\ntext\n\n## Beta\n\ntext",
    },
  ])
  let html = result.files[0].content
  inspect(html.find("class=\"mp-toc\"") is Some(_), content="true")
  inspect(html.find("href=\"#alpha\"") is Some(_), content="true")
  inspect(html.find("class=\"mp-aside\"") is Some(_), content="true")
}

///|
test "build site uses config base url for html and sitemap" {
  let result = build_site_with_config(
    [{ path: "index.md", source: "# Home" }],
    { ..default_config(), base_url: "https://example.com/docs/" },
  )
  inspect(result.files[1].path, content="search-index.json")
  inspect(result.files[2].path, content="sitemap.xml")
  inspect(
    result.files[0].content.find(
      "href=\"https://example.com/docs/assets/moonpress.css\"",
    )
    is Some(_),
    content="true",
  )
  inspect(
    result.files[0].content.find("href=\"https://example.com/docs/\"")
    is Some(_),
    content="true",
  )
  inspect(
    result.files[2].content,
    content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n  <url><loc>https://example.com/docs/</loc></url>\n</urlset>\n",
  )
}

///|
test "localized build uses one base url for every html link" {
  let result = build_site_for_lang(
    [
      {
        path: "zh/index.md",
        source: "---\ntitle: Home\nlang: zh\norder: 1\n---\n# Home",
      },
      {
        path: "zh/guide.md",
        source: "---\ntitle: Guide\nlang: zh\norder: 2\n---\n# Guide",
      },
    ],
    { ..default_config(), base_url: "/moonpress/" },
    "zh",
  )
  let html = result.files[0].content
  inspect(
    html.find("href=\"/moonpress/assets/moonpress.css\"") is Some(_),
    content="true",
  )
  inspect(html.find("href=\"/moonpress/zh/guide\"") is Some(_), content="true")
  inspect(html.find("href=\"/moonpress/\"") is Some(_), content="true")
  inspect(
    result.files[3].content.find("<loc>/moonpress/zh/</loc>") is Some(_),
    content="true",
  )
}

///|
test "build site for zh writes localized output paths" {
  let result = build_site_for_lang(
    [
      {
        path: "zh/index.md",
        source: "---\ntitle: 首页\nlang: zh\n---\n# 首页",
      },
    ],
    default_config(),
    "zh",
  )
  inspect(result.page_count, content="1")
  inspect(result.files[0].path, content="zh/index.html")
  inspect(result.files[0].content.find("中文") is Some(_), content="true")
  inspect(
    result.files[0].content.find("href=\"/zh/\"") is Some(_),
    content="true",
  )
}

///|
test "merge build results sums pages and files" {
  let merged = merge_build_results([
    { page_count: 1, files: [{ path: "index.html", content: "" }] },
    { page_count: 1, files: [{ path: "zh/index.html", content: "" }] },
  ])
  inspect(merged.page_count, content="2")
  inspect(merged.files.length(), content="2")
}
