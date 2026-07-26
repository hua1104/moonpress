///|
test "navigation keeps route depth" {
  let pages = collect_pages([
    { path: "index.md", source: "# Home" },
    { path: "guide/start.md", source: "# Start" },
  ])
  let nav = navigation_from_pages(pages)
  inspect(nav.length(), content="2")
  inspect(nav[0].depth, content="0")
  inspect(nav[1].depth, content="1")
}

///|
test "render sidebar escapes item titles" {
  let html = render_sidebar([
    { title: "Use <MoonPress>", route: "/guide", depth: 0 },
  ])
  inspect(
    html,
    content="<nav class=\"mp-sidebar\">\n  <a class=\"mp-nav-item depth-0\" href=\"/guide\">Use &lt;MoonPress&gt;</a>\n</nav>\n",
  )
}

///|
test "render sidebar keeps localized links" {
  let html = render_sidebar_for_lang(
    [
      { title: "首页", route: "/", depth: 0 },
      { title: "快速开始", route: "/guide/start", depth: 1 },
    ],
    "zh",
  )
  inspect(
    html,
    content=(
      #|<nav class="mp-sidebar">
      #|  <a class="mp-nav-item depth-0" href="/zh/">首页</a>
      #|  <details class="mp-nav-group" open>
      #|    <summary class="mp-nav-group-title">Guide</summary>
      #|    <a class="mp-nav-item depth-1" href="/zh/guide/start">快速开始</a>
      #|  </details>
      #|</nav>
      #|
    ),
  )
}

///|
test "route section splits on the first nested segment" {
  inspect(route_section("/"), content="")
  inspect(route_section("/guide"), content="")
  inspect(route_section("/guide/start"), content="guide")
  inspect(route_section("/api/core/render"), content="api")
}

///|
test "render sidebar groups nested routes and closes sections" {
  let html = render_sidebar_with_base_url(
    [
      { title: "Home", route: "/", depth: 0 },
      { title: "Start", route: "/guide/start", depth: 1 },
      { title: "Next", route: "/guide/next", depth: 1 },
      { title: "About", route: "/about", depth: 0 },
    ],
    "en",
    "/moonpress/",
  )
  inspect(
    html,
    content=(
      #|<nav class="mp-sidebar">
      #|  <a class="mp-nav-item depth-0" href="/moonpress/">Home</a>
      #|  <details class="mp-nav-group" open>
      #|    <summary class="mp-nav-group-title">Guide</summary>
      #|    <a class="mp-nav-item depth-1" href="/moonpress/guide/start">Start</a>
      #|    <a class="mp-nav-item depth-1" href="/moonpress/guide/next">Next</a>
      #|  </details>
      #|  <a class="mp-nav-item depth-0" href="/moonpress/about">About</a>
      #|</nav>
      #|
    ),
  )
}

///|
test "navigation and language switcher honor base url" {
  let sidebar = render_sidebar_with_base_url(
    [{ title: "Guide", route: "/guide", depth: 0 }],
    "en",
    "/moonpress/",
  )
  inspect(sidebar.find("href=\"/moonpress/guide\"") is Some(_), content="true")
  let switcher = render_language_switcher_with_base_url(
    "en", "/guide", "/moonpress/",
  )
  inspect(switcher.find("href=\"/moonpress/guide\"") is Some(_), content="true")
  inspect(
    switcher.find("href=\"/moonpress/zh/guide\"") is Some(_),
    content="true",
  )
}
