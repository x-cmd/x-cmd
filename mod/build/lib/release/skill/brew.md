---
name: Homebrew Formula Release
description: |
  Homebrew Formula 构建与发布专家。
  当用户需要创建、发布 Homebrew 软件包到 homebrew-core 或自定义 tap 时使用此 skill。
  支持：(1) 创建 Formula.rb，(2) 构建和测试，(3) 提交 PR 到 homebrew-core。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Homebrew Formula Release

Homebrew Formula 构建与发布专家。

## 官方文档

- [Homebrew Documentation](https://docs.brew.sh/)
- [Acceptable Formulae](https://docs.brew.sh/Acceptable-Formulae)
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)

---

## 核心命令

| 命令 | 说明 |
|------|------|
| `x-cmd release brew init <dir>` | 初始化 Formula.rb |
| `x-cmd release brew build <dir>` | 构建和测试 Formula |
| `x-cmd release brew upload <dir>` | 显示 homebrew-core PR 指引 |

---

## AI 工作流指引

### 设计原则

1. **自动检测 → 批量展示 → 单次确认**
2. **自动修复**常见问题（代码风格、校验和）
3. **只在关键决策点询问**（创建前、提交前）

### 标准流程

**创建 Formula：**
```
→ 检测项目类型（提供下载 URL）
→ 计算 SHA256 校验和
→ 生成 Formula.rb 模板
→ 展示摘要（formula 名、版本、homepage）
```

**构建流程：**
```
→ 运行 brew audit --strict（代码审计）
→ 运行 brew style（风格检查）
→ 执行 brew install --build-from-source
→ 运行 brew test
```

**发布流程：**
```
→ 检查是否满足 homebrew/core 要求
→ 显示 fork/分支/PR 步骤
→ 或显示自定义 tap 方法
```

---

## Formula 模板

```ruby
class PackageName < Formula
  desc "Package description"
  homepage "https://example.com"
  url "https://example.com/package-1.0.0.tar.gz"
  sha256 "SHA256_HASH"
  license "MIT"

  depends_on "go" => :build  # 构建依赖

  def install
    system "make", "build"
    bin.install "bin/package"
  end

  test do
    assert_match "version", shell_output("#{bin}/package --version")
  end
end
```

---

## 关键命令参考

```bash
# 创建 Formula
brew create https://example.com/package-1.0.0.tar.gz

# 审计和测试
brew audit --strict --online --new-formula package
brew style package
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source package
brew test package

# 版本更新
brew bump-formula-pr package --version=1.1.0

# 提交 PR
git checkout -b add-package-name
git add Formula/package.rb
git commit -m "package 1.0.0 (new formula)"
git push origin add-package-name
```

---

## homebrew/core 要求

- 必须从源码构建（非二进制）
- GitHub: >=30 forks OR >=30 watchers OR >=75 stars
- 稳定版本标签
- 官方主页
- 开源许可

---

## 常见错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `audit failed` | 代码审计未通过 | 根据 audit 提示修正 |
| `SHA256 mismatch` | 校验和不匹配 | 重新计算 sha256 |
| `test failed` | 测试未通过 | 修正 test block |
| `build failed` | 构建失败 | 检查 depends_on 和 install 方法 |
