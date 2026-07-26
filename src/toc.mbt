///|
/// A single entry of the on-page table of contents.
pub(all) struct TocEntry {
  level : Int
  title : String
  id : String
}

///|
/// Collects the second and third level headings of a Markdown document.
/// Headings inside fenced code blocks are ignored, and the generated ids match
/// the anchors emitted by `render_markdown`.
pub fn collect_headings(markdown : String) -> Array[TocEntry] {
  let entries : Array[TocEntry] = []
  let lines = lines_of(markdown)
  let mut fenced = false
  let mut i = 0
  while i < lines.length() {
    let text = lines[i].trim().to_owned()
    i = i + 1
    if text.has_prefix("```") {
      fenced = !fenced
      continue
    }
    if fenced {
      continue
    }
    let level = heading_level(text)
    if level < 2 || level > 3 {
      continue
    }
    let content = plain_text(text[level + 1:].trim().to_owned())
    let id = slugify(content)
    if id != "" {
      entries.push({ level, title: content, id })
    }
  }
  entries
}

///|
/// Renders the on-page table of contents. Documents with fewer than two
/// headings return an empty string so short pages stay uncluttered.
pub fn render_toc(entries : Array[TocEntry], lang : String) -> String {
  if entries.length() < 2 {
    return ""
  }
  let label = if lang == "zh" { "本页目录" } else { "On this page" }
  let out = StringBuilder::new()
  out.write_string(
    "<nav class=\"mp-toc\" aria-label=\"" + escape_html(label) + "\">\n",
  )
  out.write_string(
    "  <p class=\"mp-toc-title\">" + escape_html(label) + "</p>\n",
  )
  out.write_string("  <ul>\n")
  for entry in entries {
    out.write_string(
      "    <li class=\"mp-toc-l" +
      entry.level.to_string() +
      "\"><a href=\"#" +
      escape_html(entry.id) +
      "\">" +
      escape_html(entry.title) +
      "</a></li>\n",
    )
  }
  out.write_string("  </ul>\n</nav>\n")
  out.to_string()
}

///|
/// Convenience wrapper that builds the table of contents straight from a
/// Markdown document.
pub fn render_toc_for_markdown(markdown : String, lang : String) -> String {
  render_toc(collect_headings(markdown), lang)
}
