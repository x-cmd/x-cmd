---
name: Debian DEB Release
description: |
  Debian/Ubuntu DEB 包构建与发布专家。
  当用户需要打包、发布 Debian 软件包时使用此 skill。
  支持：(1) 创建 DEBIAN 控制文件，(2) 构建 .deb 包，(3) 提交到 Debian 仓库或 PPA。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Debian DEB Release

Debian/Ubuntu DEB 包构建与发布专家。

> **别名**: `apt` - Ubuntu/Debian 用户也可以使用 `x-cmd release apt` 命令，功能完全相同。

## 官方文档

- [How To Package For Debian](https://wiki.debian.org/HowToPackageForDebian)
- [Debian Policy Manual](https://www.debian.org/doc/debian-policy/)
- [WNPP - Work-Needing and Prospective Packages](https://www.debian.org/devel/wnpp/)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release deb init <dir>` | 初始化 DEBIAN 目录 |
| `x-cmd release deb build <dir>` | 构建 .deb 包（本地）|
| `x-cmd release deb build-docker <dir>` | 使用 Docker 构建 |
| `x-cmd release deb upload <dir>` | 显示发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（权限、脚本格式）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建 DEBIAN 结构：**
```
→ 创建目录结构（DEBIAN/control, postinst, postrm）
→ 设置正确的权限（755 for scripts）
→ 提示填写控制字段
```

**构建流程：**
```
→ 检查 DEBIAN/control 是否存在
→ 确保维护者脚本可执行
→ 执行 dpkg-deb --root-owner-group --build
```

**发布流程：**
```
→ 显示 ITP 邮件格式（如提交到官方仓库）
→ 或显示 PPA 上传步骤
→ 或显示自建仓库方法
```

---

## DEBIAN 结构

```
package/
├── DEBIAN/
│   ├── control       # 包元数据（必须）
│   ├── postinst      # 安装后脚本
│   ├── postrm        # 卸载后脚本
│   ├── preinst       # 安装前脚本
│   └── prerm         # 卸载前脚本
└── usr/              # 包文件
    ├── bin/
    └── share/
```

---

## DEBIAN/control 模板

```
Package: package-name
Version: 1.0.0
Architecture: all
Maintainer: Your Name <your@email>
Description: Package description
 Short description continued on next line
```

---

## 维护者脚本模板

**postinst:**
```bash
#!/bin/sh
set -e
# Post-installation script
exit 0
```

**postrm:**
```bash
#!/bin/sh
set -e
# Post-removal script
exit 0
```

---

## 关键命令参考

```bash
# 构建
dpkg-deb --root-owner-group --build .    # 构建包
dpkg -i package.deb                       # 安装测试

# 官方仓库提交（ITP）
# 发送邮件到 submit@bugs.debian.org
# Subject: ITP: package-name -- description

# PPA 上传
dput ppa:username/ppaname package.changes
```

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `permission denied` | 脚本没有执行权限 | `chmod 755 DEBIAN/*` |
| `control file missing` | 缺少 control 文件 | 创建 DEBIAN/control |
| `package empty` | 没有安装文件 | 确保有 usr/ 等目录 |
