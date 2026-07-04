test "navigation keeps route depth" {
  let pages = collect_pages([
    {
      path: "index.md",
      source: "# Home",
    },
    {
      path: "guide/start.md",
      source: "# Start",
    },
  ])
  let nav = navigation_from_pages(pages)
  inspect(nav.length(), content="2")
  inspect(nav[0].depth, content="0")
  inspect(nav[1].depth, content="1")
}

test "render sidebar escapes item titles" {
  let html = render_sidebar([
    {
      title: "Use <MoonPress>",
      route: "/guide",
      depth: 0,
    },
  ])
  inspect(
    html,
    content="<nav class=\"mp-sidebar\">\n  <a class=\"mp-nav-item depth-0\" href=\"/guide\">Use &lt;MoonPress&gt;</a>\n</nav>\n",
  )
}

test "render sidebar keeps localized links" {
  let html = render_sidebar_for_lang([
    {
      title: "首页",
      route: "/",
      depth: 0,
    },
    {
      title: "快速开始",
      route: "/guide/start",
      depth: 1,
    },
  ], "zh")
  inspect(
    html,
    content="<nav class=\"mp-sidebar\">\n  <a class=\"mp-nav-item depth-0\" href=\"/zh/\">首页</a>\n  <a class=\"mp-nav-item depth-1\" href=\"/zh/guide/start\">快速开始</a>\n</nav>\n",
  )
}
