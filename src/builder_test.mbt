test "build site renders pages and default asset" {
  let result = build_site([
    {
      path: "index.md",
      source: "---\ntitle: Home\n---\n# Home\nWelcome.",
    },
    {
      path: "guide/start.md",
      source: "# Start",
    },
  ])
  inspect(result.page_count, content="2")
  inspect(result.files.length(), content="6")
  inspect(result.files[0].path, content="index.html")
  inspect(result.files[1].path, content="guide/start/index.html")
  inspect(result.files[2].path, content="search-index.json")
  inspect(result.files[3].path, content="sitemap.xml")
  inspect(result.files[4].path, content="assets/moonpress.css")
  inspect(result.files[5].path, content="moonpress-manifest.txt")
}

test "build site skips draft pages" {
  let result = build_site([
    {
      path: "draft.md",
      source: "---\ntitle: Draft\ndraft: true\n---\n# Draft",
    },
  ])
  inspect(result.page_count, content="0")
  inspect(result.files.length(), content="4")
}

test "build site uses config base url for sitemap" {
  let result = build_site_with_config(
    [
      {
        path: "index.md",
        source: "# Home",
      },
    ],
    {
      title: "Docs",
      description: "Docs",
      base_url: "https://example.com/docs/",
    },
  )
  inspect(result.files[1].path, content="search-index.json")
  inspect(result.files[2].path, content="sitemap.xml")
  inspect(
    result.files[2].content,
    content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n  <url><loc>https://example.com/docs/</loc></url>\n</urlset>\n",
  )
}

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
  inspect(result.files[0].content.find("href=\"/zh/\"") is Some(_), content="true")
}

test "merge build results sums pages and files" {
  let merged = merge_build_results([
    { page_count: 1, files: [{ path: "index.html", content: "" }] },
    { page_count: 1, files: [{ path: "zh/index.html", content: "" }] },
  ])
  inspect(merged.page_count, content="2")
  inspect(merged.files.length(), content="2")
}
