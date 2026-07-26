///|
test "render bold italic and escapes" {
  inspect(
    render_inline("**bold** and *italic* and \\*literal\\*"),
    content="<strong>bold</strong> and <em>italic</em> and *literal*",
  )
  inspect(
    render_inline("__strong__ with snake_case_word intact"),
    content="<strong>strong</strong> with snake_case_word intact",
  )
}

///|
test "render inline escapes html in text and urls" {
  inspect(
    render_inline("<script>alert(1)</script>"),
    content="&lt;script&gt;alert(1)&lt;/script&gt;",
  )
  inspect(
    render_inline("[x](\"onmouseover=)"),
    content="<a href=\"&quot;onmouseover=\">x</a>",
  )
}

///|
test "render images and external links" {
  inspect(
    render_inline("![logo](/assets/logo.png)"),
    content="<img src=\"/assets/logo.png\" alt=\"logo\" loading=\"lazy\">",
  )
  inspect(
    render_inline("[site](https://example.com)"),
    content="<a href=\"https://example.com\" rel=\"noopener noreferrer\" target=\"_blank\">site</a>",
  )
}

///|
test "render all heading levels with anchors" {
  inspect(
    render_markdown("###### Deep Heading"),
    content=(
      #|<h6 id="deep-heading">Deep Heading<a class="mp-anchor" href="#deep-heading" aria-label="Permalink">#</a></h6>
      #|
    ),
  )
}

///|
test "render ordered list and thematic break" {
  inspect(
    render_markdown("1. one\n2. two\n\n---"),
    content=(
      #|<ol>
      #|  <li>one</li>
      #|  <li>two</li>
      #|</ol>
      #|<hr>
      #|
    ),
  )
}

///|
test "render nested list" {
  inspect(
    render_markdown("- outer\n  - inner\n- second"),
    content=(
      #|<ul>
      #|  <li>outer
      #|<ul>
      #|  <li>inner</li>
      #|</ul>
      #|</li>
      #|  <li>second</li>
      #|</ul>
      #|
    ),
  )
}

///|
test "render blockquote" {
  inspect(
    render_markdown("> quoted **text**\n> more"),
    content=(
      #|<blockquote>
      #|<p>quoted <strong>text</strong> more</p>
      #|</blockquote>
      #|
    ),
  )
}

///|
test "render table with alignment" {
  inspect(
    render_markdown("| A | B |\n|:--|--:|\n| 1 | 2 |"),
    content=(
      #|<table>
      #|<thead>
      #|<tr><th style="text-align:left">A</th><th style="text-align:right">B</th></tr>
      #|</thead>
      #|<tbody>
      #|<tr><td style="text-align:left">1</td><td style="text-align:right">2</td></tr>
      #|</tbody>
      #|</table>
      #|
    ),
  )
}

///|
test "render code block without language" {
  inspect(
    render_markdown("```\nplain <b>\n```"),
    content=(
      #|<figure class="mp-code">
      #|<pre><code>plain &lt;b&gt;
      #|</code></pre>
      #|</figure>
      #|
    ),
  )
}

///|
test "render code block with title attribute" {
  inspect(
    render_markdown("```moonbit title=\"hello.mbt\"\nlet x = 1\n```"),
    content=(
      #|<figure class="mp-code" data-lang="moonbit">
      #|<figcaption class="mp-code-head"><span class="mp-code-title">hello.mbt</span></figcaption>
      #|<pre><code class="language-moonbit"><span class="mp-tok-keyword">let</span> x = <span class="mp-tok-number">1</span>
      #|</code></pre>
      #|</figure>
      #|
    ),
  )
}

///|
test "render strikethrough and autolinks" {
  inspect(render_inline("~~gone~~ kept"), content="<del>gone</del> kept")
  inspect(
    render_inline("see <https://a.dev> now"),
    content="see <a href=\"https://a.dev\" rel=\"noopener noreferrer\" target=\"_blank\">https://a.dev</a> now",
  )
  inspect(
    render_inline("mail <me@a.dev> now"),
    content="mail <a href=\"mailto:me@a.dev\">me@a.dev</a> now",
  )
  inspect(render_inline("a <tag> b"), content="a &lt;tag&gt; b")
}

///|
test "render task list items" {
  inspect(
    render_markdown("- [x] done\n- [ ] todo\n- plain"),
    content=(
      #|<ul>
      #|  <li class="mp-task"><input type="checkbox" disabled checked> done</li>
      #|  <li class="mp-task"><input type="checkbox" disabled> todo</li>
      #|  <li>plain</li>
      #|</ul>
      #|
    ),
  )
}

///|
test "render footnotes with backlinks" {
  inspect(
    render_markdown("Text[^1] here.\n\n[^1]: The *note*."),
    content=(
      #|<p>Text<sup class="mp-fn-ref" id="fnref-1"><a href="#fn-1">1</a></sup> here.</p>
      #|<section class="mp-footnotes">
      #|<hr>
      #|<ol>
      #|  <li id="fn-1">The <em>note</em>. <a class="mp-fn-back" href="#fnref-1" aria-label="Back to content">↩</a></li>
      #|</ol>
      #|</section>
      #|
    ),
  )
}

///|
test "render reference links" {
  inspect(
    render_markdown("See [the docs][site].\n\n[site]: https://example.com"),
    content=(
      #|<p>See <a href="https://example.com" rel="noopener noreferrer" target="_blank">the docs</a>.</p>
      #|
    ),
  )
  inspect(
    render_markdown("See [MoonBit][].\n\n[MoonBit]: https://moonbitlang.com"),
    content=(
      #|<p>See <a href="https://moonbitlang.com" rel="noopener noreferrer" target="_blank">MoonBit</a>.</p>
      #|
    ),
  )
}

///|
test "slugify normalizes heading ids" {
  inspect(slugify("Getting Started!"), content="getting-started")
  inspect(slugify("  Multi   Word  "), content="multi-word")
  inspect(slugify("中文标题"), content="中文标题")
}

///|
test "paragraphs are separated by blank lines" {
  inspect(
    render_markdown("first line\nsame paragraph\n\nsecond"),
    content=(
      #|<p>first line same paragraph</p>
      #|<p>second</p>
      #|
    ),
  )
}

///|
test "render admonition with default title" {
  inspect(
    render_markdown("::: tip\nUse the config file.\n:::"),
    content=(
      #|<aside class="mp-admonition mp-admonition-tip">
      #|<p class="mp-admonition-title">TIP</p>
      #|<p>Use the config file.</p>
      #|</aside>
      #|
    ),
  )
}

///|
test "render admonition with custom title and nested markdown" {
  inspect(
    render_markdown("::: warning 注意\n**不要**这样做。\n:::"),
    content=(
      #|<aside class="mp-admonition mp-admonition-warning">
      #|<p class="mp-admonition-title">注意</p>
      #|<p><strong>不要</strong>这样做。</p>
      #|</aside>
      #|
    ),
  )
}

///|
test "admonition keeps fenced code and ignores unknown types" {
  let html = render_markdown(
    "::: danger\n```\n:::\n```\nstill inside\n:::\n\nafter",
  )
  inspect(html.find("mp-admonition-danger") is Some(_), content="true")
  inspect(html.find("<p>still inside</p>") is Some(_), content="true")
  inspect(html.find("<p>after</p>") is Some(_), content="true")
  inspect(
    render_markdown("::: custom\ntext\n:::").find("mp-admonition") is Some(_),
    content="false",
  )
}
