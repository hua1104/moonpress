# MoonPress

MoonPress is a static documentation site generator implemented in MoonBit. It scans Markdown files, reads front matter, builds bilingual HTML pages, copies static assets, and provides a local preview server. The generated site can be deployed at a domain root or below a path such as GitHub Pages `/moonpress/`.

## Features

- Renders a practical CommonMark subset: headings with permalink anchors, bold and italic text, images, ordered and nested lists, blockquotes, aligned tables, thematic breaks, and fenced code blocks with language classes.
- GFM-style extras: strikethrough, task lists, autolinks, footnotes, and reference-style links.
- Admonition containers (`::: tip`, `::: note`, `::: info`, `::: warning`, `::: danger`, `::: caution`) with optional custom titles and theme-aware colors.
- Build-time dead link detection: internal `.md` and route links are validated on every build and broken ones are reported as warnings.
- Build-time syntax highlighting for MoonBit, Rust, JavaScript, TypeScript, JSON, Bash, Python, TOML, and YAML — no runtime highlighter is shipped.
- Code blocks with a language label, an optional `title="..."` caption, and a copy button.
- An on-page table of contents with scroll highlighting, and a sidebar that groups pages by directory.
- A light/dark theme switch that follows the system preference and remembers the choice.
- Site-wide configuration through `moonpress.json`, overridable from the command line.
- SEO metadata on every page: description, canonical URL, `hreflang` alternates, Open Graph, and Twitter card tags.
- A dependency-free client-side search widget backed by the generated search index, with CJK bigram tokenization so Chinese queries rank properly.
- Bilingual output with English pages at the root and Chinese pages under `zh/`.
- `sitemap.xml`, an RSS `feed.xml`, a `404.html` page, `robots.txt`, and a build manifest for deployment.
- Incremental rebuilds: unchanged files are not rewritten and stale files are pruned, and `dev` watches the docs, rebuilds on save, and live-reloads open preview tabs.
- A strict CLI that validates arguments and reports failures with meaningful exit codes.

## Prerequisites

- The latest stable [MoonBit toolchain](https://www.moonbitlang.com/download/).
- Node.js 20 or newer. CI currently tests with Node.js 24.
- Git for cloning the repository.

Verify the tools before building:

```bash
moon version
node --version
git --version
```

## Installation

```bash
git clone https://github.com/hua1104/moonpress.git
cd moonpress
moon check --deny-warn
```

MoonPress can be run directly from the repository; no npm dependencies are required.

## Build a Site

Put Markdown documents in `docs/`, then run:

```bash
moon run src/cmd/moonpress -- build docs --out dist
```

For a project site deployed at `https://USER.github.io/moonpress/`, set the URL prefix explicitly:

```bash
moon run src/cmd/moonpress -- build docs --out dist --base-url /moonpress/
```

`--base-url` is applied to stylesheets, navigation, language links, pager links, preview routes, and sitemap entries. A full URL such as `https://example.com/docs/` is also supported.

Generated files include:

- HTML pages derived from Markdown routes.
- English pages at the output root and Chinese pages under `zh/`.
- `search-index.json`, `sitemap.xml`, `feed.xml`, `404.html`, `robots.txt`, and `moonpress-manifest.txt`.
- The built-in stylesheet, the search bundle, and files copied from `docs/assets/`.

During the build every internal link is validated: a `.md` link must resolve to an existing document and an absolute extensionless path must match a generated route. Broken links are printed to stderr as `warning: <file>: broken link <target>` without failing the build. External links, bare `#anchors`, asset paths, and examples inside code are skipped.

## Configure a Site

Site-wide settings live in `moonpress.json`, which is loaded automatically from the working directory:

```json
{
  "title": "MoonPress",
  "description": "A static documentation site generator written in MoonBit.",
  "base_url": "/moonpress/",
  "author": "hua1104",
  "site_url": "https://hua1104.github.io",
  "default_lang": "en"
}
```

Setting `site_url` enables absolute canonical URLs, Open Graph tags, and a `robots.txt` sitemap reference. Command-line flags such as `--base-url` and `--site-url` override the file, and `--config` selects a different path. Missing fields fall back to their defaults.

## CLI Reference

```text
moonpress build [docs-dir] [options]
moonpress dev   [docs-dir] [options]
moonpress clean [options]
moonpress version

--out <dir>        output directory (default: dist)
--base-url <path>  URL prefix for generated links (default: /)
--site-url <url>   absolute origin used for canonical and og tags
--config <file>    config file path (default: moonpress.json)
--port <number>    preview port for dev (default: 8080)
-h, --help         show help
-V, --version      show the version
```

The CLI exits with `0` on success, `1` on runtime errors such as a missing input directory, and `2` on usage errors such as an unknown option.

## Preview and Clean

```bash
moon run src/cmd/moonpress -- dev docs --out dist --port 8080
moon run src/cmd/moonpress -- clean --out dist
```

`dev` builds the site, serves it, and watches the docs directory. Saving a Markdown file triggers an incremental rebuild — only files whose content changed are rewritten — and every open preview tab reloads itself through a server-sent-events channel. The reload client only activates on localhost, so deployed pages never open the connection.

When a base URL is configured, open the preview through that prefix:

```bash
moon run src/cmd/moonpress -- dev docs --out dist --base-url /moonpress/ --port 8080
```

The preview URL is then `http://127.0.0.1:8080/moonpress/`.

## Document Metadata

MoonPress accepts the following front matter fields:

```markdown
---
title: Getting Started
description: Build a first MoonPress site
order: 2
lang: en
draft: false
---

# Getting Started
```

- `title`: navigation, page, and search title.
- `description`: page description meta tag and search index entry.
- `order`: navigation and pager ordering.
- `lang`: `en` by default; use `zh` for Chinese pages.
- `draft`: omit the page from output when set to `true`.

## Supported Markdown

Headings `#` through `######` with permalink anchors, `**bold**`, `*italic*`, `~~strikethrough~~`, inline code, backslash escapes, links, reference-style links (`[text][id]` with `[id]: url` definitions), autolinks (`<https://example.com>` and `<user@example.com>`), images, ordered and unordered lists with nesting, task lists (`- [x]`), blockquotes, admonition containers (`::: tip` … `:::` with optional custom titles), tables with column alignment, thematic breaks, footnotes (`[^id]` with `[^id]: text` definitions), and fenced code blocks with an optional language and `title="..."` caption. Fenced code in MoonBit, Rust, JavaScript, TypeScript, JSON, Bash, Python, TOML, or YAML is syntax-highlighted at build time. External links receive `rel="noopener noreferrer"`. All content is HTML-escaped, so documents cannot inject markup into the generated pages.

## Quality Checks

Run the same checks used by CI:

```bash
moon clean
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
git diff --exit-code -- src/pkg.generated.mbti src/cmd/moonpress/pkg.generated.mbti
moon build --target js src/cmd/moonpress
node --test tests/cli.integration.test.mjs
```

The MoonBit tests cover routing, front matter, Markdown rendering (including admonitions), internal link checking, configuration parsing, SEO metadata, navigation, paging, search, sitemap, build planning, and CLI argument parsing. The Node.js integration tests execute the real CLI and verify custom output directories, base URLs, configuration loading and flag precedence, SEO output, the search bundle and its CJK tokenizer, extended Markdown rendering, admonitions, broken link warnings, asset copying, cleaning, exit codes, and HTTP preview behavior.

## License

MoonPress is released under the MIT License.
