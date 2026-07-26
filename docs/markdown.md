---
title: Markdown Reference
description: The Markdown syntax MoonPress renders
order: 5
---

# Markdown Reference

MoonPress renders a practical CommonMark subset. Everything below is covered by the test suite.

## Headings

Levels `#` through `######` are supported. Each heading receives a generated `id` and a permalink anchor, so `## Build Command` becomes `#build-command`.

## Inline formatting

- `**bold**` renders as **bold**.
- `*italic*` renders as *italic*.
- `` `inline code` `` renders as `inline code`.
- `~~strikethrough~~` renders as ~~strikethrough~~.
- `\*escaped\*` renders literal asterisks.

Underscores inside words are left alone, so `snake_case_name` survives intact.

## Links and images

`[label](/target)` produces a link. Links to `http://` or `https://` targets automatically receive `rel="noopener noreferrer"` and open in a new tab.

`![alt text](/assets/logo.png)` produces an image with `loading="lazy"`.

Reference-style links keep long URLs out of the prose: write `[label][id]` in the text and define `[id]: https://example.com` on its own line anywhere in the document. Bare URLs and e-mail addresses can be autolinked with angle brackets: `<https://moonbitlang.com>` and `<hello@example.com>`.

## Lists

Unordered lists accept `-`, `*`, or `+` markers. Ordered lists use `1.` style markers. Indent by two spaces to nest:

```markdown
- outer item
  - nested item
1. first
2. second
```

Task lists render as checkboxes:

```markdown
- [x] shipped
- [ ] planned
```

## Blockquotes

```markdown
> Quoted text supports **inline formatting**.
```

## Tables

```markdown
| Name | Value |
|:-----|------:|
| left |     1 |
```

Use `:---` for left alignment, `---:` for right, and `:---:` for centre.

## Code blocks

Fenced blocks accept an optional language, which becomes a `language-*` class on the `<code>` element. MoonBit, Rust, JavaScript, TypeScript, JSON, Bash, Python, TOML, and YAML are syntax-highlighted at build time, every block gets a copy button, and a `title="..."` attribute adds a caption:

````markdown
```moonbit title="hello.mbt"
let greeting = "hello"
```
````

## Footnotes

`A claim.[^1]` references a footnote defined as `[^1]: The supporting note.` — footnotes collect at the end of the page with backlinks.

## Thematic breaks

A line of three or more `-`, `*`, or `_` characters renders as a horizontal rule.

## Escaping

All text, attribute values, and URLs are HTML-escaped, so document content cannot inject markup into the generated page.
