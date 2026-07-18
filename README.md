# MoonPress

MoonPress is a static documentation site generator implemented in MoonBit. It scans Markdown files, reads front matter, builds bilingual HTML pages, copies static assets, and provides a local preview server. The generated site can be deployed at a domain root or below a path such as GitHub Pages `/moonpress/`.

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
- `search-index.json`, `sitemap.xml`, and `moonpress-manifest.txt`.
- The built-in stylesheet and files copied from `docs/assets/`.

## Preview and Clean

```bash
moon run src/cmd/moonpress -- dev docs --out dist --port 8080
moon run src/cmd/moonpress -- clean --out dist
```

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
- `description`: search index description.
- `order`: navigation and pager ordering.
- `lang`: `en` by default; use `zh` for Chinese pages.
- `draft`: omit the page from output when set to `true`.

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

The MoonBit tests cover routing, front matter, rendering, navigation, paging, search, sitemap, and build planning. The Node.js integration tests execute the real CLI and verify custom output directories, base URLs, asset copying, cleaning, and HTTP preview behavior.

## License

MoonPress is released under the MIT License.
