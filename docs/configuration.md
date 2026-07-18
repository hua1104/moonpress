---
title: Configuration
description: Page metadata supported by MoonPress
order: 4
---

# Configuration

MoonPress currently reads page-level metadata from front matter.

## Page fields

- `title`: page title used in navigation, HTML title, and search index.
- `description`: short text for the search index and future metadata tags.
- `order`: numeric ordering key for navigation and pager links.
- `draft`: set to `true` to skip a page during builds.
- `lang`: page language, currently `en` or `zh`.

## CLI options

- `--out`: generated site directory, `dist` by default.
- `--base-url`: deployment root such as `/moonpress/` or `https://example.com/docs/`.
- `--port`: preview server port, `8080` by default.

## Example

```markdown
---
title: Getting Started
description: Build a first MoonPress site
order: 2
draft: false
---

# Getting Started
```
