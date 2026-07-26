///|
pub fn escape_html(input : String) -> String {
  input
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
}

///|
fn chars_of(input : String) -> Array[Char] {
  let chars : Array[Char] = []
  for ch in input {
    chars.push(ch)
  }
  chars
}

///|
fn chars_to_string(chars : Array[Char], from : Int, to : Int) -> String {
  let out = StringBuilder::new()
  for i = from; i < to; i = i + 1 {
    out.write_char(chars[i])
  }
  out.to_string()
}

///|
fn escape_char_into(out : StringBuilder, ch : Char) -> Unit {
  if ch == '&' {
    out.write_string("&amp;")
  } else if ch == '<' {
    out.write_string("&lt;")
  } else if ch == '>' {
    out.write_string("&gt;")
  } else if ch == '"' {
    out.write_string("&quot;")
  } else {
    out.write_char(ch)
  }
}

///|
fn find_char(chars : Array[Char], from : Int, to : Int, needle : Char) -> Int {
  for i = from; i < to; i = i + 1 {
    if chars[i] == needle {
      return i
    }
  }
  -1
}

///|
fn find_pair(
  chars : Array[Char],
  from : Int,
  to : Int,
  first : Char,
  second : Char,
) -> Int {
  for i = from; i + 1 < to; i = i + 1 {
    if chars[i] == first && chars[i + 1] == second {
      return i
    }
  }
  -1
}

///|
fn is_ascii_alphanumeric(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') ||
  (ch >= 'A' && ch <= 'Z') ||
  (ch >= '0' && ch <= '9')
}

///|
pub fn render_inline(input : String) -> String {
  let chars = chars_of(input)
  render_inline_range(chars, 0, chars.length())
}

///|
fn render_inline_range(chars : Array[Char], start : Int, end : Int) -> String {
  let out = StringBuilder::new()
  let mut i = start
  while i < end {
    let ch = chars[i]
    let next = if ch == '\\' {
      render_escape(chars, i, end, out)
    } else if ch == '`' {
      render_code_span(chars, i, end, out)
    } else if ch == '!' {
      render_image(chars, i, end, out)
    } else if ch == '[' {
      if i + 1 < end && chars[i + 1] == '^' {
        render_footnote_ref(chars, i, end, out)
      } else {
        render_link(chars, i, end, out)
      }
    } else if ch == '<' {
      render_autolink(chars, i, end, out)
    } else if ch == '~' {
      render_strikethrough(chars, i, end, out)
    } else if ch == '*' || ch == '_' {
      render_emphasis(chars, i, start, end, out)
    } else {
      -1
    }
    if next < 0 {
      escape_char_into(out, ch)
      i = i + 1
    } else {
      i = next
    }
  }
  out.to_string()
}

///|
fn render_escape(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  if i + 1 >= end {
    return -1
  }
  escape_char_into(out, chars[i + 1])
  i + 2
}

///|
fn render_code_span(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let close = find_char(chars, i + 1, end, '`')
  if close < 0 {
    return -1
  }
  out.write_string("<code>")
  out.write_string(escape_html(chars_to_string(chars, i + 1, close)))
  out.write_string("</code>")
  close + 1
}

///|
fn render_image(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  if i + 1 >= end || chars[i + 1] != '[' {
    return -1
  }
  let close = find_char(chars, i + 2, end, ']')
  if close < 0 || close + 1 >= end || chars[close + 1] != '(' {
    return -1
  }
  let paren = find_char(chars, close + 2, end, ')')
  if paren < 0 {
    return -1
  }
  let alt = chars_to_string(chars, i + 2, close)
  let url = chars_to_string(chars, close + 2, paren)
  out.write_string("<img src=\"")
  out.write_string(escape_html(url))
  out.write_string("\" alt=\"")
  out.write_string(escape_html(alt))
  out.write_string("\" loading=\"lazy\">")
  paren + 1
}

