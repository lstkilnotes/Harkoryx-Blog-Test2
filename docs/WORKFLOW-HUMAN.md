# Harkoryx Blog — 人类编辑工作流

> 这是给主人（人类）看的工作流文档。AI Agent 请看 `.ai/WORKFLOW.md`。

---

## 快速开始

```powershell
# 1. 初始化（每次编辑前必须）
.\scripts\blog-init.ps1 -Prefix owner -Type content -Name my-article

# 2. 编辑...

# 3. 验证
pnpm run check && pnpm run build

# 4. 提交
git add -A; git commit -m "content: 添加文章 xxx"

# 5. 推送
git push -u origin owner/content/my-article

# 6. 在 GitHub 创建 PR → 自己审核合并
```

---

## 项目信息

| 项目 | 值 |
|------|-----|
| 仓库 | `https://github.com/lstkilnotes/Harkoryx-Blog-Test2` |
| 框架 | Astro + Firefly 主题 |
| 部署 | Cloudflare Pages（`main` 分支自动部署） |
| 包管理器 | **pnpm**（必须，npm 会被拦截） |

---

## 写文章

### 创建新文章

```powershell
# 方式1：用 Firefly 脚本（推荐，自动生成 frontmatter）
pnpm run new-post my-article-slug

# 方式2：手动在 src/content/posts/ 下创建 .md 文件
```

### 文章 Frontmatter

```yaml
---
title: 文章标题          # 必填
published: 2026-07-04    # 必填
description: 文章描述     # 可选
image: "./cover.jpg"     # 可选，或 "api" 随机封面
tags: [标签1, 标签2]      # 可选
category: 分类           # 可选
draft: false             # 可选，true 则不会发布
pinned: false            # 可选，置顶
comment: true            # 可选，允许评论
---
```

### 文章放在哪

```
src/content/posts/my-article.md     ← 文章
src/content/posts/my-article/       ← 文章配套资源（封面图等）
```

---

## 修改站点配置

Firefly 的配置都在 `src/config/` 目录下，按功能分文件：

| 配置文件 | 用途 |
|----------|------|
| `siteConfig.ts` | 站点名称、URL、主题色、分页等 |
| `navBarConfig.ts` | 导航栏链接 |
| `sidebarConfig.ts` | 侧边栏布局和组件 |
| `profileConfig.ts` | 个人资料 |
| `footerConfig.ts` | 页脚内容 |
| `commentConfig.ts` | 评论系统 |
| `analyticsConfig.ts` | 站点统计 |
| `fontConfig.ts` | 字体 |
| `musicConfig.ts` | 音乐播放器 |
| `friendsConfig.ts` | 友链 |

完整列表见 Firefly 使用文档：https://docs-firefly.cuteleaf.cn/

---

## 分支工作流

### 为什么要用分支？

`main` 分支受保护，不能直接推送。所有改动必须通过 PR 合并。这是为了：
- 防止误操作破坏线上站点
- 每次改动都有构建验证保障
- 可以看到每次改动的完整 diff

### 分支命名

```
owner/<type>/<name>
```

| type | 用途 | 示例 |
|------|------|------|
| `content` | 写文章 | `owner/content/my-article` |
| `feat` | 新功能 | `owner/feat/add-tags` |
| `fix` | 修复 | `owner/fix/rss-link` |
| `style` | 样式 | `owner/style/dark-mode` |
| `chore` | 杂项 | `owner/chore/update-deps` |

### 初始化脚本

```powershell
# 自动完成：检查工作区 → 切 main → 同步远程 → 创建分支 → 验证基线
.\scripts\blog-init.ps1 -Prefix owner -Type <type> -Name <name>
```

### 不用脚本的话，手动步骤

```powershell
git checkout main
git fetch origin main
git checkout -b owner/<type>/<name> origin/main
# ... 编辑 ...
pnpm run check
pnpm run build
git add -A; git commit -m "<type>: 描述"
git push -u origin owner/<type>/<name>
# 在 GitHub 创建 PR
```

---

## 验证

每次推送前**必须**通过：

```powershell
pnpm run check    # 类型检查，发现 frontmatter 错误等
pnpm run build    # 完整构建（icons → LQIPs → Astro → Pagefind）
```

构建比较慢（1-3分钟），但这是最后的防线。

快速验证（跳过构建）：
```powershell
pnpm run check    # 只做类型检查，几秒钟
```

---

## 本地预览

```powershell
pnpm dev
# 访问 http://localhost:4321

# 如果要让局域网/其他设备访问
pnpm dev --host 0.0.0.0
# 访问 http://<你的IP>:4321
```

---

## 常用命令速查

```powershell
# 包管理
pnpm install           # 安装依赖
pnpm run new-post xxx  # 创建新文章

# 开发
pnpm dev               # 开发服务器
pnpm run check         # 类型检查
pnpm run build         # 生产构建
pnpm run preview       # 预览构建结果

# 代码质量
pnpm run format        # 格式化代码
pnpm run lint          # Lint + 自动修复

# Git 工作流
git fetch origin main
git checkout -b owner/<type>/<name> origin/main
git add -A; git commit -m "<type>: 描述"
git push -u origin <branch-name>

# 创建 PR（需安装 GitHub CLI）
gh pr create --title "标题" --body "描述"

# 清理已合并的分支
git checkout main
git branch -d <branch-name>
git push origin --delete <branch-name>
```

---

## 和 AI Agent 协作

绫、萌華、塞娜也可以编辑这个博客。区别：

| | 主人 | AI Agent |
|---|---|---|
| 分支前缀 | `owner/` | `aya/` `moka/` `sena/` |
| 操作方式 | 自己在 GitHub 审核合并 PR | 创建 PR 后**等主人合并** |
| 工作目录 | 主 repo | 独立的 git worktree |

Agent 创建 PR 后会通知主人，主人在 GitHub 上审核并合并即可。

---

## 遇到问题？

- **构建失败**：先检查 frontmatter 格式是否正确
- **推送被拒绝**：确认不是在推 `main`（应该推分支）
- **类型检查报错**：看错误信息，通常是 frontmatter 字段问题
- **想回退改动**：`git checkout .`（未提交的改动）或 `git reset --soft HEAD~1`（撤销最近一次提交）
- **本地和远程不同步/想强制回到远程状态**：`git reset --hard origin/main`（⚠️ 会丢弃所有未提交的改动和本地领先远程的提交，执行前确认不需要保留本地修改）

---

*最后更新：2026-07-04*
