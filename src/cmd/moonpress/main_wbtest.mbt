///|
fn options_summary(args : Array[String]) -> String {
  let options = parse_args(args)
  options.command +
  " input=" +
  options.input +
  " out=" +
  options.out +
  " base=" +
  options.base_url +
  " port=" +
  options.port.to_string() +
  " errors=" +
  options.errors.length().to_string()
}

///|
fn first_error(args : Array[String]) -> String {
  let errors = parse_args(args).errors
  if errors.length() == 0 {
    ""
  } else {
    errors[0]
  }
}

///|
fn port_text(value : String) -> String {
  match parse_port(value) {
    Some(port) => port.to_string()
    None => "invalid"
  }
}

///|
test "CLI parses commands, inputs, options, and ports" {
  inspect(
    options_summary([
      "dev", "content", "--out=site", "--base-url", "/moonpress/", "--port", "9090",
    ]),
    content="dev input=content out=site base=/moonpress/ port=9090 errors=0",
  )
  inspect(
    options_summary(["build", "--out", "site"]),
    content="build input=docs out=site base= port=8080 errors=0",
  )
  inspect(
    options_summary(["clean", "--out", "site"]),
    content="clean input=docs out=site base= port=8080 errors=0",
  )
}

///|
test "CLI defaults to help and reports invalid usage" {
  inspect(
    options_summary([]),
    content="help input=docs out=dist base= port=8080 errors=0",
  )
  inspect(
    first_error(["build", "--unknown"]),
    content="unknown option: --unknown",
  )
  inspect(first_error(["build", "--out"]), content="missing value for --out")
  inspect(
    first_error(["build", "docs", "extra"]),
    content="unexpected argument: extra",
  )
  inspect(first_error(["clean", "docs"]), content="unexpected argument: docs")
  inspect(
    first_error(["build", "--port", "abc"]),
    content="invalid value for --port: abc",
  )
}

///|
test "CLI validates port numbers" {
  inspect(port_text("8080"), content="8080")
  inspect(port_text("invalid"), content="invalid")
  inspect(port_text("0"), content="invalid")
  inspect(port_text("70000"), content="invalid")
  inspect(port_text(""), content="invalid")
}

///|
test "CLI recognises help and version flags" {
  inspect(parse_args(["--help"]).command, content="help")
  inspect(parse_args(["-V"]).command, content="version")
  inspect(parse_args(["version"]).command, content="version")
  inspect(parse_args(["build", "--help"]).command, content="help")
}

///|
test "dev rebuild command replays the original flags" {
  inspect(
    rebuild_command(parse_args(["dev", "docs", "--out", "site"])),
    content="build\ndocs\n--out\nsite",
  )
  inspect(
    rebuild_command(
      parse_args([
        "dev", "content", "--out", "site", "--base-url", "/moonpress/", "--config",
        "site.json",
      ]),
    ),
    content="build\ncontent\n--out\nsite\n--base-url\n/moonpress/\n--config\nsite.json",
  )
}
