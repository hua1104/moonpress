---
title: 配置说明
description: 站点配置文件、页面元数据与命令行选项
order: 4
lang: zh
---

# 配置说明

MoonPress 通过配置文件读取站点级配置，通过 front matter 读取页面级配置。

## 站点配置

在构建目录旁放置 `moonpress.json`，MoonPress 会自动加载；也可以用 `--config` 指定其他路径。

```json
{
  "title": "MoonPress",
  "description": "使用 MoonBit 实现的静态文档站生成器",
  "base_url": "/moonpress/",
  "author": "hua1104",
  "site_url": "https://hua1104.github.io",
  "default_lang": "en"
}
```

| 字段 | 作用 |
|:-----|:-----|
| `title` | 站点名称，用于 HTML 标题和 Open Graph 标签。 |
| `description` | 页面未单独填写时的默认简介。 |
| `base_url` | 应用到所有生成链接的 URL 前缀。 |
| `author` | 写入 `author` meta 标签。 |
| `site_url` | 用于 canonical、Open Graph 和 `robots.txt` 的绝对地址。 |
| `default_lang` | 用于 `hreflang="x-default"` 的语言。 |

缺失字段会回退到默认值，因此只写部分字段也是合法的。

## 页面字段

- `title`：页面标题，用于导航、HTML 标题和搜索索引。
- `description`：页面简介，用于页面描述和搜索索引。
- `order`：导航和上一篇/下一篇的排序值。
- `draft`：设为 `true` 时跳过该页面。
- `lang`：页面语言，英文为 `en`，中文为 `zh`。

```markdown
---
title: 快速开始
description: 构建第一个 MoonPress 站点
order: 2
lang: zh
---

# 快速开始
```

## 命令行选项

- `--out <目录>`：输出目录，默认 `dist`。
- `--base-url <路径>`：部署前缀，例如 `/moonpress/` 或 `https://example.com/docs/`。
- `--site-url <地址>`：用于 canonical 和 Open Graph 的绝对地址。
- `--config <文件>`：配置文件路径，默认 `moonpress.json`。
- `--port <端口>`：预览服务端口，默认 `8080`。

命令行选项的优先级高于配置文件。

## 退出码

- `0`：命令执行成功。
- `1`：运行时错误，例如输入目录或配置文件不存在。
- `2`：用法错误，例如未知选项或非法端口。