///|
fn render_link(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let close = find_char(chars, i + 1, end, ']')
  if close < 0 || close + 1 >= end || chars[close + 1] != '(' {
    return -1
  }
  let paren = find_char(chars, close + 2, end, ')')
  if paren < 0 {
    return -1
  }
  let url = chars_to_string(chars, close + 2, paren)
  out.write_string("<a href=\"")
  out.write_string(escape_html(url))
  out.write_string("\"")
  if is_external_url(url) {
    out.write_string(" rel=\"noopener noreferrer\" target=\"_blank\"")
  }
  out.write_string(">")
  out.write_string(render_inline_range(chars, i + 1, close))
  out.write_string("</a>")
  paren + 1
}

///|
fn is_external_url(url : String) -> Bool {
  url.has_prefix("http://") || url.has_prefix("https://")
}

///|
/// Renders `<https://example.com>` and `<user@example.com>` autolinks.
/// Anything else keeps the previous behaviour of escaping the `<` character.
fn render_autolink(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let close = find_char(chars, i + 1, end, '>')
  if close < 0 || close == i + 1 {
    return -1
  }
  let value = chars_to_string(chars, i + 1, close)
  if is_external_url(value) {
    out.write_string("<a href=\"")
    out.write_string(escape_html(value))
    out.write_string("\" rel=\"noopener noreferrer\" target=\"_blank\">")
    out.write_string(escape_html(value))
    out.write_string("</a>")
    close + 1
  } else if is_email_address(value) {
    out.write_string("<a href=\"mailto:")
    out.write_string(escape_html(value))
    out.write_string("\">")
    out.write_string(escape_html(value))
    out.write_string("</a>")
    close + 1
  } else {
    -1
  }
}

///|
fn is_email_address(value : String) -> Bool {
  let chars = chars_of(value)
  let mut at = -1
  let mut dot_after_at = false
  for index, ch in chars {
    if ch == ' ' || ch == '\t' || ch == '<' || ch == '>' {
      return false
    }
    if ch == '@' {
      if at >= 0 || index == 0 {
        return false
      }
      at = index
    } else if ch == '.' &&
      at >= 0 &&
      index > at + 1 &&
      index + 1 < chars.length() {
      dot_after_at = true
    }
  }
  at > 0 && dot_after_at
}

///|
fn render_strikethrough(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  if i + 1 >= end || chars[i + 1] != '~' {
    return -1
  }
  let close = find_pair(chars, i + 2, end, '~', '~')
  if close <= i + 2 {
    return -1
  }
  out.write_string("<del>")
  out.write_string(render_inline_range(chars, i + 2, close))
  out.write_string("</del>")
  close + 2
}

///|
fn render_footnote_ref(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let close = find_char(chars, i + 2, end, ']')
  if close < 0 || close == i + 2 {
    return -1
  }
  let label = chars_to_string(chars, i + 2, close)
  let id = escape_html(slugify(label))
  if id == "" {
    return -1
  }
  out.write_string("<sup class=\"mp-fn-ref\" id=\"fnref-")
  out.write_string(id)
  out.write_string("\"><a href=\"#fn-")
  out.write_string(id)
  out.write_string("\">")
  out.write_string(escape_html(label))
  out.write_string("</a></sup>")
  close + 1
}

///|
fn render_emphasis(
  chars : Array[Char],
  i : Int,
  start : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let marker = chars[i]
  if marker == '_' && i > start && is_ascii_alphanumeric(chars[i - 1]) {
    return -1
  }
  if i + 1 < end && chars[i + 1] == marker {
    let close = find_pair(chars, i + 2, end, marker, marker)
    if close > i + 2 {
      out.write_string("<strong>")
      out.write_string(render_inline_range(chars, i + 2, close))
      out.write_string("</strong>")
      return close + 2
    }
    return -1
  }
  let close = find_char(chars, i + 1, end, marker)
  if close <= i + 1 {
    return -1
  }
  out.write_string("<em>")
  out.write_string(render_inline_range(chars, i + 1, close))
  out.write_string("</em>")
  close + 1
}

