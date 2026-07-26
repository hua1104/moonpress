///|
struct Options {
  command : String
  input : String
  out : String
  base_url : String
  config_path : String
  port : Int
  site_url : String
  errors : Array[String]
}

///|
fn main {
  let options = parse_args(cli_args())
  if options.errors.length() > 0 {
    for message in options.errors {
      print_error(message)
    }
    print_error("run `moonpress help` for usage")
    exit_with(2)
  } else if options.command == "help" {
    print_help()
  } else if options.command == "version" {
    println("moonpress " + @core.version())
  } else if options.command == "build" {
    run_build(options) |> ignore
  } else if options.command == "dev" {
    run_dev(options)
  } else if options.command == "clean" {
    run_clean(options)
  }
}

///|
fn known_command(value : String) -> Bool {
  value == "build" ||
  value == "dev" ||
  value == "clean" ||
  value == "help" ||
  value == "version"
}

///|
fn parse_args(args : Array[String]) -> Options {
  let errors : Array[String] = []
  let mut command = ""
  let mut input = ""
  let mut out = ""
  let mut base_url = ""
  let mut config_path = ""
  let mut site_url = ""
  let mut port = 8080
  let mut i = 0
  while i < args.length() {
    let arg = args[i]
    if arg == "--help" || arg == "-h" {
      command = "help"
      i = i + 1
    } else if arg == "--version" || arg == "-V" {
      if command == "" {
        command = "version"
      }
      i = i + 1
    } else if known_command(arg) && command == "" {
      command = arg
      i = i + 1
    } else if arg.has_prefix("-") {
      let (name, inline_value, consumed) = split_option(args, i)
      if name == "--out" {
        match inline_value {
          Some(value) => out = value
          None => errors.push("missing value for --out")
        }
      } else if name == "--base-url" {
        match inline_value {
          Some(value) => base_url = value
          None => errors.push("missing value for --base-url")
        }
      } else if name == "--config" {
        match inline_value {
          Some(value) => config_path = value
          None => errors.push("missing value for --config")
        }
      } else if name == "--site-url" {
        match inline_value {
          Some(value) => site_url = value
          None => errors.push("missing value for --site-url")
        }
      } else if name == "--port" {
        match inline_value {
          Some(value) =>
            match parse_port(value) {
              Some(parsed) => port = parsed
              None => errors.push("invalid value for --port: " + value)
            }
          None => errors.push("missing value for --port")
        }
      } else {
        errors.push("unknown option: " + name)
      }
      i = i + consumed
    } else if input == "" && (command == "build" || command == "dev") {
      input = arg
      i = i + 1
    } else {
      errors.push("unexpected argument: " + arg)
      i = i + 1
    }
  }
  if command == "" {
    command = "help"
  }
  {
    command,
    input: if input == "" {
      "docs"
    } else {
      input
    },
    out: if out == "" {
      "dist"
    } else {
      out
    },
    base_url,
    config_path,
    site_url,
    port,
    errors,
  }
}

///|
fn split_option(args : Array[String], index : Int) -> (String, String?, Int) {
  let arg = args[index]
  match arg.find("=") {
    Some(at) => (arg[:at].to_owned(), Some(arg[at + 1:].to_owned()), 1)
    None =>
      if index + 1 < args.length() && !args[index + 1].has_prefix("-") {
        (arg, Some(args[index + 1]), 2)
      } else {
        (arg, None, 1)
      }
  }
}

///|
fn parse_port(value : String) -> Int? {
  if value == "" {
    return None
  }
  let mut result = 0
  for ch in value {
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - '0'.to_int())
    } else {
      return None
    }
  }
  if result < 1 || result > 65535 {
    None
  } else {
    Some(result)
  }
}

///|
fn resolve_config(options : Options) -> @core.SiteConfig {
  let path = if options.config_path == "" {
    "moonpress.json"
  } else {
    options.config_path
  }
  let base = match read_text_file(path) {
    Some(text) => @core.parse_config_json(text, @core.default_config())
    None => {
      if options.config_path != "" {
        print_error("config file not found: " + path)
        exit_with(1)
      }
      @core.default_config()
    }
  }
  {
    ..base,
    base_url: if options.base_url == "" {
      base.base_url
    } else {
      options.base_url
    },
    site_url: if options.site_url == "" {
      base.site_url
    } else {
      options.site_url
    },
  }
}

///|
fn run_build(options : Options) -> @core.SiteConfig {
  let config = resolve_config(options)
  if !dir_exists(options.input) {
    print_error("input directory not found: " + options.input)
    exit_with(1)
  }
  let sources = load_sources(options.input)
  if sources.length() == 0 {
    print_error("no markdown files found in " + options.input)
    exit_with(1)
  }
  let en_result = @core.build_site_for_lang(sources, config, "en")
  let zh_result = @core.build_site_for_lang(sources, config, "zh")
  let result = @core.merge_build_results([en_result, zh_result])
  let changed = write_build_result(options.out, result)
  copy_assets(options.input, options.out)
  println("moonpress " + @core.version())
  println(
    "built " + result.page_count.to_string() + " pages from " + options.input,
  )
  for file in result.files {
    println("emit " + options.out + "/" + file.path)
  }
  println("copy " + options.input + "/assets -> " + options.out + "/assets")
  println("copy " + options.input + "/assets -> " + options.out + "/zh/assets")
  println(
    "changed " +
    changed.to_string() +
    " of " +
    result.files.length().to_string() +
    " files",
  )
  config
}

///|
/// Rebuilds the site with exactly the flags the developer typed, so the watcher
/// can replay the same command whenever a document changes.
fn rebuild_command(options : Options) -> String {
  let args : Array[String] = ["build", options.input, "--out", options.out]
  if options.base_url != "" {
    args.push("--base-url")
    args.push(options.base_url)
  }
  if options.site_url != "" {
    args.push("--site-url")
    args.push(options.site_url)
  }
  if options.config_path != "" {
    args.push("--config")
    args.push(options.config_path)
  }
  args.join("\n")
}

///|
fn run_dev(options : Options) -> Unit {
  let config = run_build(options)
  start_preview(
    options.out,
    options.port,
    config.base_url,
    options.input,
    rebuild_command(options),
  )
}

///|
fn run_clean(options : Options) -> Unit {
  clean_output_dir(options.out)
  println("cleaned " + options.out)
}

///|
fn print_help() -> Unit {
  println("moonpress " + @core.version())
  println("A static documentation site generator written in MoonBit.")
  println("")
  println("Usage:")
  println("  moonpress build [docs-dir] [options]")
  println("  moonpress dev   [docs-dir] [options]")
  println("  moonpress clean [options]")
  println("  moonpress version")
  println("")
  println("Options:")
  println("  --out <dir>        output directory (default: dist)")
  println("  --base-url <path>  URL prefix for generated links (default: /)")
  println("  --site-url <url>   absolute origin used for canonical and og tags")
  println("  --config <file>    config file path (default: moonpress.json)")
  println("  --port <number>    preview port for dev (default: 8080)")
  println("  -h, --help         show this help")
  println("  -V, --version      show the version")
}
