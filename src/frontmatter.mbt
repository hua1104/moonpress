///|
pub fn has_front_matter(input : String) -> Bool {
  input.length() >= 4 && input[:3] == "---"
}

///|
pub fn strip_front_matter(input : String) -> String {
  if has_front_matter(input) {
    let marker = "\n---\n"
    match input.find(marker) {
      Some(index) => input[index + marker.length():].to_owned()
      None => input
    }
  } else {
    input
  }
}

///|
pub fn read_title(input : String) -> String {
  let title = read_front_matter_value(input, "title")
  if title != "" {
    title
  } else {
    let body = strip_front_matter(input)
    read_first_heading(body)
  }
}

///|
pub fn read_description(input : String) -> String {
  read_front_matter_value(input, "description")
}

///|
pub fn read_draft(input : String) -> Bool {
  read_front_matter_value(input, "draft") == "true"
}

///|
pub fn read_order(input : String) -> Int {
  parse_non_negative_int(read_front_matter_value(input, "order"))
}

///|
pub fn read_lang(input : String) -> String {
  let lang = read_front_matter_value(input, "lang")
  if lang == "" {
    "en"
  } else {
    lang
  }
}

///|
fn read_first_heading(input : String) -> String {
  let lines = input.split("\n")
  for line in lines {
    let text = line.to_owned()
    if text.has_prefix("# ") {
      return text[2:].trim().to_owned()
    }
  }
  ""
}

///|
fn read_front_matter_value(input : String, key : String) -> String {
  if !has_front_matter(input) {
    return ""
  }
  let lines = input.split("\n")
  let mut in_block = false
  let prefix = key + ":"
  for line in lines {
    let text = line.trim().to_owned()
    if text == "---" {
      if in_block {
        return ""
      } else {
        in_block = true
      }
    } else if in_block && text.has_prefix(prefix) {
      return clean_value(text[prefix.length():].to_owned())
    }
  }
  ""
}

///|
fn clean_value(value : String) -> String {
  let text = value.trim().to_owned()
  if text.length() >= 2 && text.has_prefix("\"") && text.has_suffix("\"") {
    text[1:text.length() - 1].to_owned()
  } else {
    text
  }
}

///|
fn parse_non_negative_int(value : String) -> Int {
  let text = value.trim()
  let mut result = 0
  for ch in text {
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - '0'.to_int())
    } else {
      return 0
    }
  }
  result
}