///|
pub fn slugify(input : String) -> String {
  let out = StringBuilder::new()
  let mut pending_dash = false
  let mut started = false
  for ch in input.to_lower() {
    if is_ascii_alphanumeric(ch) || ch.to_int() > 127 {
      if pending_dash && started {
        out.write_char('-')
      }
      out.write_char(ch)
      pending_dash = false
      started = true
    } else {
      pending_dash = true
    }
  }
  out.to_string()
}

///|
fn plain_text(input : String) -> String {
  let out = StringBuilder::new()
  for ch in input {
    if ch != '`' && ch != '*' && ch != '_' && ch != '[' && ch != ']' {
      out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn lines_of(input : String) -> Array[String] {
  let lines : Array[String] = []
  for line in input.replace_all(old="\r\n", new="\n").split("\n") {
    lines.push(line.to_owned())
  }
  lines
}

///|
fn indent_width(line : String) -> Int {
  let mut width = 0
  for ch in line {
    if ch == ' ' {
      width = width + 1
    } else if ch == '\t' {
      width = width + 4
    } else {
      break
    }
  }
  width
}

///|
fn dedent(line : String, width : Int) -> String {
  let mut removed = 0
  let mut index = 0
  let chars = chars_of(line)
  while index < chars.length() && removed < width {
    if chars[index] == ' ' {
      removed = removed + 1
    } else if chars[index] == '\t' {
      removed = removed + 4
    } else {
      break
    }
    index = index + 1
  }
  chars_to_string(chars, index, chars.length())
}

///|
fn heading_level(text : String) -> Int {
  let mut level = 0
  for ch in text {
    if ch == '#' {
      level = level + 1
    } else {
      break
    }
  }
  if level >= 1 && level <= 6 && text.has_prefix("#".repeat(level) + " ") {
    level
  } else {
    0
  }
}

///|
fn is_thematic_break(text : String) -> Bool {
  if text.length() < 3 {
    return false
  }
  let first = chars_of(text)[0]
  if first != '-' && first != '*' && first != '_' {
    return false
  }
  for ch in text {
    if ch != first {
      return false
    }
  }
  true
}

///|
fn unordered_marker_width(text : String) -> Int {
  if text.has_prefix("- ") || text.has_prefix("* ") || text.has_prefix("+ ") {
    2
  } else {
    0
  }
}

///|
fn ordered_marker_width(text : String) -> Int {
  let chars = chars_of(text)
  let mut index = 0
  while index < chars.length() && chars[index] >= '0' && chars[index] <= '9' {
    index = index + 1
  }
  if index == 0 || index + 1 >= chars.length() {
    return 0
  }
  if chars[index] == '.' && chars[index + 1] == ' ' {
    index + 2
  } else {
    0
  }
}

///|
/// Returns `0` for a plain list item, `1` for an unchecked task item, and `2`
/// for a checked one.
fn task_marker_state(content : String) -> Int {
  if content.has_prefix("[ ] ") {
    1
  } else if content.has_prefix("[x] ") || content.has_prefix("[X] ") {
    2
  } else {
    0
  }
}

///|
fn is_blockquote(text : String) -> Bool {
  text == ">" || text.has_prefix("> ")
}

///|
fn is_block_start(text : String) -> Bool {
  text == "" ||
  text.has_prefix("```") ||
  heading_level(text) > 0 ||
  is_thematic_break(text) ||
  is_blockquote(text) ||
  unordered_marker_width(text) > 0 ||
  ordered_marker_width(text) > 0 ||
  admonition_kind(text) != ""
}

///|
/// Returns the admonition type for a `::: tip` style container opener, or an
/// empty string when the line does not open a known container.
fn admonition_kind(text : String) -> String {
  if !text.has_prefix(":::") {
    return ""
  }
  let kind = first_token(text[3:].trim().to_owned()).to_lower()
  if kind == "tip" ||
    kind == "note" ||
    kind == "info" ||
    kind == "warning" ||
    kind == "danger" ||
    kind == "caution" {
    kind
  } else {
    ""
  }
}

///|
/// The container title: the text after the type on the opening line, or the
/// uppercased type when the author did not provide one.
fn admonition_title(opener : String, kind : String) -> String {
  let rest = opener[3:].trim().to_owned()
  let custom = rest[kind.length():].trim().to_owned()
  if custom == "" {
    kind.to_upper()
  } else {
    custom
  }
}

///|
fn split_row(text : String) -> Array[String] {
  let cells : Array[String] = []
  let trimmed = if text.has_prefix("|") { text[1:].to_owned() } else { text }
  let body = if trimmed.has_suffix("|") {
    trimmed[:trimmed.length() - 1].to_owned()
  } else {
    trimmed
  }
  for cell in body.split("|") {
    cells.push(cell.trim().to_owned())
  }
  cells
}

///|
fn is_delimiter_row(text : String) -> Bool {
  if !text.has_prefix("|") {
    return false
  }
  let cells = split_row(text)
  if cells.length() == 0 {
    return false
  }
  for cell in cells {
    if cell == "" {
      return false
    }
    let mut has_dash = false
    for ch in cell {
      if ch == '-' {
        has_dash = true
      } else if ch != ':' {
        return false
      }
    }
    if !has_dash {
      return false
    }
  }
  true
}

///|
fn cell_alignment(spec : String) -> String {
  let left = spec.has_prefix(":")
  let right = spec.has_suffix(":")
  if left && right {
    " style=\"text-align:center\""
  } else if right {
    " style=\"text-align:right\""
  } else if left {
    " style=\"text-align:left\""
  } else {
    ""
  }
}

///|
/// Renders a full Markdown document. Link and footnote definitions are removed
/// up front, reference links are expanded into inline links, and collected
/// footnotes are appended as a trailing section.
pub fn render_markdown(input : String) -> String {
  let link_ids : Array[String] = []
  let link_urls : Array[String] = []
  let note_ids : Array[String] = []
  let note_bodies : Array[String] = []
  let stripped = strip_definitions(
    lines_of(input),
    link_ids,
    link_urls,
    note_ids,
    note_bodies,
  )
  let content = expand_reference_links_in_lines(stripped, link_ids, link_urls)
  let out = StringBuilder::new()
  render_blocks(content, out)
  if note_ids.length() > 0 {
    render_footnotes(note_ids, note_bodies, out)
  }
  out.to_string()
}

///|
/// Renders nested Markdown such as list item bodies and block quotes.
/// Definitions are resolved by the enclosing document, so this entry point only
/// walks blocks.
fn render_fragment(input : String) -> String {
  let out = StringBuilder::new()
  render_blocks(lines_of(input), out)
  out.to_string()
}

///|
fn first_token(input : String) -> String {
  let text = input.trim().to_owned()
  let mut token = ""
  for part in text.split(" ") {
    token = part.to_owned()
    break
  }
  if token.length() >= 2 && token.has_prefix("<") && token.has_suffix(">") {
    token[1:token.length() - 1].to_owned()
  } else {
    token
  }
}

///|
/// Removes `[id]: url` link definitions and `[^id]: text` footnote definitions
/// from the document, collecting them into the supplied accumulators.
fn strip_definitions(
  lines : Array[String],
  link_ids : Array[String],
  link_urls : Array[String],
  note_ids : Array[String],
  note_bodies : Array[String],
) -> Array[String] {
  let kept : Array[String] = []
  let mut fenced = false
  let mut i = 0
  while i < lines.length() {
    let raw = lines[i]
    let text = raw.trim().to_owned()
    if text.has_prefix("```") {
      fenced = !fenced
      kept.push(raw)
      i = i + 1
      continue
    }
    if fenced || !text.has_prefix("[") {
      kept.push(raw)
      i = i + 1
      continue
    }
    let at = match text.find("]:") {
      Some(index) => index
      None => -1
    }
    if at >= 1 {
      let label = text[1:at].to_owned()
      let value = text[at + 2:].trim().to_owned()
      if label.has_prefix("^") && label.length() > 1 {
        let body = StringBuilder::new()
        body.write_string(value)
        let mut j = i + 1
        while j < lines.length() &&
              indent_width(lines[j]) >= 2 &&
              lines[j].trim().to_owned() != "" {
          body.write_string(" ")
          body.write_string(lines[j].trim().to_owned())
          j = j + 1
        }
        note_ids.push(label[1:].to_owned())
        note_bodies.push(body.to_string().trim().to_owned())
        i = j
        continue
      }
      if label != "" && value != "" {
        link_ids.push(label)
        link_urls.push(first_token(value))
        i = i + 1
        continue
      }
    }
    kept.push(raw)
    i = i + 1
  }
  kept
}

///|
fn expand_reference_links_in_lines(
  lines : Array[String],
  ids : Array[String],
  urls : Array[String],
) -> Array[String] {
  if ids.length() == 0 {
    return lines
  }
  let out : Array[String] = []
  let mut fenced = false
  for line in lines {
    let text = line.trim().to_owned()
    if text.has_prefix("```") {
      fenced = !fenced
      out.push(line)
    } else if fenced {
      out.push(line)
    } else {
      out.push(expand_reference_links(line, ids, urls))
    }
  }
  out
}

///|
/// Rewrites `[text][id]` and `[id][]` into inline `[text](url)` links so the
/// existing inline renderer keeps a single code path for links.
fn expand_reference_links(
  line : String,
  ids : Array[String],
  urls : Array[String],
) -> String {
  let chars = chars_of(line)
  let end = chars.length()
  let out = StringBuilder::new()
  let mut i = 0
  while i < end {
    if chars[i] == '[' && !(i + 1 < end && chars[i + 1] == '^') {
      let close = find_char(chars, i + 1, end, ']')
      if close > 0 && close + 1 < end && chars[close + 1] == '[' {
        let second = find_char(chars, close + 2, end, ']')
        if second > 0 {
          let text = chars_to_string(chars, i + 1, close)
          let raw_id = chars_to_string(chars, close + 2, second)
          let key = if raw_id == "" { text } else { raw_id }
          let url = lookup_definition(ids, urls, key)
          if url != "" {
            out.write_string("[")
            out.write_string(text)
            out.write_string("](")
            out.write_string(url)
            out.write_string(")")
            i = second + 1
            continue
          }
        }
      }
    }
    out.write_char(chars[i])
    i = i + 1
  }
  out.to_string()
}

///|
fn lookup_definition(
  ids : Array[String],
  urls : Array[String],
  key : String,
) -> String {
  let needle = key.trim().to_owned().to_lower()
  for index, id in ids {
    if id.trim().to_owned().to_lower() == needle {
      return urls[index]
    }
  }
  ""
}

///|
fn render_footnotes(
  ids : Array[String],
  bodies : Array[String],
  out : StringBuilder,
) -> Unit {
  out.write_string("<section class=\"mp-footnotes\">\n<hr>\n<ol>\n")
  for index, id in ids {
    let slug = escape_html(slugify(id))
    out.write_string("  <li id=\"fn-" + slug + "\">")
    out.write_string(render_inline(bodies[index]))
    out.write_string(
      " <a class=\"mp-fn-back\" href=\"#fnref-" +
      slug +
      "\" aria-label=\"Back to content\">\u{21a9}</a></li>\n",
    )
  }
  out.write_string("</ol>\n</section>\n")
}

///|
fn render_blocks(lines : Array[String], out : StringBuilder) -> Unit {
  let mut i = 0
  while i < lines.length() {
    let text = lines[i].trim().to_owned()
    if text == "" {
      i = i + 1
    } else if text.has_prefix("```") {
      i = render_code_block(lines, i, out)
    } else if heading_level(text) > 0 {
      render_heading(text, out)
      i = i + 1
    } else if is_thematic_break(text) {
      out.write_string("<hr>\n")
      i = i + 1
    } else if is_blockquote(text) {
      i = render_blockquote(lines, i, out)
    } else if admonition_kind(text) != "" {
      i = render_admonition(lines, i, out)
    } else if unordered_marker_width(text) > 0 || ordered_marker_width(text) > 0 {
      i = render_list(lines, i, out)
    } else if is_delimiter_row_at(lines, i + 1) && text.has_prefix("|") {
      i = render_table(lines, i, out)
    } else {
      i = render_paragraph(lines, i, out)
    }
  }
}

///|
fn is_delimiter_row_at(lines : Array[String], index : Int) -> Bool {
  index < lines.length() && is_delimiter_row(lines[index].trim().to_owned())
}

///|
fn render_code_block(
  lines : Array[String],
  start : Int,
  out : StringBuilder,
) -> Int {
  let fence = lines[start].trim().to_owned()
  let info = fence[3:].trim().to_owned()
  let language = first_token(info)
  let title = info_attribute(info, "title")
  let body = StringBuilder::new()
  let mut i = start + 1
  while i < lines.length() && !lines[i].trim().to_owned().has_prefix("```") {
    body.write_string(lines[i])
    body.write_string("\n")
    i = i + 1
  }
  let slug = escape_html(slugify(language))
  out.write_string("<figure class=\"mp-code\"")
  if language != "" {
    out.write_string(" data-lang=\"" + slug + "\"")
  }
  out.write_string(">\n")
  if language != "" || title != "" {
    out.write_string(
      "<figcaption class=\"mp-code-head\"><span class=\"mp-code-title\">",
    )
    out.write_string(escape_html(if title == "" { language } else { title }))
    out.write_string("</span></figcaption>\n")
  }
  out.write_string("<pre><code")
  if language != "" {
    out.write_string(" class=\"language-" + slug + "\"")
  }
  out.write_string(">")
  out.write_string(highlight_code(language, body.to_string()))
  out.write_string("</code></pre>\n</figure>\n")
  if i < lines.length() {
    i + 1
  } else {
    i
  }
}

///|
/// Reads a `key="value"` or `key=value` attribute from a fence info string.
fn info_attribute(info : String, key : String) -> String {
  let needle = key + "="
  match info.find(needle) {
    Some(at) => {
      let rest = info[at + needle.length():].to_owned()
      if rest.has_prefix("\"") {
        match rest[1:].to_owned().find("\"") {
          Some(close) => rest[1:close + 1].to_owned()
          None => ""
        }
      } else {
        first_token(rest)
      }
    }
    None => ""
  }
}

///|
fn render_heading(text : String, out : StringBuilder) -> Unit {
  let level = heading_level(text)
  let content = text[level + 1:].trim().to_owned()
  let tag = "h" + level.to_string()
  let id = slugify(plain_text(content))
  out.write_string("<" + tag)
  if id != "" {
    out.write_string(" id=\"" + escape_html(id) + "\"")
  }
  out.write_string(">")
  out.write_string(render_inline(content))
  if id != "" {
    out.write_string(
      "<a class=\"mp-anchor\" href=\"#" +
      escape_html(id) +
      "\" aria-label=\"Permalink\">#</a>",
    )
  }
  out.write_string("</" + tag + ">\n")
}

///|
/// Renders a `::: tip` style container. The body is collected up to the
/// closing `:::` line (fenced code inside the container is skipped over, so a
/// `:::` inside a code sample does not close it) and rendered as nested
/// Markdown. An unterminated container runs to the end of the document, which
/// matches how unterminated code fences behave.
fn render_admonition(
  lines : Array[String],
  start : Int,
  out : StringBuilder,
) -> Int {
  let opener = lines[start].trim().to_owned()
  let kind = admonition_kind(opener)
  let title = admonition_title(opener, kind)
  let inner : Array[String] = []
  let mut fenced = false
  let mut i = start + 1
  while i < lines.length() {
    let text = lines[i].trim().to_owned()
    if text.has_prefix("```") {
      fenced = !fenced
    } else if !fenced && text == ":::" {
      i = i + 1
      break
    }
    inner.push(lines[i])
    i = i + 1
  }
  out.write_string(
    "<aside class=\"mp-admonition mp-admonition-" + kind + "\">\n",
  )
  out.write_string("<p class=\"mp-admonition-title\">")
  out.write_string(render_inline(title))
  out.write_string("</p>\n")
  out.write_string(render_fragment(inner.join("\n")))
  out.write_string("</aside>\n")
  i
}

///|
fn render_blockquote(
  lines : Array[String],
  start : Int,
  out : StringBuilder,
) -> Int {
  let inner : Array[String] = []
  let mut i = start
  while i < lines.length() && is_blockquote(lines[i].trim().to_owned()) {
    let text = lines[i].trim().to_owned()
    inner.push(if text == ">" { "" } else { text[2:].to_owned() })
    i = i + 1
  }
  out.write_string("<blockquote>\n")
  out.write_string(render_fragment(inner.join("\n")))
  out.write_string("</blockquote>\n")
  i
}

///|
fn render_list(lines : Array[String], start : Int, out : StringBuilder) -> Int {
  let base = indent_width(lines[start])
  let ordered = ordered_marker_width(lines[start].trim().to_owned()) > 0
  out.write_string(if ordered { "<ol>\n" } else { "<ul>\n" })
  let mut i = start
  while i < lines.length() {
    let raw = lines[i]
    let text = raw.trim().to_owned()
    if text == "" {
      if i + 1 < lines.length() && indent_width(lines[i + 1]) > base {
        i = i + 1
        continue
      }
      break
    }
    let indent = indent_width(raw)
    if indent != base {
      break
    }
    let marker = if ordered {
      ordered_marker_width(text)
    } else {
      unordered_marker_width(text)
    }
    if marker == 0 {
      break
    }
    let children : Array[String] = []
    let mut j = i + 1
    while j < lines.length() {
      let child = lines[j]
      if child.trim().to_owned() == "" {
        if j + 1 < lines.length() && indent_width(lines[j + 1]) > base {
          children.push("")
          j = j + 1
          continue
        }
        break
      }
      if indent_width(child) <= base {
        break
      }
      children.push(dedent(child, base + 2))
      j = j + 1
    }
    let content = text[marker:].to_owned()
    let task = task_marker_state(content)
    if task == 0 {
      out.write_string("  <li>")
      out.write_string(render_inline(content))
    } else {
      out.write_string(
        "  <li class=\"mp-task\"><input type=\"checkbox\" disabled",
      )
      if task == 2 {
        out.write_string(" checked")
      }
      out.write_string("> ")
      out.write_string(render_inline(content[4:].to_owned()))
    }
    if children.length() > 0 {
      out.write_string("\n")
      out.write_string(render_fragment(children.join("\n")))
    }
    out.write_string("</li>\n")
    i = j
  }
  out.write_string(if ordered { "</ol>\n" } else { "</ul>\n" })
  i
}

///|
fn render_table(lines : Array[String], start : Int, out : StringBuilder) -> Int {
  let headers = split_row(lines[start].trim().to_owned())
  let alignments = split_row(lines[start + 1].trim().to_owned())
  out.write_string("<table>\n<thead>\n<tr>")
  for index, header in headers {
    let align = if index < alignments.length() {
      cell_alignment(alignments[index])
    } else {
      ""
    }
    out.write_string("<th" + align + ">" + render_inline(header) + "</th>")
  }
  out.write_string("</tr>\n</thead>\n<tbody>\n")
  let mut i = start + 2
  while i < lines.length() {
    let text = lines[i].trim().to_owned()
    if !text.has_prefix("|") {
      break
    }
    let cells = split_row(text)
    out.write_string("<tr>")
    for index, cell in cells {
      let align = if index < alignments.length() {
        cell_alignment(alignments[index])
      } else {
        ""
      }
      out.write_string("<td" + align + ">" + render_inline(cell) + "</td>")
    }
    out.write_string("</tr>\n")
    i = i + 1
  }
  out.write_string("</tbody>\n</table>\n")
  i
}

///|
fn render_paragraph(
  lines : Array[String],
  start : Int,
  out : StringBuilder,
) -> Int {
  let parts : Array[String] = []
  let mut i = start
  while i < lines.length() {
    let text = lines[i].trim().to_owned()
    if is_block_start(text) && i > start {
      break
    }
    if text == "" {
      break
    }
    parts.push(render_inline(text))
    i = i + 1
  }
  out.write_string("<p>" + parts.join(" ") + "</p>\n")
  i
}
