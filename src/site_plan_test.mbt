///|
test "collect pages skips drafts and builds output paths" {
  let pages = collect_pages([
    { path: "index.md", source: "---\ntitle: Home\n---\n# Ignored" },
    { path: "draft.md", source: "---\ntitle: Draft\ndraft: true\n---\n# Draft" },
    { path: "guide/start.md", source: "---\norder: 2\n---\n# Start" },
  ])
  inspect(pages.length(), content="2")
  inspect(pages[0].route, content="/")
  inspect(pages[0].title, content="Home")
  inspect(pages[1].output_path, content="guide/start/index.html")
  inspect(pages[1].order, content="2")
}

///|
test "collect pages sorts by front matter order" {
  let pages = collect_pages([
    { path: "b.md", source: "---\norder: 2\n---\n# B" },
    { path: "a.md", source: "---\norder: 1\n---\n# A" },
  ])
  inspect(pages[0].route, content="/a")
  inspect(pages[1].route, content="/b")
}

///|
test "fallback title uses last route segment" {
  let page = plan_page("guide/install.md", "Plain paragraph")
  inspect(page.title, content="install")
}
