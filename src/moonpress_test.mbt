///|
test "normalize markdown route" {
  inspect(normalize_route("guide/start.md"), content="/guide/start")
  inspect(normalize_route("index.md"), content="/")
}

///|
test "render heading" {
  let html = render_markdown("# Hello")
  inspect(html, content="<h1>Hello</h1>\n")
}

///|
test "render fenced code block" {
  let html = render_markdown("```bash\nmoon test\n```")
  inspect(html, content="<pre><code>moon test\n</code></pre>\n")
}

///|
test "render inline code link and list" {
  let html = render_markdown("### Tools\n- Run `moon test`\n- Open [docs](/)")
  inspect(
    html,
    content="<h3>Tools</h3>\n<ul>\n  <li>Run <code>moon test</code></li>\n  <li>Open <a href=\"/\">docs</a></li>\n</ul>\n",
  )
}
