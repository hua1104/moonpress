///|
/// Build-time syntax highlighting for fenced code blocks.
///
/// The tokenizer is deliberately small: it recognises line and block comments,
/// quoted strings, numbers, and a per-language keyword set. That is enough to
/// make documentation samples readable while keeping the generated site free of
/// any runtime highlighting dependency. Unknown languages fall back to plain
/// escaped text.
pub fn highlight_code(language : String, code : String) -> String {
  let id = highlight_language_id(language)
  if id == "" {
    return escape_html(code)
  }
  let keywords = language_keywords(id)
  let chars = chars_of(code)
  let end = chars.length()
  let out = StringBuilder::new()
  let mut i = 0
  while i < end {
    let ch = chars[i]
    let next = if is_line_comment_start(id, chars, i, end) {
      write_line_comment(chars, i, end, out)
    } else if is_block_comment_start(id, chars, i, end) {
      write_block_comment(chars, i, end, out)
    } else if is_string_quote(id, ch) {
      write_string_token(chars, i, end, out)
    } else if is_digit(ch) {
      write_number(chars, i, end, out)
    } else if is_word_start(ch) {
      write_word(chars, i, end, keywords, out)
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
/// Maps a fence info string to the internal highlighter identifier.
/// An empty result means "render this block without highlighting".
pub fn highlight_language_id(language : String) -> String {
  let name = language.to_lower()
  if name == "moonbit" || name == "mbt" {
    "moonbit"
  } else if name == "rust" || name == "rs" {
    "rust"
  } else if name == "js" ||
    name == "javascript" ||
    name == "mjs" ||
    name == "cjs" ||
    name == "jsx" {
    "javascript"
  } else if name == "ts" || name == "typescript" || name == "tsx" {
    "typescript"
  } else if name == "json" || name == "jsonc" {
    "json"
  } else if name == "bash" ||
    name == "sh" ||
    name == "shell" ||
    name == "zsh" ||
    name == "console" {
    "bash"
  } else if name == "python" || name == "py" {
    "python"
  } else if name == "toml" || name == "ini" {
    "toml"
  } else if name == "yaml" || name == "yml" {
    "yaml"
  } else {
    ""
  }
}

///|
fn language_keywords(id : String) -> Array[String] {
  if id == "moonbit" {
    [
      "fn", "let", "mut", "struct", "enum", "trait", "impl", "derive", "pub", "priv",
      "type", "typealias", "match", "if", "else", "while", "for", "in", "return",
      "break", "continue", "test", "as", "is", "guard", "loop", "try", "catch", "raise",
      "async", "extern", "const", "init", "main", "self", "true", "false",
    ]
  } else if id == "rust" {
    [
      "fn", "let", "mut", "struct", "enum", "trait", "impl", "pub", "crate", "use",
      "mod", "match", "if", "else", "while", "for", "in", "return", "break", "continue",
      "as", "ref", "move", "dyn", "where", "type", "const", "static", "unsafe", "async",
      "await", "self", "Self", "true", "false",
    ]
  } else if id == "javascript" || id == "typescript" {
    [
      "const", "let", "var", "function", "class", "extends", "return", "if", "else",
      "for", "while", "do", "switch", "case", "break", "continue", "new", "delete",
      "typeof", "instanceof", "in", "of", "this", "super", "import", "export", "from",
      "default", "async", "await", "try", "catch", "finally", "throw", "yield", "static",
      "get", "set", "null", "undefined", "true", "false", "interface", "implements",
      "type", "enum", "namespace", "declare", "readonly", "public", "private", "protected",
      "abstract", "as", "satisfies",
    ]
  } else if id == "json" {
    ["true", "false", "null"]
  } else if id == "bash" {
    [
      "if", "then", "elif", "else", "fi", "for", "in", "do", "done", "while", "until",
      "case", "esac", "function", "return", "exit", "export", "local", "readonly",
      "source", "set", "unset", "shift", "echo", "cd", "sudo",
    ]
  } else if id == "python" {
    [
      "def", "class", "return", "if", "elif", "else", "for", "while", "break", "continue",
      "import", "from", "as", "pass", "raise", "try", "except", "finally", "with",
      "lambda", "yield", "global", "nonlocal", "assert", "del", "in", "is", "not",
      "and", "or", "None", "True", "False", "self", "async", "await",
    ]
  } else if id == "toml" {
    ["true", "false"]
  } else if id == "yaml" {
    ["true", "false", "null", "yes", "no", "on", "off"]
  } else {
    []
  }
}

///|
fn is_keyword(keywords : Array[String], word : String) -> Bool {
  for keyword in keywords {
    if keyword == word {
      return true
    }
  }
  false
}

///|
fn is_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
fn is_word_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn is_word_char(ch : Char) -> Bool {
  is_word_start(ch) || is_digit(ch)
}

///|
fn uses_hash_comment(id : String) -> Bool {
  id == "bash" || id == "python" || id == "toml" || id == "yaml"
}

///|
fn uses_slash_comment(id : String) -> Bool {
  id == "moonbit" || id == "rust" || id == "javascript" || id == "typescript"
}

///|
fn is_line_comment_start(
  id : String,
  chars : Array[Char],
  i : Int,
  end : Int,
) -> Bool {
  if uses_hash_comment(id) && chars[i] == '#' {
    return true
  }
  uses_slash_comment(id) &&
  chars[i] == '/' &&
  i + 1 < end &&
  chars[i + 1] == '/'
}

///|
fn is_block_comment_start(
  id : String,
  chars : Array[Char],
  i : Int,
  end : Int,
) -> Bool {
  uses_slash_comment(id) &&
  chars[i] == '/' &&
  i + 1 < end &&
  chars[i + 1] == '*'
}

///|
fn is_string_quote(id : String, ch : Char) -> Bool {
  if ch == '"' {
    return true
  }
  if ch == '\'' {
    return id != "json"
  }
  ch == '`' && (id == "javascript" || id == "typescript")
}

///|
fn write_token(out : StringBuilder, class_name : String, text : String) -> Unit {
  out.write_string("<span class=\"" + class_name + "\">")
  out.write_string(escape_html(text))
  out.write_string("</span>")
}

///|
fn write_line_comment(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let mut stop = i
  while stop < end && chars[stop] != '\n' {
    stop = stop + 1
  }
  write_token(out, "mp-tok-comment", chars_to_string(chars, i, stop))
  stop
}

///|
fn write_block_comment(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let close = find_pair(chars, i + 2, end, '*', '/')
  let stop = if close < 0 { end } else { close + 2 }
  write_token(out, "mp-tok-comment", chars_to_string(chars, i, stop))
  stop
}

///|
fn write_string_token(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let quote = chars[i]
  let mut stop = i + 1
  while stop < end {
    let ch = chars[stop]
    if ch == '\\' {
      stop = stop + 2
      continue
    }
    if ch == '\n' || ch == quote {
      break
    }
    stop = stop + 1
  }
  let close = if stop < end && chars[stop] == quote { stop + 1 } else { stop }
  let bounded = if close > end { end } else { close }
  write_token(out, "mp-tok-string", chars_to_string(chars, i, bounded))
  bounded
}

///|
fn write_number(
  chars : Array[Char],
  i : Int,
  end : Int,
  out : StringBuilder,
) -> Int {
  let mut stop = i
  while stop < end &&
        (
          is_digit(chars[stop]) ||
          chars[stop] == '.' ||
          chars[stop] == '_' ||
          chars[stop] == 'x' ||
          chars[stop] == 'X' ||
          (chars[stop] >= 'a' && chars[stop] <= 'f') ||
          (chars[stop] >= 'A' && chars[stop] <= 'F')
        ) {
    stop = stop + 1
  }
  write_token(out, "mp-tok-number", chars_to_string(chars, i, stop))
  stop
}

///|
fn write_word(
  chars : Array[Char],
  i : Int,
  end : Int,
  keywords : Array[String],
  out : StringBuilder,
) -> Int {
  let mut stop = i
  while stop < end && is_word_char(chars[stop]) {
    stop = stop + 1
  }
  let word = chars_to_string(chars, i, stop)
  if is_keyword(keywords, word) {
    write_token(out, "mp-tok-keyword", word)
  } else if stop < end && chars[stop] == '(' {
    write_token(out, "mp-tok-function", word)
  } else {
    out.write_string(escape_html(word))
  }
  stop
}
