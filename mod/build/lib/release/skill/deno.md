---
name: Deno Release
description: |
  Deno 模块构建与发布专家。
  当用户需要打包、发布 Deno 模块到 JSR (jsr.io) 或 deno.land/x 时使用此 skill。
  支持：(1) 创建 Deno 项目，(2) 类型检查和测试，(3) 发布到 JSR。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Deno Release

Deno 模块构建与发布专家。

## 官方文档

- [Deno Manual](https://docs.deno.com/)
- [JSR Documentation](https://jsr.io/docs/)
- [deno.land/x](https://deno.land/x)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release deno init <dir>` | 初始化 Deno 项目 |
| `x-cmd release deno build <dir>` | 类型检查和测试 |
| `x-cmd release deno upload <dir>` | 显示 JSR 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（格式化、类型错误）
3. **只在关键决策点询问**（创建前、发布前）

### 标准流程

**创建项目：**
```
→ 创建 deno.json
→ 创建 mod.ts
→ 配置 exports 和 imports
```

**构建流程：**
```
→ deno fmt --check（格式化检查）
→ deno lint（代码检查）
→ deno check **/*.ts（类型检查）
→ deno test -A（运行测试）
```

**发布流程：**
```
→ deno login（登录 JSR）
→ deno publish --dry-run（干运行）
→ deno publish（发布）
```

---

## deno.json 模板

```json
{
  "name": "@scope/package-name",
  "version": "0.1.0",
  "exports": {
    ".": "./mod.ts",
    "./utils": "./utils.ts"
  },
  "imports": {
    "$std/": "https://deno.land/std@0.220.0/"
  },
  "tasks": {
    "test": "deno test -A",
    "fmt": "deno fmt",
    "lint": "deno lint"
  },
  "publish": {
    "include": ["*.ts", "README.md", "LICENSE"]
  }
}
```

---

## 关键命令参考

```bash
# 开发
deno run main.ts              # 运行
deno test -A                  # 运行测试
deno fmt                      # 格式化
deno fmt --check              # 检查格式
deno lint                     # 代码检查
deno check **/*.ts            # 类型检查

# 发布
deno login                    # 登录 JSR
deno publish --dry-run        # 干运行测试
deno publish                  # 发布到 JSR
```

---

## JSR 要求

- 包名必须是 JSR scope（@scope/name）
- 必须包含 JSDoc 文档
- 必须通过 deno check
- 推荐使用 HTTPS 导入

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `Missing JSDoc` | 缺少文档注释 | 为导出添加 JSDoc |
| `Type error` | 类型检查失败 | 修复类型错误 |
| `Not authorized` | 未登录 | 运行 deno login |
| `Name taken` | 包名被占用 | 更换 scope 或名称 |
