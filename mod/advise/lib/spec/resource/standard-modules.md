# 标准模块白名单

> **AI 学习 advise 请执行**: `x advise spec show`
>
> 本文档是 advise 规范的标准模块参考，完整的 advise 规则见 `x advise spec show`。

---

## 1. 标准模块列表

| 模块 | 说明 | 特点 |
|------|------|------|
| **bwh** | BandwagonHost VPS 管理器 | 多段式 advise、`<ref>` 外部引用、复杂子命令结构 |
| **line** | 行处理函数 | 集合操作、子命令分类、`<tip>` 模块级别说明 `_` 变体 |
| **tldr** | TLDR 命令（基于标准扩展） | `<web>` 字段展示、`<case>` 用例模式、`<ref>` 外部引用、`tlfz` 快捷命令 |
| **assert** | 测试断言模块 | 效率模块标记（`subcmd-help: disable`）、批量操作、TLDR 在根级别 |
| **uuid** | UUID 生成器 | 清晰的子命令分类、示例丰富 |
| **timeout** | 命令超时封装 | 选项模式、多信号支持 |
| **str** | 字符串处理 | 效率模块、子命令无 help |

---

## 2. 模块分级

### 2.1 一级标准（完整规范）

**bwh** - 最完整的模块结构示例
- 多级子命令分类
- `<ref>` 外部引用（复杂子命令拆分）
- 完整的 `<tldr>` 示例
- 清晰的中英文描述

**line** - 最佳实践参考
- 模块级别 `<tip>` 统一说明 `_` 变体
- 子命令分类合理
- 示例覆盖主要功能

### 2.2 二级标准（良好实践）

**timeout** - 选项模式示例
- synopsis 清晰
- 选项定义规范
- tip 说明时间格式

**user** - 普通模块示例
- 子命令定义规范
- 带 `_` 变体说明

**passwd** - 选项模式（无子命令）
- 直接输出，无子命令
- 自动 TTY 检测

### 2.3 三级标准（基础参考）

**tmp** - 基础模块
- 基本结构完整
- 需要补充更多示例

**home** - 主目录管理
- 结构完整
- 某些子命令未实现（TODO）

---

## 3. 模块结构模式

### 3.1 传统子命令模式（bwh、line、user）

```yaml
<name>:
  <module>:
  cn: 中文名
  en: English name

<subcmd:分类>:
  - subcmd1
  - subcmd2

subcmd1:
  <desc>:
    cn: 描述
    en: Description
  <tldr>: ...
```

### 3.2 选项模式（timeout、passwd）

```yaml
<name>:
  <module>:
  cn: 中文名
  en: English name

<synopsis>:
  - x <module> [options]

--option1:
  <desc>: ...
```

### 3.3 效率模块模式（assert、str）

```yaml
<meta>:
  subcmd-help: disable

<tldr>:
  - cmd: x <module> op1 1 2 3
    cn: "测试: 批量操作"

op1:
  <desc>: ...
```

### 3.4 外部引用模式（bwh complex subcommands）

```yaml
<subcmd>:
  <desc>: ...
  <ref>: "x-advise://<module>/data/<subcmd>.jso"
```

### 3.5 外部标准扩展模式（tldr）

基于外部标准（如 TLDR Pages）扩展的模块，使用 `<web>` 提供网站展示内容：

```yaml
<name>:
  tldr:
  cn: TLDR 命令
  en: TLDR command

<desc>:                     # 简短描述
  cn: 简短的模块描述
  en: Brief module description

<web>:                      # 网站展示用的详细文档
  desc:
    cn: |
      ## 介绍
      详细的模块介绍...
    en: |
      ## Introduction
      Detailed module description...

<subcmd>: ...               # 子命令定义
```

**注意**：`tlfz` 不是独立模块，而是 `tldr --fz` 的快捷命令别名。

---

## 4. 参考文件

- **bwh**: `/Users/l/.x-cmd.root/v/.repo/x-bash/bwh/adv/index.yml` - 多段式复杂模块
- **line**: `/Users/l/.x-cmd.root/v/.repo/x-bash/line/adv/index.yml` - `_` 变体规范
- **assert**: `/Users/l/.x-cmd.root/v/.repo/x-bash/assert/adv/index.yml` - 效率模块
- **timeout**: `/Users/l/.x-cmd.root/v/.repo/x-bash/timeout/adv/index.yml` - 选项模式
- **passwd**: `/Users/l/.x-cmd.root/v/.repo/x-bash/passwd/adv/index.yml` - 纯选项模式

---

*创建: 2026-05-04*