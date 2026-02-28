---
name: Alpine APK Release
description: |
  Alpine Linux APK 包构建与发布专家。
  当用户需要打包、发布 Alpine Linux 软件包时使用此 skill。
  支持：(1) 创建 APKBUILD 文件，(2) 构建 apk 包，(3) 提交到 aports 官方仓库。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Alpine APK Release

Alpine Linux APK 包构建与发布专家。

## 官方文档

- [Creating an Alpine package](https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package)
- [APKBUILD Reference](https://wiki.alpinelinux.org/wiki/APKBUILD_Reference)
- [COMMITSTYLE.md](https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/COMMITSTYLE.md)
- [CODINGSTYLE.md](https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/CODINGSTYLE.md)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release apk init <dir>` | 初始化 APKBUILD 目录 |
| `x-cmd release apk build <dir>` | 构建 apk 包（本地或 Docker）|
| `x-cmd release apk upload` | 显示发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（依赖缺失、校验和错误）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建 APKBUILD：**
```
→ 检测项目类型（Cargo.toml/go.mod/package.json 等）
→ 提取包名/版本/描述
→ 展示摘要（包名、版本、类型、需填写的源码URL）
→ 确认创建？[Y/n]
→ 执行 x-cmd release apk init
```

**构建包：**
```
→ 执行 x-cmd release apk build
→ 自动：keygen → lint → checksum → build
→ 成功：告知包位置
→ 失败：分析错误，尝试自动修复
```

**发布到 Alpine：**
```
→ 检查 .apk 文件
→ 准备 aports 提交
→ 确认提交？[Y/n]
```

---

## APKBUILD 核心要点

### 必备变量

```bash
maintainer="Name <email>"     # Alpine 特有要求
pkgname=package-name           # 必须小写
pkgver=1.0.0                  # 版本
pkgrel=0                       # 修订号（从0开始）
pkgdesc="Description"
url="https://example.com"
arch="x86_64"                 # all/noarch/x86_64/!排除
license="MIT"
source="$pkgname-$pkgver.tar.gz"
sha512sums="..."              # abuild checksum 生成
```

### 关键函数

```bash
build() {
    cd "$builddir"
    ./configure --prefix=/usr
    make
}

check() {
    cd "$builddir"
    make check
}

package() {
    cd "$builddir"
    make DESTDIR="$pkgdir" install
}
```

### Alpine 特有概念

| 概念 | 说明 |
|------|------|
| `arch` | `all`(全部), `noarch`(架构无关), `!arch`(排除特定架构) |
| `depends` | 运行时依赖（so 依赖自动检测，无需手动指定） |
| `makedepends` | 构建时依赖 |
| `source` | 支持 URL 重命名语法：`filename::url` |
| `subpackages` | 子包定义：`$pkgname-dev $pkgname-doc` |
| 安装脚本 | `$pkgname.pre-install`, `$pkgname.post-install` 等 |

---

## 提交到 aports

### 提交规范

| 类型 | 格式 |
|------|------|
| 新增 | `testing/foo: new aport` |
| 升级 | `main/foo: upgrade to 1.2.3` |
| 降级 | `main/foo: downgrade to 1.2.2` |
| 移动 | `community/foo: move from main` |
| 重命名 | `community/bar: rename from foo` |

### 提交流程

1. Fork [gitlab.alpinelinux.org/alpine/aports](https://gitlab.alpinelinux.org/alpine/aports)
2. 创建分支 `add/<pkgname>`（不要用 master）
3. 在 `testing/<pkgname>/` 创建 APKBUILD
4. 运行 `abuild checksum` 和 `apkbuild-lint`
5. 提交并创建 Merge Request

```bash
git checkout -b add/foo
git add testing/foo/
git commit -m "testing/foo: new aport

https://example.com/foo"
git push origin add/foo
```

---

## 代码风格

- **缩进**: Tab（不是空格）
- **引号**: 变量 `"$var"`，但 `pkgver`/`pkgname` 除外
- **变量**: 辅助变量用 `_` 前缀
- **函数**: 辅助函数用 `_` 前缀
- **元数据顺序**: maintainer → pkgname/pkgver/pkgrel → depends → source → sha512sums → 函数

---

## 辅助工具

```bash
# Python 包
apkbuild-pypi create <package>

# Perl 包  
apkbuild-cpan create <Module::Name>

# 通用模板
newapkbuild <package-name>
```

---

## 使用示例

```bash
# 创建 APKBUILD
x-cmd release apk init mypackage

# 构建包
x-cmd release apk build mypackage

# 询问 AI
x-cmd release apk --claude 如何为 Rust 项目创建 APKBUILD？
```
