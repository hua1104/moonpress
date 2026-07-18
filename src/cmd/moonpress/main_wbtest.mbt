///|
test "CLI parses commands, inputs, options, and ports" {
  let args = [
    "moonpress", "dev", "content", "--out=site", "--base-url", "/moonpress/", "--port",
    "9090",
  ]
  inspect(find_command(args), content="dev")
  inspect(find_build_input(args), content="content")
  inspect(find_option(args, "--out", "dist"), content="site")
  inspect(find_option(args, "--base-url", "/"), content="/moonpress/")
  inspect(parse_port(find_option(args, "--port", "8080")), content="9090")
  inspect(parse_port("invalid"), content="8080")
  inspect(
    find_build_input(["moonpress", "build", "--out", "site"]),
    content="docs",
  )
}
