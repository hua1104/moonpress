---
title: Architecture
description: How MoonPress turns documents into a static site
order: 3
---

# Architecture

MoonPress is split into a reusable core library and a small CLI package.

## Core library

- `config.mbt` parses the `moonpress.json` site configuration.
- `frontmatter.mbt` reads page metadata such as `title`, `description`, `order`, and `draft`.
- `router.mbt` maps Markdown paths to stable documentation routes.
- `site_plan.mbt` turns input documents into sorted page plans.
- `markdown.mbt` renders the supported Markdown subset to HTML.
- `render.mbt` wraps rendered content in the page shell and emits SEO metadata.
- `navigation.mbt` and `pager.mbt` generate document browsing links.
- `search_ui.mbt` emits the dependency-free client-side search widget.
- `builder.mbt` turns page plans into output files.
- `search.mbt`, `sitemap.mbt`, and `manifest.mbt` generate deployment metadata.

## CLI package

The CLI package lives in `src/cmd/moonpress`. It handles runtime-specific work:

- parsing and validating command-line arguments
- reading the configuration file
- scanning `docs/` for Markdown files
- copying `docs/assets/`
- writing the generated files to `dist/`
- cleaning output directories
- serving the preview server

## Build flow

```text
docs/*.md
  -> PageSource
  -> PagePlan
  -> Rendered HTML
  -> dist/
```

The core stays independent from the Node.js filesystem bridge. This keeps the main site generation logic easy to test and reusable from other MoonBit packages.

