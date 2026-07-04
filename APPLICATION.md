# MoonPress 项目申报书

## 项目名称

MoonPress：面向 MoonBit 生态的静态文档站生成器

## 项目简介

MoonPress 是一个使用 MoonBit 实现的静态文档站生成器，目标是帮助 MoonBit 开源库作者将 Markdown 文档快速生成可发布的静态网站。项目支持文档路由、页面元数据、导航、上一篇/下一篇、搜索索引、sitemap、构建 manifest、静态资源复制和中英双语站点输出，可用于 MoonBit 包文档、教程站、课程讲义、项目主页和参赛项目展示页。

## 项目方向与适用场景

项目方向属于 MoonBit 开源生态建设中的工程基础设施与应用生态。适用场景包括：

- MoonBit 开源库文档站与 API 示例说明；
- 教程、课程讲义和项目主页；
- GitHub Pages / Gitlink Pages 等静态站点部署；
- 需要中英双语展示的 MoonBit 项目文档。

## 拟实现的核心功能

- 扫描 `docs/` 目录，读取 Markdown 文档并生成 `dist/` 静态站点；
- 解析 front matter：`title`、`description`、`order`、`draft`、`lang`；
- 将 Markdown 子集渲染为 HTML，支持标题、段落、列表、链接、行内代码和代码块；
- 生成侧边栏导航、上一篇/下一篇链接和语言切换入口；
- 生成 `search-index.json`、`sitemap.xml` 和 `moonpress-manifest.txt`；
- 复制 `docs/assets/` 静态资源；
- 提供 CLI：`build`、`clean`，支持 `--out` 和 `--base-url`；
- 提供中英双语示例文档站和测试用例。

## 原创性与参考项目

本项目为原创项目，不是对已有项目的直接移植。项目会参考成熟生态中静态文档站工具的产品形态和工程经验，例如 Rust 生态的 mdBook、JavaScript 生态的 VitePress / Docusaurus，但不会复制或移植其源码。MoonPress 的核心数据模型、路由规划、页面构建流程、CLI 和示例站点均使用 MoonBit 自主实现。若后续接入 MoonBit 生态已有 Markdown parser，将以依赖形式使用，并在仓库中明确标注来源和许可证。

## 仓库链接

- GitHub 仓库：[https://github.com/hua1104/moonpress.git](https://github.com/hua1104/moonpress.git)
- Gitlink 仓库：[https://gitlink.org.cn/hua1104/moonpress.git](https://gitlink.org.cn/hua1104/moonpress.git)

申报阶段将按项目功能拆分为 10-20 个有效 commits，避免通过无意义拆分、空提交或重复提交满足次数要求。Gitlink 仓库将与 GitHub 仓库保持同步。

