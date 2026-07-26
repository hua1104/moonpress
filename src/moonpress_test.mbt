///|
test "normalize markdown route" {
  inspect(normalize_route("guide/start.md"), content="/guide/start")
  inspect(normalize_route("index.md"), content="/")
}

///|
test "join site paths with root and nested base urls" {
  inspect(with_base_url("/", "/guide"), content="/guide")
  inspect(with_base_url("moonpress/", "/guide"), content="/moonpress/guide")
  inspect(with_base_url("/moonpress/", "/"), content="/moonpress/")
  inspect(
    with_base_url("https://example.com/moonpress/", "/assets/site.css"),
    content="https://example.com/moonpress/assets/site.css",
  )
}

///|
test "render heading" {
  let html = render_markdown("# Hello")
  inspect(
    html,
    content=(
      #|<h1 id="hello">Hello<a class="mp-anchor" href="#hello" aria-label="Permalink">#</a></h1>
      #|
    ),
  )
}

///|
test "render fenced code block" {
  let html = render_markdown("```bash\nmoon test\n```")
  inspect(
    html,
    content=(
      #|<figure class="mp-code" data-lang="bash">
      #|<figcaption class="mp-code-head"><span class="mp-code-title">bash</span></figcaption>
      #|<pre><code class="language-bash">moon test
      #|</code></pre>
      #|</figure>
      #|
    ),
  )
}

///|
test "render inline code link and list" {
  let html = render_markdown("### Tools\n- Run `moon test`\n- Open [docs](/)")
  inspect(
    html,
    content=(
      #|<h3 id="tools">Tools<a class="mp-anchor" href="#tools" aria-label="Permalink">#</a></h3>
      #|<ul>
      #|  <li>Run <code>moon test</code></li>
      #|  <li>Open <a href="/">docs</a></li>
      #|</ul>
      #|
    ),
  )
}
