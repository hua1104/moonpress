---
title: Getting Started
description: Build a first MoonPress site
order: 2
---

# Getting Started

Create a `docs` directory, add Markdown files, and run the MoonPress CLI to generate HTML pages.

## Build command

```bash
moon run src/cmd/moonpress -- build docs --out dist
```

For GitHub Pages project sites, include the repository path:

```bash
moon run src/cmd/moonpress -- build docs --out dist --base-url /moonpress/
```
