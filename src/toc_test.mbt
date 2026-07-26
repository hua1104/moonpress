///|
test "collect headings skips h1 and fenced code" {
  let entries = collect_headings(
    "# T\n\n## Alpha\n\n### Beta\n\n```\n## not a heading\n```\n\n## Gamma",
  )
  inspect(entries.length(), content="3")
  inspect(entries[0].id, content="alpha")
  inspect(entries[1].level, content="3")
  inspect(entries[2].title, content="Gamma")
}

///|
test "render toc lists h2 and h3 anchors" {
  inspect(
    render_toc_for_markdown(
      "# T\n\n## Alpha\n\n### Beta\n\ntext\n\n## Gamma", "en",
    ),
    content=(
      #|<nav class="mp-toc" aria-label="On this page">
      #|  <p class="mp-toc-title">On this page</p>
      #|  <ul>
      #|    <li class="mp-toc-l2"><a href="#alpha">Alpha</a></li>
      #|    <li class="mp-toc-l3"><a href="#beta">Beta</a></li>
      #|    <li class="mp-toc-l2"><a href="#gamma">Gamma</a></li>
      #|  </ul>
      #|</nav>
      #|
    ),
  )
}

///|
test "render toc is localized and skips short pages" {
  inspect(
    render_toc_for_markdown("## 甲\n\n## 乙", "zh").find("本页目录")
    is Some(_),
    content="true",
  )
  inspect(render_toc_for_markdown("## Only", "en"), content="")
}
