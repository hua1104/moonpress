# MoonPress Roadmap

## Implemented

- Recursive Markdown discovery and front matter parsing.
- Static HTML generation with stable document routes.
- Extended Markdown subset: heading levels one through six with permalink anchors, bold and italic text, strikethrough, images, ordered and nested lists, task lists, blockquotes, aligned tables, thematic breaks, autolinks, reference-style links, footnotes, and fenced code blocks with language classes and optional titles.
- Admonition containers (`::: tip` through `::: caution`) with custom titles and theme-aware styling.
- Build-time internal link validation with per-link warnings for broken `.md` and route targets.
- CJK-aware search: queries are tokenized into words and Chinese bigrams so bilingual sites rank results correctly.
- Build-time syntax highlighting for MoonBit, Rust, JavaScript, TypeScript, JSON, Bash, Python, TOML, and YAML, with copy buttons on every code block.
- An on-page table of contents with scroll highlighting, and a sidebar grouped by directory.
- A light/dark theme switch that follows the system preference and persists the choice.
- Site configuration through `moonpress.json`, with command-line overrides.
- SEO metadata: page descriptions, canonical URLs, `hreflang` alternates, Open Graph, and Twitter card tags.
- Dependency-free client-side search widget backed by the generated index.
- English and Chinese output, navigation, language switching, and pager links.
- Search indexes, sitemaps, RSS feeds, 404 pages, `robots.txt`, build manifests, and static asset copying.
- `build`, `clean`, and `dev` CLI commands with strict argument validation and meaningful exit codes.
- Incremental rebuilds that skip unchanged files and prune stale output.
- A `dev` server with file watching and live reload over server-sent events.
- Root and nested base URL deployment support.
- MoonBit unit tests and Node.js CLI/preview integration tests.

## Next

- Configurable themes and custom page layouts.
- Richer CommonMark compatibility, including setext headings and reference-style images.
- Search with word-boundary ranking and per-heading anchors.
- Published demo artifacts and versioned binary releases.
