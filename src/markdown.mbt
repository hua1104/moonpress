///|
pub fn escape_html(input : String) -> String {
  input
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
}

///|
pub fn render_inline(input : String) -> String {
  render_links(render_inline_code(input))
}

///|
fn render_inline_code(input : String) -> String {
  match input.find("`") {
    Some(start) => {
      let rest = input[start + 1:]
      match rest.find("`") {
        Some(end_rel) => {
          let end = start + 1 + end_rel
          escape_html(input[:start].to_owned()) +
          "<code>" +
          escape_html(input[start + 1:end].to_owned()) +
          "</code>" +
          render_inline_code(input[end + 1:].to_owned())
        }
        None => escape_html(input)
      }
    }
    None => escape_html(input)
  }
}

///|
fn render_links(input : String) -> String {
  match input.find("[") {
    Some(start) => {
      let tail = input[start + 1:]
      match tail.find("](") {
        Some(close_rel) => {
          let close = start + 1 + close_rel
          let url_tail = input[close + 2:]
          match url_tail.find(")") {
            Some(end_rel) => {
              let end = close + 2 + end_rel
              input[:start].to_owned() +
              "<a href=\"" +
              escape_html(input[close + 2:end].to_owned()) +
              "\">" +
              input[start + 1:close].to_owned() +
              "</a>" +
              render_links(input[end + 1:].to_owned())
            }
            None => input
          }
        }
        None => input
      }
    }
    None => input
  }
}

///|
pub fn render_markdown(input : String) -> String {
  let mut html = ""
  let lines = input.split("\n")
  let mut in_paragraph = false
  let mut in_code = false
  let mut in_list = false
  for line in lines {
    let text = line.trim().to_owned()
    if text.has_prefix("```") {
      if in_paragraph {
        html = html + "</p>\n"
        in_paragraph = false
      }
      if in_list {
        html = html + "</ul>\n"
        in_list = false
      }
      if in_code {
        html = html + "</code></pre>\n"
        in_code = false
      } else {
        html = html + "<pre><code>"
        in_code = true
      }
    } else if in_code {
      html = html + escape_html(line.to_owned()) + "\n"
    } else if text == "" {
      if in_paragraph {
        html = html + "</p>\n"
        in_paragraph = false
      }
      if in_list {
        html = html + "</ul>\n"
        in_list = false
      }
    } else if text.has_prefix("# ") {
      if in_paragraph {
        html = html + "</p>\n"
        in_paragraph = false
      }
      if in_list {
        html = html + "</ul>\n"
        in_list = false
      }
      html = html + "<h1>" + render_inline(text[2:].to_owned()) + "</h1>\n"
    } else if text.has_prefix("## ") {
      if in_paragraph {
        html = html + "</p>\n"
        in_paragraph = false
      }
      if in_list {
        html = html + "</ul>\n"
        in_list = false
      }
      html = html + "<h2>" + render_inline(text[3:].to_owned()) + "</h2>\n"
    } else if text.has_prefix("### ") {
      if in_paragraph {
        html = html + "</p>\n"
        in_paragraph = false
      }
      if in_list {
        html = html + "</ul>\n"
        in_list = false
      }
      html = html + "<h3>" + render_inline(text[4:].to_owned()) + "</h3>\n"
    } else if text.has_prefix("- ") {
      if in_paragraph {
        html = html + "</p>\n"
        in_paragraph = false
      }
      if !in_list {
        html = html + "<ul>\n"
        in_list = true
      }
      html = html + "  <li>" + render_inline(text[2:].to_owned()) + "</li>\n"
    } else {
      if in_list {
        html = html + "</ul>\n"
        in_list = false
      }
      if !in_paragraph {
        html = html + "<p>"
        in_paragraph = true
      } else {
        html = html + " "
      }
      html = html + render_inline(text)
    }
  }
  if in_paragraph {
    html = html + "</p>\n"
  }
  if in_code {
    html = html + "</code></pre>\n"
  }
  if in_list {
    html = html + "</ul>\n"
  }
  html
}
