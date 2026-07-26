---
title: Configuration
description: Site configuration file, page metadata, and CLI options
order: 4
---

# Configuration

MoonPress reads site-wide settings from a configuration file and page-level settings from front matter.

## Site configuration

Place a `moonpress.json` file next to the directory you build from. MoonPress loads it automatically; pass `--config` to use a different path.

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

| Field | Purpose |
|:------|:--------|
| `title` | Site name used in the HTML title and Open Graph tags. |
| `description` | Fallback description for pages without their own. |
| `base_url` | URL prefix applied to every generated link. |
| `author` | Written to the `author` meta tag. |
| `site_url` | Absolute origin used for canonical URLs, Open Graph, and `robots.txt`. |
| `default_lang` | Language used for the `hreflang="x-default"` link. |

Missing fields fall back to their defaults, so a partial file is valid.

## Page fields

- `title`: page title used in navigation, HTML title, and search index.
- `description`: short text used for the page description and search index.
- `order`: numeric ordering key for navigation and pager links.
- `draft`: set to `true` to skip a page during builds.
- `lang`: page language, currently `en` or `zh`.

```markdown
---
title: Getting Started
description: Build a first MoonPress site
order: 2
draft: false
---

# Getting Started
```

## CLI options

- `--out <dir>`: generated site directory, `dist` by default.
- `--base-url <path>`: deployment root such as `/moonpress/` or `https://example.com/docs/`.
- `--site-url <url>`: absolute origin for canonical and Open Graph tags.
- `--config <file>`: configuration file path, `moonpress.json` by default.
- `--port <number>`: preview server port, `8080` by default.

Command-line flags take precedence over values from the configuration file.

## Exit codes

- `0`: the command succeeded.
- `1`: a runtime error, such as a missing input directory or configuration file.
- `2`: a usage error, such as an unknown option or an invalid port.
