///|
/// Parses the minimal flat JSON object subset used by `moonpress.json`.
/// Recognised value types are strings, integers, and booleans.
pub fn parse_config_json(input : String, fallback : SiteConfig) -> SiteConfig {
  let fields = parse_flat_json_object(input)
  {
    title: config_field(fields, "title", fallback.title),
    description: config_field(fields, "description", fallback.description),
    base_url: config_field(fields, "base_url", fallback.base_url),
    author: config_field(fields, "author", fallback.author),
    site_url: config_field(fields, "site_url", fallback.site_url),
    default_lang: config_field(fields, "default_lang", fallback.default_lang),
  }
}

///|
fn config_field(
  fields : Map[String, String],
  key : String,
  fallback : String,
) -> String {
  match fields.get(key) {
    Some(value) => value
    None => fallback
  }
}

///|
fn parse_flat_json_object(input : String) -> Map[String, String] {
  let fields : Map[String, String] = Map([])
  let chars = chars_of(input)
  let length = chars.length()
  let mut i = 0
  while i < length && chars[i] != '{' {
    i = i + 1
  }
  i = i + 1
  while i < length {
    while i < length && is_json_space(chars[i]) {
      i = i + 1
    }
    if i >= length || chars[i] == '}' {
      break
    }
    if chars[i] == ',' {
      i = i + 1
      continue
    }
    if chars[i] != '"' {
      break
    }
    let key_end = scan_json_string(chars, i + 1, length)
    if key_end < 0 {
      break
    }
    let key = decode_json_string(chars, i + 1, key_end)
    i = key_end + 1
    while i < length && is_json_space(chars[i]) {
      i = i + 1
    }
    if i >= length || chars[i] != ':' {
      break
    }
    i = i + 1
    while i < length && is_json_space(chars[i]) {
      i = i + 1
    }
    if i >= length {
      break
    }
    if chars[i] == '"' {
      let value_end = scan_json_string(chars, i + 1, length)
      if value_end < 0 {
        break
      }
      fields[key] = decode_json_string(chars, i + 1, value_end)
      i = value_end + 1
    } else {
      let value_end = scan_json_scalar(chars, i, length)
      fields[key] = chars_to_string(chars, i, value_end).trim().to_owned()
      i = value_end
    }
  }
  fields
}

///|
fn is_json_space(ch : Char) -> Bool {
  ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t'
}

///|
fn scan_json_string(chars : Array[Char], from : Int, length : Int) -> Int {
  let mut i = from
  while i < length {
    if chars[i] == '\\' {
      i = i + 2
    } else if chars[i] == '"' {
      return i
    } else {
      i = i + 1
    }
  }
  -1
}

///|
fn scan_json_scalar(chars : Array[Char], from : Int, length : Int) -> Int {
  let mut i = from
  while i < length && chars[i] != ',' && chars[i] != '}' {
    i = i + 1
  }
  i
}

///|
fn decode_json_string(chars : Array[Char], from : Int, to : Int) -> String {
  let out = StringBuilder::new()
  let mut i = from
  while i < to {
    if chars[i] == '\\' && i + 1 < to {
      let escaped = chars[i + 1]
      if escaped == 'n' {
        out.write_char('\n')
      } else if escaped == 'r' {
        out.write_char('\r')
      } else if escaped == 't' {
        out.write_char('\t')
      } else {
        out.write_char(escaped)
      }
      i = i + 2
    } else {
      out.write_char(chars[i])
      i = i + 1
    }
  }
  out.to_string()
}
