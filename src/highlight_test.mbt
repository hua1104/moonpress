///|
test "highlight maps language aliases" {
  inspect(highlight_language_id("MoonBit"), content="moonbit")
  inspect(highlight_language_id("sh"), content="bash")
  inspect(highlight_language_id("ts"), content="typescript")
  inspect(highlight_language_id("brainfuck"), content="")
}

///|
test "highlight moonbit keywords comments numbers and calls" {
  inspect(
    highlight_code("moonbit", "fn add(a : Int) -> Int {\n  // sum\n  a + 1\n}"),
    content=(
      #|<span class="mp-tok-keyword">fn</span> <span class="mp-tok-function">add</span>(a : Int) -&gt; Int {
      #|  <span class="mp-tok-comment">// sum</span>
      #|  a + <span class="mp-tok-number">1</span>
      #|}
    ),
  )
}

///|
test "highlight json strings and literals" {
  inspect(
    highlight_code("json", "{\"a\": 1}"),
    content=(
      #|{<span class="mp-tok-string">&quot;a&quot;</span>: <span class="mp-tok-number">1</span>}
    ),
  )
}

///|
test "highlight bash comments and single quoted strings" {
  inspect(
    highlight_code("bash", "# note\nmoon test 'x'"),
    content=(
      #|<span class="mp-tok-comment"># note</span>
      #|moon test <span class="mp-tok-string">'x'</span>
    ),
  )
}

///|
test "highlight falls back to escaped text for unknown languages" {
  inspect(highlight_code("text", "let <x> = 1"), content="let &lt;x&gt; = 1")
}
