---
name: Rust Cargo Release
description: |
  Rust Cargo crate 构建与发布专家。
  当用户需要打包、发布 Rust crate 到 crates.io 时使用此 skill。
  支持：(1) 创建 Cargo 项目，(2) 构建和测试，(3) 发布到 crates.io。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Rust Cargo Release

Rust Cargo crate 构建与发布专家。

## 官方文档

- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Publishing on crates.io](https://doc.rust-lang.org/cargo/reference/publishing.html)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release cargo init <dir>` | 初始化 Cargo 项目 |
| `x-cmd release cargo build <dir>` | 构建和测试 |
| `x-cmd release cargo upload <dir>` | 显示 crates.io 发布指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（格式化、lint 问题）
3. **只在关键决策点询问**（创建前、发布前）

### 标准流程

**创建项目：**
```
→ 创建 Cargo.toml 和 src/main.rs
→ 填充基本元数据（name, version, author）
→ 提示填写 description 和 repository
```

**构建流程：**
```
→ cargo fmt --check（格式化检查）
→ cargo clippy（代码检查）
→ cargo test（运行测试）
→ cargo build --release（发布构建）
```

**发布流程：**
```
→ 检查 Cargo.toml 完整性
→ 提示登录 crates.io（cargo login）
→ 显示 cargo publish 步骤
```

---

## Cargo.toml 模板

```toml
[package]
name = "package-name"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your@email>"]
description = "Package description"
license = "MIT"
repository = "https://github.com/username/package"

[dependencies]

[dev-dependencies]
```

---

## 关键命令参考

```bash
# 开发
cargo build                    # 调试构建
cargo build --release         # 发布构建
cargo test                     # 运行测试
cargo fmt                      # 格式化代码
cargo clippy                   # 代码检查

# 发布
cargo login <token>            # 登录 crates.io
cargo publish --dry-run        # 干运行测试
cargo publish                  # 发布到 crates.io
cargo yank --vers 0.1.0        # 撤回版本（紧急）
```

---

## crates.io 要求

- 包名必须唯一（全局）
- 必须有 license 或 license-file
- 推荐包含：description, repository, homepage
- 版本遵循语义化版本（SemVer）

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `name already exists` | 包名已被占用 | 更换包名 |
| `version already exists` | 版本已发布 | 递增版本号 |
| `description is empty` | 缺少描述 | 添加 description |
| `unauthorized` | 未登录或 token 过期 | 运行 cargo login |
