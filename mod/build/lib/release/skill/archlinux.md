---
name: Arch Linux PKGBUILD Release
description: |
  Arch Linux PKGBUILD 包构建与发布专家。
  当用户需要打包、发布 Arch Linux 软件包到 AUR 时使用此 skill。
  支持：(1) 创建 PKGBUILD 文件，(2) 构建 .pkg.tar.* 包，(3) 提交到 AUR。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Arch Linux PKGBUILD Release

Arch Linux PKGBUILD 包构建与 AUR 发布专家。

> **别名**: `pacman` - Arch 用户也可以使用 `x-cmd release pacman` 命令，功能完全相同。

## 官方文档

- [Creating packages](https://wiki.archlinux.org/title/Creating_packages)
- [PKGBUILD Reference](https://man.archlinux.org/man/PKGBUILD.5)
- [AUR Submission Guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release archlinux init <dir>` | 初始化 PKGBUILD 目录 |
| `x-cmd release archlinux build <dir>` | 构建包（本地 makepkg）|
| `x-cmd release archlinux build-docker <dir>` | 使用 Docker 构建 |
| `x-cmd release archlinux upload <dir>` | 显示 AUR 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（校验和、依赖）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建 PKGBUILD：**
```
→ 检测项目类型（Cargo.toml/go.mod/package.json 等）
→ 提取包名/版本/描述
→ 展示摘要（包名、版本、类型、需填写的源码URL）
→ 确认创建？[Y/n]
→ 执行 x-cmd release archlinux init
```

**构建流程：**
```
→ 检测本地 makepkg 是否可用
→ 可用：直接本地构建
→ 不可用：提示使用 build-docker
→ 生成校验和（updpkgsums 或 makepkg -g）
→ 执行构建
```

**AUR 发布流程：**
```
→ 生成 .SRCINFO（makepkg --printsrcinfo）
→ 检查 PKGBUILD 和 .SRCINFO
→ 提示 SSH 配置（如需要）
→ 显示提交步骤
```

---

## PKGBUILD 模板

```bash
# Maintainer: Your Name <your@email>
pkgname=package-name
pkgver=1.0.0
pkgrel=0
pkgdesc="Package description"
arch=('x86_64')
url="https://example.com"
license=('MIT')
depends=()
makedepends=()
source=("$pkgname-$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
    cd "$srcdir/$pkgname-$pkgver"
    ./configure --prefix=/usr
    make
}

package() {
    cd "$srcdir/$pkgname-$pkgver"
    make DESTDIR="$pkgdir" install
}
```

---

## 关键命令参考

```bash
# 构建
makepkg -f              # 强制构建
makepkg -si             # 构建并安装
updpkgsums              # 自动更新校验和

# AUR 发布
makepkg --printsrcinfo > .SRCINFO    # 生成 .SRCINFO
git clone ssh://aur@aur.archlinux.org/PKGNAME.git
```

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `checksum failed` | 源码包校验和不匹配 | 运行 `updpkgsums` |
| `missing dependency` | 缺少构建依赖 | 安装 `makedepends` 中的包 |
| `package() not found` | 未定义 package 函数 | 添加 package() 函数 |
