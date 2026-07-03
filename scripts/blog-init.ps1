# blog-init.ps1 — 博客编辑初始化脚本 (Windows / PowerShell 版)
# 用法: .\scripts\blog-init.ps1 -Prefix <prefix> -Type <type> -Name <name>
#   prefix: owner
#   type:   content / feat / fix / style
#   name:   分支名（如 my-article, add-tags）
# 示例: .\scripts\blog-init.ps1 -Prefix owner -Type content -Name my-first-article

param(
    [Parameter(Mandatory=$true)][ValidateSet("owner")][string]$Prefix,
    [Parameter(Mandatory=$true)][ValidateSet("content","feat","fix","style","refactor","chore")][string]$Type,
    [Parameter(Mandatory=$true)][string]$Name
)

$ErrorActionPreference = "Stop"
$Branch = "${Prefix}/${Type}/${Name}"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Harkoryx Blog 编辑初始化 (Windows)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: 检查工作区状态 ---
Write-Host "🔍 Step 1/7: 检查工作区状态..." -ForegroundColor Yellow
$status = git status --porcelain 2>$null
if ($status) {
    Write-Host "⚠️  工作区有未提交的改动：" -ForegroundColor Red
    Write-Host $status
    Write-Host ""
    Write-Host "请先处理以上改动，然后再运行初始化。"
    Write-Host "  放弃: git checkout ."
    Write-Host "  保存: git add -A; git commit -m 'WIP'"
    exit 1
}
Write-Host "✅ 工作区干净" -ForegroundColor Green

# --- Step 2: 确认在 main ---
Write-Host ""
Write-Host "🔄 Step 2/7: 确认在 main 分支..." -ForegroundColor Yellow
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "  当前在 $currentBranch，切回 main"
    git checkout main
} else {
    Write-Host "  已在 main"
}
Write-Host "✅ 已在 main" -ForegroundColor Green

# --- Step 3: 同步远程 ---
Write-Host ""
Write-Host "🔄 Step 3/7: 同步远程 main..." -ForegroundColor Yellow
git fetch origin main
Write-Host "✅ 已获取最新 origin/main" -ForegroundColor Green

# --- Step 4: 创建分支 ---
Write-Host ""
Write-Host "🌿 Step 4/7: 创建分支 $Branch (基于 origin/main)..." -ForegroundColor Yellow
$branchExists = git show-ref --verify --quiet "refs/heads/$Branch" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "⚠️  分支 $Branch 已存在！" -ForegroundColor Red
    Write-Host "  如果要继续上次的工作: git checkout $Branch"
    Write-Host "  如果要重新开始: 先删除旧分支 git branch -D $Branch"
    exit 1
}
git checkout -b $Branch origin/main
Write-Host "✅ 已创建并切换到分支 $Branch" -ForegroundColor Green

# --- Step 5: 确认依赖 ---
Write-Host ""
Write-Host "📦 Step 5/7: 确认依赖..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "安装依赖中..."
    pnpm install
}
Write-Host "✅ 依赖就绪" -ForegroundColor Green

# --- Step 6: 类型检查基线 ---
Write-Host ""
Write-Host "🔍 Step 6/7: 类型检查基线..." -ForegroundColor Yellow
pnpm astro check 2>&1 | Select-Object -Last 5
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 类型检查失败！" -ForegroundColor Red
    git checkout main
    git branch -D $Branch 2>$null
    exit 1
}
Write-Host "✅ 类型检查通过" -ForegroundColor Green

# --- Step 7: 构建验证基线 ---
Write-Host ""
Write-Host "🏗️  Step 7/7: 构建验证基线..." -ForegroundColor Yellow
pnpm run build 2>&1 | Select-Object -Last 5
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 基线构建失败！" -ForegroundColor Red
    git checkout main
    git branch -D $Branch 2>$null
    exit 1
}
Write-Host "✅ 基线构建通过" -ForegroundColor Green

# --- 完成 ---
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  ✅ 初始化完成！" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  分支: $Branch"
Write-Host ""
Write-Host "  现在可以开始编辑了。"
Write-Host "  完成后运行:"
Write-Host "    pnpm run check && pnpm run build  # 验证"
Write-Host "    git add -A; git commit -m '${Type}: <描述>'"
Write-Host "    git push -u origin $Branch"
Write-Host "    # 然后在 GitHub 创建 PR 并合并"
Write-Host ""
