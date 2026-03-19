---
name: Node.js NPM Release
description: |
  Node.js NPM 包构建与发布专家。
  当用户需要打包、发布 JavaScript/TypeScript 包到 npm 时使用此 skill。
  支持：(1) 创建 npm 项目，(2) 构建和测试，(3) 发布到 npm registry。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Node.js NPM Release

Node.js NPM 包构建与发布专家。

## 官方文档

- [npm Docs](https://docs.npmjs.com/)
- [Package.json](https://docs.npmjs.com/cli/v10/configuring-npm/package-json)
- [Publishing packages](https://docs.npmjs.com/packages-and-modules/contributing-packages-to-the-registry)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release npm init <dir>` | 初始化 npm 项目 |
| `x-cmd release npm build <dir>` | 构建和测试 |
| `x-cmd release npm upload <dir>` | 显示 npm 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（依赖安装、格式化）
3. **只在关键决策点询问**（创建前、发布前）

### 标准流程

**创建项目：**
```
→ 创建 package.json
→ 填充基本元数据（name, version, description）
→ 创建入口文件 index.js
```

**构建流程：**
```
→ npm ci 或 npm install（安装依赖）
→ npm test（运行测试）
→ npm run lint（代码检查，如果有）
```

**发布流程：**
```
→ 检查版本号是否已存在（npm view）
→ 提示登录 npm（npm login）
→ npm publish 或 npm publish --access public
```

---

## package.json 模板

```json
{
  "name": "@scope/package-name",
  "version": "0.1.0",
  "description": "Package description",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "Your Name <your@email>",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/username/repo.git"
  }
}
```

---

## 关键命令参考

```bash
# 开发
npm install                    # 安装依赖
npm ci                         # 严格按 lock 安装
npm test                       # 运行测试
npm run build                  # 构建（如有）

# 版本管理
npm version patch              # 0.1.0 -> 0.1.1
npm version minor              # 0.1.0 -> 0.2.0
npm version major              # 0.1.0 -> 1.0.0

# 发布
npm login                      # 登录
npm publish                    # 发布
npm publish --access public    # 发布 scoped 包（公开）
npm publish --tag beta         # 发布 beta 标签
npm unpublish package@version  # 撤回（24小时内）
```

---

## npm 包要求

- 包名必须小写，可用 `-` 连接
- Scoped 包（@scope/name）首次发布需 `--access public`
- 版本遵循语义化版本（SemVer）
- 邮箱必须验证才能发布

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `E403` | 包名被占用或未验证邮箱 | 更换名字或验证邮箱 |
| `E401` | 未登录 | 运行 npm login |
| `E404` | Scoped 包未指定 --access | 添加 --access public |
| `EPUBLISHCONFLICT` | 版本已存在 | 递增版本号 |
