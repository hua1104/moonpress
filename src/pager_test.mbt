///|
test "render pager links neighboring pages" {
  let pages = collect_pages([
    { path: "index.md", source: "---\ntitle: Home\norder: 1\n---\n# Home" },
    { path: "guide.md", source: "---\ntitle: Guide\norder: 2\n---\n# Guide" },
  ])
  inspect(
    render_pager(pages, 0),
    content="<nav class=\"mp-pager\">\n  <a class=\"mp-next\" href=\"/guide\">Next: Guide</a>\n</nav>\n",
  )
  inspect(
    render_pager(pages, 1),
    content="<nav class=\"mp-pager\">\n  <a class=\"mp-prev\" href=\"/\">Previous: Home</a>\n</nav>\n",
  )
}

///|
test "render pager keeps localized links" {
  let pages = collect_pages_for_lang(
    [
      {
        path: "zh/index.md",
        source: "---\ntitle: 首页\norder: 1\nlang: zh\n---\n# 首页",
      },
      {
        path: "zh/guide.md",
        source: "---\ntitle: 指南\norder: 2\nlang: zh\n---\n# 指南",
      },
    ],
    "zh",
  )
  inspect(
    render_pager_for_lang(pages, 0, "zh"),
    content="<nav class=\"mp-pager\">\n  <a class=\"mp-next\" href=\"/zh/guide\">Next: 指南</a>\n</nav>\n",
  )
}
