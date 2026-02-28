---
name: asdf Plugin Release
description: |
  asdf 版本管理器插件构建与发布专家。
  当用户需要创建、发布 asdf 插件时使用此 skill。
  支持：(1) 创建 asdf 插件结构，(2) 编写必要脚本，(3) 注册到 asdf-plugins。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# asdf Plugin Release

asdf 版本管理器插件构建与发布专家。

## 官方文档

- [asdf Create Plugins](https://asdf-vm.com/plugins/create.html)
- [asdf Plugins Repository](https://github.com/asdf-vm/asdf-plugins)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release asdf init <dir>` | 初始化 asdf 插件 |
| `x-cmd release asdf build <dir>` | 验证插件结构 |
| `x-cmd release asdf upload <dir>` | 显示发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（脚本权限、格式）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建插件：**
```
→ 创建 bin/list-all（列出所有版本）
→ 创建 bin/install（安装指定版本）
→ 创建 bin/download（下载源码）
→ 设置脚本权限
```

**验证流程：**
```
→ 检查脚本存在
→ 检查脚本可执行
→ 测试本地安装
```

**发布流程：**
```
→ 推送到 GitHub
→ Fork asdf-plugins
→ 提交 PR 注册
```

---

## 插件结构

```
asdf-plugin-name/
├── bin/
│   ├── list-all           # 列出所有可用版本
│   ├── install            # 安装指定版本
│   ├── download           # 下载源码（可选）
│   ├── list-bin-paths     # 添加 PATH（可选）
│   └── exec-env           # 设置环境变量（可选）
├── README.md              # 使用说明
└── LICENSE                # 许可证
```

---

## 脚本模板

**bin/list-all:**
```bash
#!/usr/bin/env bash
set -euo pipefail

curl -s https://api.github.com/repos/owner/repo/releases | \
  grep -o '"tag_name": "[^"]*"' | \
  sed 's/"tag_name": "//;s/"$//' | \
  sort -V
```

**bin/install:**
```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$ASDF_INSTALL_PATH/bin"
# Download and install logic here
curl -L "$download_url" | tar -xz -C "$ASDF_INSTALL_PATH/bin"
```

---

## 关键命令参考

```bash
# 本地测试
asdf plugin add my-plugin /path/to/local/plugin
asdf list-all my-plugin
asdf install my-plugin 1.0.0
asdf global my-plugin 1.0.0

# 发布
# 1. Push to GitHub
# 2. Fork asdf-vm/asdf-plugins
# 3. Add plugins/my-plugin with repo URL
# 4. Submit PR
```

---

## asdf 插件要求

- 仓库名必须是 `asdf-<tool-name>`
- 必须有 `bin/list-all` 和 `bin/install`
- 脚本必须可执行
- 必须处理环境变量（ASDF_INSTALL_VERSION, ASDF_INSTALL_PATH）

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `list-all failed` | 无法获取版本列表 | 检查 API 或正则表达式 |
| `install failed` | 下载或解压失败 | 检查 URL 和归档格式 |
| `command not found` | PATH 未设置 | 添加 list-bin-paths 脚本 |
