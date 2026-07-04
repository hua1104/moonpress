fn main {
  let args = @env.args()
  let command = find_command(args)
  if command == "build" {
    run_build(args)
  } else if command == "clean" {
    run_clean(args)
  } else if command == "version" || command == "--version" || command == "-V" {
    println("moonpress " + @core.version())
  } else {
    print_help()
  }
}

fn find_command(args : Array[String]) -> String {
  for arg in args {
    if arg == "help" || arg == "--help" || arg == "-h" {
      return "help"
    } else if arg == "version" || arg == "--version" || arg == "-V" {
      return "version"
    } else if arg == "build" {
      return "build"
    } else if arg == "clean" {
      return "clean"
    }
  }
  "build"
}

fn run_build(args : Array[String]) -> Unit {
  let docs_dir = find_build_input(args)
  let out_dir = find_option(args, "--out", "dist")
  let base_url = find_option(args, "--base-url", "/")
  let sources = load_sources(docs_dir)
  let en_result = @core.build_site_for_lang(
    sources,
    {
      title: "MoonPress",
      description: "MoonBit documentation site",
      base_url,
    },
    "en",
  )
  let zh_result = @core.build_site_for_lang(
    sources,
    {
      title: "MoonPress",
      description: "MoonBit documentation site",
      base_url: join_base_url(base_url, "zh"),
    },
    "zh",
  )
  let result = @core.merge_build_results([en_result, zh_result])
  write_build_result(out_dir, result)
  copy_assets(docs_dir, out_dir)
  println("moonpress " + @core.version())
  println("built " + result.page_count.to_string() + " pages from " + docs_dir)
  for file in result.files {
    println("emit " + out_dir + "/" + file.path)
  }
  println("copy " + docs_dir + "/assets -> " + out_dir + "/assets")
  println("copy " + docs_dir + "/assets -> " + out_dir + "/zh/assets")
}

fn join_base_url(base_url : String, segment : String) -> String {
  if base_url == "" || base_url == "/" {
    "/" + segment + "/"
  } else if base_url.has_suffix("/") {
    base_url + segment + "/"
  } else {
    base_url + "/" + segment + "/"
  }
}

fn run_clean(args : Array[String]) -> Unit {
  let out_dir = find_option(args, "--out", "dist")
  clean_output_dir(out_dir)
  println("cleaned " + out_dir)
}

fn find_build_input(args : Array[String]) -> String {
  let mut seen_build = false
  for arg in args {
    if seen_build && !arg.has_prefix("-") {
      return arg
    }
    if arg == "build" {
      seen_build = true
    }
  }
  "docs"
}

fn find_option(args : Array[String], name : String, fallback : String) -> String {
  for i = 0; i < args.length(); i = i + 1 {
    if args[i] == name && i + 1 < args.length() {
      return args[i + 1]
    }
    let prefix = name + "="
    if args[i].has_prefix(prefix) {
      return args[i][prefix.length():].to_owned()
    }
  }
  fallback
}

fn print_help() -> Unit {
  println("moonpress " + @core.version())
  println("Usage:")
  println("  moonpress build [docs-dir] --out dist --base-url /")
  println("  moonpress clean --out dist")
  println("  moonpress version")
}
