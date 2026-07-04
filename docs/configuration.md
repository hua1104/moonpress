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

