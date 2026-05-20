# X-CMD Advise Specification

> **版本**: v0
> **状态**: 当前规范
> **适用范围**: X-CMD 模块开发
>
> **v1 升级预告**（待实现）:
> - 引入 `<option>` 字段明确标识选项，而非依赖 `-` 前缀判断
> - 当前选项默认写法（以 `-` 开头）将变为显式 `<option>:` 包裹

---

## 零、系统概述

Advise 是 x-cmd 的**命令补全系统**，通过声明式的 YAML 配置文件定义命令的补全规则。

**配套文档**（同目录下，互为参考，同时更新）：

| 文件 | 用途 |
|------|------|
| `spec.md`（本文件） | advise 编写规范：字段定义、编写原则、示例、错误模式 |
| `rule/advise.rule.yml` | `x check` / `x rule` 使用的检查规则集，与 spec.md 中的原则一一对应 |

> 修改 spec.md 中的任何原则时，应同步更新 rule.yml 中对应的规则；反之亦然。

### 核心特性

- **声明式配置**：使用 YAML 定义补全规则，无需编写 Shell 代码
- **多 Shell 支持**：单一配置适配 bash、zsh、fish、nu、elvish、xonsh、tcsh
- **动态补全**：支持通过命令动态生成补全候选项
- **国际化**：支持中英文描述切换
- **层级结构**：支持子命令、选项、位置参数的嵌套定义

### 重要声明

> **⚠️ JSO 不是 JSON 文件！**
>
> `.jso` 是由 JSON **后处理**生成的二进制优化格式：
> - 不可直接编辑
> - 不可直接用 JSON 解析器读取
> - 由 x-cmd 内部专用工具生成和使用

---

## 一、三操作关系总览

Advise 与以下三个操作紧密关联：

| 操作 | 内容来源 | 说明 |
|------|----------|------|
| `x help -m <mod> [subcmd]` | 读取 advise.jso | TLDR、desc 最终显示位置 |
| TLDR 内容 | 先写入 `x advise spec show` 输出 | 后续再拆分到 `x tldr` 模块 |
| advise shell 代码 | 主要在 x-cmd-spec | `x advise spec show` 适当引用 |

**核心原则**:
- `adv/index.yml` 是唯一源文件
- 转换流程: `adv/index.yml` → `x y2j` → JSON → 后处理 → `advise.jso`
- `advise.jso` 是二进制优化格式，**不可直接编辑**

---

## 二、文件结构

### 2.1 文件位置

| 文件类型 | 路径 | 说明 |
|---------|------|------|
| 源文件 | `<module>/adv/index.yml` | YAML 格式，开发者编辑 |
| 生成文件 | `$___X_CMD_ROOT_ADV/<module>/advise.jso` | 二进制格式，系统自动生成 |

### 2.2 标准字段顺序

```yaml
<name>              # 模块名称（必需）
<meta>              # 元数据配置（可选）
<synopsis>          # 命令用法示例（必需）
<desc>              # 模块描述（必需）
<tip>               # 使用提示（推荐）
<tldr>              # 常用示例（必需）
<subcmd:Category>   # 子命令分类列表（可选）
<subcmd-definitions> # 子命令定义（根级别，与 <name> 同级）
<other>             # 其他信息（可选）
```

**顺序规则**:
- `<tip>` 必须在 `<desc>` 之后、`<tldr>` 之前
- `<subcmd:Category>` 在 `<tldr>` 之后、子命令定义之前
- 子命令定义在根级别，与 `<name>`、`<desc>` 同级

---

## 三、字段规范

### 3.1 `<name>` - 模块名称

```yaml
<name>:
  <module_name>:        # 模块名（如 host、assert）
  cn: 中文名称           # 中文显示名
  en: English Name      # 英文显示名
```

### 3.2 `<meta>` - 元数据配置

```yaml
<meta>:
  default-subcmd: <subcmd_name>    # 默认子命令
  trailing-option: true|false      # 是否支持后置选项
  <subcmd-help>: disable             # 效率模块标记
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `default-subcmd` | string | 当用户只输入模块名时使用的默认子命令 |
| `trailing-option` | boolean | 是否支持选项出现在位置参数之后 |
| `<subcmd-help>` | string | `disable` 表示子命令无 help 支持（效率模块） |

### 3.3 `<synopsis>` - 命令用法

```yaml
<synopsis>:
  - x <module> [name-and-alias-of-subcmd] [options] [args...]:
  - x <module> <name-of-subcmd> <args>:
```

**注意**: `<synopsis>` **只能在模块级别**定义，子命令/选项级别不可使用。

**⚠️ 重要规则：选项必须前置**

在 synopsis、tldr、所有文档示例中，**选项（option）必须放在参数（argument）之前**。

| 类型 | 示例 |
|------|------|
| ✅ 正确 | `x ccal info --yml 2026-05-09` |
| ❌ 错误 | `x ccal info 2026-05-09 --yml` |
| ✅ 正确 | `x ccal tiaoxiu -n 30 2026-05-01` |
| ❌ 错误 | `x ccal tiaoxiu 2026-05-01 -n 30` |

**说明**：
- 选项包括：`--<flag>`、`--<key> <value>`、`-<short>`
- 代码层面可以支持选项后置，但文档中**绝对不要鼓励这种写法**
- 这是 x-cmd 的设计规范，必须遵守

### 3.4 `<desc>` - 模块描述

```yaml
<desc>:
  cn: |
    第一行描述。

    功能特点：
    - 特点 1
    - 特点 2
  en: |
    First line description.

    Features:
    - Feature 1
    - Feature 2
```

### 3.5 `<tip>` - 使用提示

`<tip>` 是**列表格式**，不同事项分项列举，每项聚焦一个要点。可以在**模块级别**和**子命令级别**使用。

**模块级别 tip**：
```yaml
<tip>:
  - cn: |
      使用提示：
      1. 提示内容 1
      2. 提示内容 2
    en: |
      Usage tips:
      1. Tip content 1
      2. Tip content 2
```

**子命令级别 tip**：
```yaml
<subcmd>:
  <desc>: ...
  <tip>:
    - cn: "要点1：xxx"
      en: "Point 1: xxx"
    - cn: "要点2：xxx"
      en: "Point 2: xxx"
```

**tip 使用原则**：
- **避免 desc 过于冗长**：详细的说明应该拆到 tip 中，而不是堆在 desc 里
- **每项只讲一个要点**：tip 是列表，每项聚焦一个点
- **子命令 tip 放在 subcmd 定义下**：子命令级别的 tip 随 subcmd 定义走
- **特定行为的提示**：当子命令有非显而易见的行为（如 auto 格式切换）时，应在 tip 中说明。这是模块特定的，不是所有模块都需要：
  ```yaml
  # 仅当子命令确实有 auto 格式切换时才写这条 tip
  <tip>:
    - cn: "不带格式选项时，交互终端下以 csv app 浏览，管道或重定向则以 TSV 输出。"
      en: "Without a format flag, interactive terminals open csv app; pipe or redirect outputs TSV."
  ```

---

### 3.6 `<tldr>` - 常用示例

```yaml
<tldr>:
  - cmd: x <module> <name-of-subcmd> <args>    # 命令示例
    cn: "示例: 中文描述"                        # 中文描述
    en: "Example: English description"          # 英文描述
```

**核心定位**:
- TLDR 是 **help 的入口**，协助 AI agent 和人类用户清晰了解如何使用模块
- 帮助 AI 快速理解模块能力，建立初步认知
- 帮助人类用户通过场景化示例快速上手
- 引导 AI 和人类在需要时通过 `x <mod> <subcmd> --help` 获取详细信息

**目标读者与行文原则**:

> advise 的主要服务对象是**人类专家 + AI agent**（codex、openclaw 等）。
> 行文追求：**精炼且信息量大**。砍无效词，保留有区分度的信息。
>
> 人类新手是次要考虑，通过"逐步深入"的排列梯度降低门槛：
> - 第一个 tldr/tip — 最简单、最直觉的用法
> - 中间 — 核心场景，信息密度高
> - 后面 — 进阶场景、边界情况、脚本集成
>
> 当专家信息密度需求与新手友好冲突时，**优先信息密度**。
> 人类新手可以通过 agent 辅助理解，所以信息密度不会真正排斥新手。

**写作优先级**:
1. **先把功能和场景用法讲清楚** — 事情说到位，用户能理解、能用起来
2. **再考虑精简篇幅** — 清晰度永远优先于简洁性；宁可多写两句把场景交代完整，不要为了短而丢信息
3. **砍无效词** — 删掉不影响理解的词（如上下文已暗示的"格式输出"），保留有区分度的词（如"带表头"、"适合管道"）

---

## 3.6.1 TLDR 编写核心原则

### ⚠️ 首要规则：选项必须前置

**TLDR 中的命令示例，选项必须放在参数之前：**

| 正确示例 | 错误示例 |
|---------|---------|
| `x ccal info --yml 2026-05-09` | `x ccal info 2026-05-09 --yml` |
| `x ccal ls --yml 2026-05` | `x ccal ls 2026-05 --yml` |
| `x ccal tiaoxiu -n 30` | `x ccal tiaoxiu 2026-05-01 -n 30` |

**代码可能支持选项后置，但 TLDR 中绝对不要这样写！**

### 1. 顶层 tldr 引导 AI 认知
- 每个模块的 help 顶层 tldr 很重要，应该尽量引导 AI 了解常用功能
- AI 通过 tldr 建立对模块能力的第一印象

### 2. 第一个 tldr：最常用、最有吸引力的场景
- 第一个 tldr 面向**最常用、最有吸引力的场景**
- 应该**尽量简单**：不带多余的选项，用最自然的调用方式
- 让人一看就知道"这个模块是做什么的"，一用即有结果
- 对于工具类模块，第一个 tldr 通常是 `x <mod>`（不带参数）或 `x <mod> info`

**反例**：第一个 tldr 就带 `--csv` 或 `--json`，增加了不必要的认知负担。

### 3. 场景适用原则（优先于"展示最强能力"）
- **每个 tldr 面向一个具体场景**，不是为了展示参数组合
- 同类别选项（如 `--csv`/`--tsv`/`--json`）只需各出现一次，除非某场景确实更适合某种格式
- 格式选项集中在前几条 tldr 展示，后续条目聚焦功能和场景
- "展示最强能力"是次要原则，当与场景适用冲突时让位

```yaml
# ✅ 正确 — 格式选项只在前几条展示，后面聚焦场景
<tldr>:
  - cmd: x dbnomics align imf.us.cpi imf.de.cpi imf.jp.cpi
    cn: "对比美/德/日 CPI，交互终端以 csv app 浏览，管道则以 TSV 输出"
  - cmd: x dbnomics align --csv imf.us.gdp imf.cn.gdp
    cn: "CSV 格式: 对比美/中 GDP，适合数据库导入、表格软件或脚本处理"
  - cmd: x dbnomics align --tsv fed.10y fed.2y fed.3m
    cn: "TSV 格式: 对比美国国债收益率曲线，适合管道和 awk/grep 处理"
  - cmd: x dbnomics align imf.us.unemployment imf.de.unemployment
    cn: "对比美/德失业率"                                     # 后续聚焦场景，除非场景需要否则不带格式选项

# ❌ 错误 — 每个 tldr 都带格式选项，且描述不说明场景差异
<tldr>:
  - cmd: x dbnomics align --csv imf.us.cpi imf.de.cpi
  - cmd: x dbnomics align --csv imf.us.gdp imf.cn.gdp
  - cmd: x dbnomics align --csv imf.us.unemployment imf.de.unemployment
```

### 4. 后续 tldr：让 AI 知道能获得什么工具
- 后续 tldr 主要让 AI 知道能获得什么工具/能力
- 展示模块的核心功能和适用场景
- AI 可以反推用 `x <mod> <subcmd> --help` 来看更多细节

### 5. 不怕重复，不同角度多场景描述
- **不用担心重复**：上层 subcmd 可能会与重要子 subcmd 的 tldr 重合
- **多角度描述**：同一功能可以从不同使用场景描述
- **提供更多选择**：AI 可以根据不同场景选择合适的命令

### 6. 描述前缀规范
| 前缀 | 用途 | 示例 |
|------|------|------|
| `"示例: xxx"` | 功能模块 | `"示例: 查看主机信息"` |
| `"测试: xxx"` | 测试模块 | `"测试: 验证整数类型"` |
| `"警告: xxx"` | 危险操作 | `"警告: 删除不可恢复"` |

### 7. 展示最强能力（次要原则）
- 多值、批量、复杂模式 > 单值简单模式
- 让 AI 知道模块的上限能力
- **当与场景适用原则冲突时，让位于场景适用**

### 8. 文档中使用 `--help` 而非 `-h`
- 在 tldr、tip、desc 等所有文档中，引用帮助信息时使用 `--help` 而非 `-h`
- 前提是命令确实提供 `--help`

```yaml
# ✅ 正确
- cn: "详情参见 x dbnomics align --help"
- cn: "别名和完整 ID 详见 x dbnomics --help"

# ❌ 错误
- cn: "详情参见 x dbnomics align -h"
```

---

## 3.6.2 TLDR 编写示例

**好的 TLDR 结构（多角度）**：

```yaml
<tldr>:
  # 第一个：最简单、最自然的调用
  - cmd: x host
    cn: "示例: 交互式查看 hosts 文件"
    en: "Example: interactive view hosts file"

  # 后续：多角度展示能力
  - cmd: x host cat
    cn: "示例: 管道方式获取 hosts 内容"
    en: "Example: get hosts content via pipe"

  - cmd: x host get localhost
    cn: "示例: 查询指定主机名的 IP"
    en: "Example: lookup IP for hostname"

  - cmd: x host ls
    cn: "示例: 列出所有主机名"
    en: "Example: list all hostnames"

  - cmd: x host app
    cn: "示例: 交互式模糊查找主机"
    en: "Example: interactive fuzzy search hosts"
```

**好的 TLDR 结构（场景化、含格式选项）**：

对于支持多种输出格式的子命令，第一条不带格式选项（最自然的调用），格式选项各出现一次，后续聚焦场景。

> **参考示例**：执行 `x dbnomics align --help` 查看完整输出。

```yaml
<tldr>:
  # 第一条：不带格式选项，描述说明默认行为
  - cmd: x dbnomics align imf.us.cpi imf.de.cpi imf.jp.cpi
    cn: "对比美/德/日 CPI，交互终端以 csv app 浏览，管道则以 TSV 输出"
    en: "Compare US/Germany/Japan CPI; interactive terminal opens csv app, pipe outputs TSV"

  # 格式选项各出现一次，描述说明适用场景
  - cmd: x dbnomics align --csv imf.us.gdp imf.cn.gdp
    cn: "CSV 格式: 对比美/中 GDP，适合数据库导入、表格软件或脚本处理"
    en: "CSV format: Compare US/China GDP, suitable for database import, spreadsheets, or scripting"

  - cmd: x dbnomics align --tsv fed.10y fed.2y fed.3m
    cn: "TSV 格式: 对比美国国债收益率曲线，适合管道和 awk/grep 处理"
    en: "TSV format: Compare US Treasury yield curve, suitable for piping with awk/grep"

  # 后续聚焦场景，除非场景需要否则不带格式选项
  - cmd: x dbnomics align imf.us.unemployment imf.de.unemployment
    cn: "对比美/德失业率"
    en: "Compare US/Germany unemployment"
```

## 3.6.3 子命令级别的 tldr

子命令的 tldr 可以与父级 tldr 有部分重合，但应该**聚焦该子命令的独特价值**。

```yaml
host:
  <desc>: ...
  <tldr>:                    # 顶层 tldr - 整体认知
    - cmd: x host
      cn: "示例: 交互式查看 hosts"
    - cmd: x host get localhost
      cn: "示例: 查询主机 IP"

  get:                       # 子命令 tldr - 聚焦该子命令
    <desc>: 获取主机名对应的 IP
    <tldr>:
      - cmd: x host get localhost
        cn: "示例: 获取 localhost 的 IP"
      - cmd: x host get example.com
        cn: "示例: 获取任意域名的 IP"
```

## 四、子命令定义（核心语法）

### 4.1 关键规则

**子命令直接在根级别定义，不使用 `<subcmd>:` 包裹。**

```yaml
# ✅ 正确 - 子命令在根级别定义
cat:
  <desc>:
    cn: 显示内容
    en: Display content

get:
  <desc>:
    cn: 获取值
    en: Get value

# ❌ 错误 - 不要包裹在 <subcmd>: 下
<subcmd>:
  cat:
    <desc>: ...
```

### 4.2 带别名的子命令

使用 `|` 分隔主名称和别名。

```yaml
cat|view|show:
  <desc>:
    cn: 显示内容
    en: Display content

ls|list|dir:
  <desc>:
    cn: 列出所有条目
    en: List all entries
```

**别名顺序规则**: 保持原始顺序，不得随意更改。

### 4.3 子命令分类（仅用于显示）

`<subcmd:Category>:` 仅用于 help 显示时的分类归类，**不定义子命令本身**。

#### 4.3.1 分类顺序原则

| 分类位置 | 类型 | 内容 | 示例 |
|---------|------|------|------|
| **第一类** | View（查看） | 最傻瓜、最基础的命令 | `info`, `ls`, `cat`, `app` |
| **第二类** | 常用操作 | 虽会变动但非常常用的命令 | `start`, `stop`, `restart` |
| **第三类** | Edit（编辑/变动） | 修改性操作，有一定风险 | `edit`, `set`, `rm`, `add`, `create` |
| **第四类** | Advanced（进阶） | 高级功能或特定场景 | `export`, `import`, `backup`, `restore` |
| **倒数第二类** | Internal（脚本） | `_` 变体，内部高效版本 | `get_`, `set_`, `join_` |
| **最后一类** | dev（开发） | 仅供模块开发者参考 | 带 `<tag>: inner` |

**核心原则**：
- **第一类是"最傻瓜"的命令**：只需看不需要操作的，如 `info`、`ls`、`cat`
- **Edit/变动类放第一类以后**：除非非常常用（如 `start`/`stop`），否则不放在第一类
- **`--cfg`、`sshkey` 等不放在第一类**：需要一定背景知识，不是零门槛

```yaml
# ✅ 正确 - bwh 模块分类示例
<subcmd:common>:         # 第一类：View 操作
  - info
  - current
  - start
  - stop
  - restart

<subcmd:advanced>:       # 第二类以后：进阶/高风险操作
  - kill
  - reinstall
  - migrate

# ✅ 正确 - line 模块分类示例（按功能）
<subcmd:Iter>:
  - uni
  - duo
  - uno
  - minus

<subcmd:Transform>:
  - join
  - wrap
  - prf
  - prln
```

**注意**：
- `<subcmd:common>` 通常指第一类（View/入门）
- `<subcmd:advanced>` 指进阶操作
- 分类名称只是显示用，实际子命令定义在根级别

```yaml
# 分类声明（仅归类，不定义）
<subcmd:View>:
  - cat
  - app
  - fz

<subcmd:Edit>:
  - get
  - ed

# 子命令定义（根级别）
cat:
  <desc>:
    cn: 显示 hosts 文件

app:
  <desc>:
    cn: 智能分页显示
```

### 4.4 子命令字段

```yaml
<subcmd-name>:
  <desc>:                         # 描述（必需）
    cn: 中文描述
    en: English description
  <1>:                            # 第1个位置参数（可选）
    <desc>: ...
    <exec>: ...
  <2>:                            # 第2个位置参数（可选）
  <n>:                            # 剩余参数（可选）
  --option|-o:                    # 选项定义（以 - 开头自动识别为选项）
    <desc>: ...
```

**⚠️ 重要说明**：
- `<synopsis>` **只能出现在模块级别**（`<name>`、`<desc>` 之后），**不能出现在子命令或选项级别**
- 子命令级别的用法说明应该使用 `<1>`、`<2>`、`<n>` 等位置参数字段来描述

```yaml
# ✅ 正确 - synopsis 只在模块级别
<synopsis>:
  - x host get <hostname>:

host:
  get:
    <desc>: ...
    <1>:                          # 子命令用 <1> 描述参数
      <desc>: 主机名

# ❌ 错误 - 子命令级别使用 synopsis
get:
  <synopsis>: <hostname>         # ❌ 不能在子命令级别使用 synopsis
  <desc>: ...

### 4.5 效率模块特殊规则

#### 什么是效率模块

效率模块是 x-cmd 中少数几个为极致性能设计的底层模块。

**判定标准**：如果一个子函数的主体执行时间**小于参数判断的开销**（如解析 `-h`、显示 help），那么它就是效率函数。整个模块如果绝大部分子命令都是效率函数，才标记为效率模块。

**已确认的效率模块**：`assert`、`is`、`str`（仅此三个）

> **⚠️ 判定效率模块要非常小心**：
> - 效率模块的数目极少，不要轻易将模块标记为效率模块
> - `env`、`path` 等模块虽有部分效率函数，但不一定是完整的效率模块
> - 部分效率模块可能存在非效率函数（即有些子命令的执行时间大于参数判断开销）
> - 不确定时，**不要标记为效率模块**，让它做普通模块即可

#### 效率函数的继承规则

一个子命令（subcmd）**仅当其上层（父层或祖层）被标记为效率模块**时，才算效率函数。

```
模块层（root）
  └── <meta>: <subcmd-help>: disable    ← 标记为效率模块
        ├── subcmd-a                  ← 效率函数（继承自模块层）
        ├── subcmd-b                  ← 效率函数（继承自模块层）
        └── subcmd-c                  ← 效率函数（继承自模块层）

模块层（root）
  └── <meta>: （无 subcmd-help: disable）  ← 普通模块
        ├── subcmd-a                  ← 普通函数
        ├── subcmd-b                  ← 普通函数
        └── subcmd-c                  ← 普通函数
```

**关键点**：
- 效率函数的判定是**自上而下继承**的，不是按单个子命令独立判定
- 只要模块层标记了 `<subcmd-help>: disable`，该模块下**所有**子命令都是效率函数
- 如果模块层没有标记，即使某个子命令执行很快，它也不算效率函数

> **⚠️ 显式标定原则**：
> `<subcmd-help>: disable` **必须由开发者显式标定**。lint、scan 等检查工具**不应主动推断或认定**某个模块为效率模块。
> - 检查工具只负责：如果已标记，则验证标记后的约束是否满足
> - 检查工具**不负责**：判断某个模块"应该"标记为效率模块
> - 没有 `<subcmd-help>: disable` 标记 → 一律视为普通模块，不做任何效率模块相关的检查
> - 检查工具可以**建议**某些 subcmd 适合标记为效率函数（info 级别），但未经作者许可，不得自动变更

#### AI 迭代的边界

> **经验教训**：AI 在迭代修复 story 时，可能反复建议将未标记的模块认定为效率模块，导致方向越走越偏。
>
> 这说明有些决策**必须由人类/设计者做出**，不适合交给 AI 自动迭代。效率模块的判定就是典型的例子 —— 它需要开发者对模块性能特征的深入理解，而非模式匹配。
>
> 这也是 Unix 小工具哲学的体现：工具的**结果域越小，越容易收敛**。检查工具应聚焦于"已标记的约束是否满足"这一可验证的小问题，而非"这个模块应不应该标记"这一开放性的大问题。

#### `_` 后缀子命令不需要在 advise 中声明

以 `_` 结尾的子命令（如 `join_`、`split_`、`v4_`）是内部脚本变体，**不需要**在 advise 中作为 subcmd 声明，不需要补全支持。

- 其对应的**无 `_` 版本**（如 `join`、`split`、`v4`）已经在 subcmd 定义中
- `_` 变体的存在只需在 `<tip>` 中提及即可
- 详见 [12.6 `_` 后缀子命令](#126-_-后缀子命令内部脚本变体)

#### 效率模块的约束

- 标记 `<meta>: <subcmd-help>: disable`，子命令不支持 `-h`/`--help`
- 所有 TLDR 必须在根级别
- 子命令下禁止 `<tldr>` 和复杂选项定义

```yaml
<meta>:
  <subcmd-help>: disable      # 标记为效率模块

# 所有 TLDR 必须在根级别
<tldr>:
  - cmd: x assert is-int 1 2 3
    cn: "测试: 批量验证"

# 子命令下只有简短 desc
is-int:
  <desc>:
    cn: 验证整数
    en: Check if integer
  # ❌ 效率模块子命令下禁止 <tldr> 和 <option>
```

---

## 五、选项定义

### 5.1 v0 规则：以 `-` 开头自动识别为选项

```yaml
<subcmd>:
  --json|-j:
    <desc>:
      cn: JSON 格式输出
      en: Output in JSON format
  --verbose|-v:
    <desc>:
      cn: 详细输出
      en: Verbose output
```

### 5.2 v1 升级预告：显式 `<option>` 字段

> **v1 升级计划**:
> - 引入 `<option>` 字段替代 `-` 前缀判断
> - 使选项定义更明确、更易理解
>
> ```yaml
> # v1 预期语法
> <subcmd>:
>   <option>:
>     --json|-j:
>       <desc>:
>         cn: JSON 格式输出
>         en: Output in JSON format
> ```

### 5.3 选项参数定义

```yaml
<subcmd>:
  --config|-c:
    <desc>:
      cn: 配置文件路径
      en: Config file path
    <1>:
      <desc>:
        cn: 文件路径
        en: File path
      <exec>: ___x_cmd_advise__file      # 文件补全
      <cand>:                            # 或静态候选项
        - config.yml
        - config.yaml
        - config.json
```

---

## 六、特殊字段详解

### 6.1 `<exec>` - 动态补全

`<exec>` 支持两种补全格式：

#### 6.1.1 辅助函数格式（推荐）

```yaml
<1>:
  <exec>: ___x_cmd_advise__file           # 文件补全
<1>:
  <exec>: ___x_cmd_advise__dir            # 目录补全
<1>:
  <exec>: ___x_cmd_advise__seq 1/100      # 数字序列 1-100
<1>:
  <exec>: ___x_cmd_<module>__list_items   # 自定义函数
```

#### 6.1.2 Shell 数组格式（高级）

```yaml
# 基本 exec - 生成 shell 变量
<1>:
  <exec>: candidate_arr=( $(ls /some/path) )

# exec:stdout - 直接输出候选项
<1>:
  <exec:stdout>: x ls /some/path

# exec:stdout:nospace - 无空格后缀（用于紧凑输出）
<n>:
  <exec:stdout:nospace>: command
```

### 6.2 `<cand>` - 静态候选项

```yaml
<1>:
  <cand>:
    - option1
    - option2
    - option3
```

### 6.3 `<ref>` - 引用其他 Advise（多段式 advise）

`<ref>` 用于将复杂的子命令拆分到外部文件，实现**多段式 advise**。

#### 6.3.1 文件关系

```
开发时（仓库）：
module/
├── adv/
│   ├── index.yml           # 主文件（入口）
│   └── data/
│       ├── current.yml      # 子命令 advise（yml 源文件）
│       ├── sshkey.yml
│       └── ...

发布时（合并后）：
module/
├── adv/
│   ├── index.yml           # 主文件（入口）
│   ├── index.jso           # 合并后的二进制格式
│   └── data/
│       ├── current.jso     # 转换后的二进制格式
│       ├── sshkey.jso
│       └── ...
```

**关键说明**：
- **yml** 是开发格式，开发者编辑
- **jso** 是发布格式，二进制优化（不可直接编辑）
- `<ref>` 在开发时指向 yml，发布时指向 jso
- `x y2j` 转换流程自动处理这个转换

#### 6.3.2 典型应用场景

- 子命令有非常多的选项和复杂结构（如 `bwh reinstall`、`bwh snapshot`）
- 同一个模块内有多个类似的复杂子命令
- 需要分组管理大量子命令

```yaml
<subcmd>:
  <desc>: Reference external advise
  <ref>: "x-advise://<module>/data/<subcmd>.jso"
```

**bwh 模块示例**：

`bwh` 模块是典型的多段式 advise 结构，将复杂子命令拆分到单独文件：

```yaml
# 主文件 bwh/adv/index.yml
<name>:
  bwh:
  cn: BandwagonHost VPS 管理器
  en: BandwagonHost VPS Manager

current:
  <desc>: 查看或修改当前 VPS 配置
  <ref>: "x-advise://bwh/data/current.jso"
  <tldr>:
    - cmd: x bwh current set veid=<new_veid>
      cn: 设置当前环境的 VEID

sshkey:
  <desc>: 管理 VPS 的 SSH 密钥
  <ref>: "x-advise://bwh/data/sshkey.jso"

reinstall:
  <desc>: 重新安装 VPS 的操作系统
  <ref>: "x-advise://bwh/data/reinstall.jso"
```

**多段式 adv 目录结构**：

```
module/
├── adv/
│   ├── index.yml           # 主文件（入口）
│   └── data/
│       ├── current.jso     # 子命令 advice
│       ├── sshkey.jso
│       ├── reinstall.jso
│       └── ...
```

**`<ref>` 格式**：
- `x-advise://<module>/data/<subcmd>.jso` - 指向模块 data 目录下的 jso 文件
- jso 文件由 `x y2j` 和后续处理流程生成

**何时使用 `<ref>`**：
- 子命令有 5+ 个选项
- 子命令有多个子子命令
- 子命令需要大量 TLDR 示例
- 多个模块有相似的复杂子命令结构

### 6.4 `<regex>` - 正则匹配

```yaml
<n>:
  <regex>:
    .*/.*:              # 匹配包含 / 的值
      <exec>: ___x_cmd_advise__file
    -.*:                # 匹配以 - 开头的值
      <exec>: ...
```

### 6.5 `<exec>` 变体语法

`<exec>` 支持两种输出模式：

| 变体 | 说明 |
|------|------|
| `<exec>: ___x_cmd_advise__file` | 普通补全，输出后加空格 |
| `<exec:stdout>: cmd` | 命令输出作为候选项 |
| `<exec:stdout:nospace>: cmd` | 命令输出作为候选项，**不加空格** |

```yaml
# 普通补全
<n>:
  <exec>: ___x_cmd_advise__dir

# 命令输出作为候选项
<1>:
  <exec:stdout>: x git branch

# 不加空格的命令输出（用于紧凑输出）
<1>:
  <exec:stdout:nospace>: x git remote
```

### 6.6 内置辅助函数

`<exec>` 和其他字段中可使用以下内置辅助函数：

| 函数 | 说明 | 适用场景 |
|------|------|----------|
| `___x_cmd_advise__file` | 文件补全 | 需要选择文件的参数 |
| `___x_cmd_advise__dir` | 目录补全 | 需要选择目录的参数 |
| `___x_cmd_advise__seq <start>/<end>` | 数字序列 | 数字范围补全 |
| `___x_cmd_advise__ls <dir>` | 目录内容 | 列出目录下的内容 |
| `___x_cmd_advise__xcmd` | x-cmd 模块 | 补全 x-cmd 子命令 |
| `___x_cmd_advise__xcmd_mod <mod>` | 模块子命令 | 补全特定模块的子命令 |

```yaml
# 文件补全示例
<n>:
  <exec>: ___x_cmd_advise__file

# 目录补全示例
<1>:
  <exec>: ___x_cmd_advise__dir

# 数字序列 1-100
<n>:
  <exec>: ___x_cmd_advise__seq 1/100

# 自定义命令输出
<1>:
  <exec:stdout>: x git branch
```

### 6.7 Shell 自动加载模式

Advise 支持多种自动加载模式，通过 `___X_CMD_ADVISE_AUTOLOAD_MODE` 环境变量控制：

| 模式 | 说明 |
|------|------|
| `auto` | **默认**。加载前检测是否已有 bash-completion 或 carapace，避免覆盖 |
| `all` | 加载所有补全：x-cmd + x-cmd/advise + bash/zsh-completion |
| `x` | 仅加载 x-cmd 相关补全，不加载外部补全 |
| `never` | 禁用所有 x-cmd 补全功能 |

```bash
# 设置自动加载模式
export ___X_CMD_ADVISE_AUTOLOAD_MODE=auto

# 禁用补全
export ___X_CMD_ADVISE_AUTOLOAD_MODE=never
```

### 6.8 补全执行流程

补全过程分为以下步骤：

```
1. 解析参数 → 2. 定位上下文 → 3. 获取候选项 → 4. 过滤 → 5. 格式化输出
```

| 步骤 | 说明 |
|------|------|
| **1. 解析参数** | 解析当前命令行参数，确定当前位置 |
| **2. 定位上下文** | 找到对应的模块和子命令 |
| **3. 获取候选项** | 从 `<cand>`、`<exec>`、`<ref>` 等获取候选项 |
| **4. 过滤** | 根据已输入内容过滤候选项 |
| **5. 格式化输出** | 按 Shell 要求格式输出（bash/zsh/fish 等） |

### 6.9 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `___X_CMD_ADVISE_DISABLE` | `0` | `1` = 禁用 advise 补全 |
| `___X_CMD_ADVISE_WITHOUT_DESC` | `0` | `1` = 补全时不显示描述 |
| `___X_CMD_ADVISE_MAX_ITEM` | `99` | 补全候选项最大数量 |
| `___X_CMD_ADVISE_DEV_MOD` | `0` | `1` = 开发模式 |
| `___X_CMD_ADVISE_AUTOLOAD_MODE` | `auto` | 自动加载模式 |
| `___X_CMD_LANG` | `en` | 补全显示语言（`zh` 或 `en`） |

```bash
# 禁用补全
export ___X_CMD_ADVISE_DISABLE=1

# 显示描述
export ___X_CMD_ADVISE_WITHOUT_DESC=0

# 中文补全
export ___X_CMD_LANG=zh
```

### 6.10 效率模块 vs 普通模块对比

| 特性 | 效率模块 | 普通模块 |
|------|----------|----------|
| 已确认 | assert, is, str | host, git, bwh, env, path, ... |
| 判定标准 | 子函数执行时间 < 参数判断开销 | 不满足效率模块标准 |
| `<meta>: <subcmd-help>` | `disable` | 不需要或 `enable` |
| TLDR 位置 | **根级别** | 根级别或子命令下 |
| 子命令 help | **不支持** | 支持 |
| `_` 变体 | 通常有 | 可选 |

> **注意**：`env`、`path` 等模块虽有部分效率函数，但整体不是效率模块。不确定时不标记。

```yaml
# 效率模块
<meta>:
  <subcmd-help>: disable

<tldr>:
  - cmd: x assert is-int 1 2 3
    cn: "测试: 批量验证"

is-int:
  <desc>:
    cn: 验证整数

# 普通模块
git:
  <desc>: ...

  <tldr>:      # 普通模块可以在子命令下放 tldr
    - cmd: x git commit
      cn: "示例: 提交"

  commit:
    <desc>: ...
```

### 6.11 位置参数 `<1>` `<2>` `<n>`

```yaml
<1>:                            # 第1个参数
  <desc>: 参数描述
  <exec>: 补全命令

<2>:                            # 第2个参数
  <desc>: ...

<n>:                            # 第n个及以后的所有参数
  <desc>: 剩余参数
  <cand>: [...]
```

### 6.12 内置子命令 `-h|--help`

`-h|--help` 是 x-cmd 各模块/函数的**默认内置子命令**。

- **不需要**在 advise 中声明 `-h|--help` 为子命令
- **不需要**在子命令分类列表（`<subcmd:xxx>`）中列出
- **不需要**在 tldr、tip、desc 等 help 文档中提及 `-h|--help`
- 代码中通过 `case "$1" in -h|--help) ...` 统一处理

> 正因为默认，所以不需要在 advise 和 help 文档中提及。用户自然知道可以用 `--help`。

---

## 七、尖括号格式规范

**⚠️ 严正声明：尖括号在不同语境中有完全不同的含义，请严格区分！**

| 类型 | 格式 | 示例 | 含义 | 是否是真实 YAML 字段 |
|------|------|------|------|---------------------|
| **真实字段名** | `<name\|desc\|tldr>` | `<name>`, `<desc>`, `<tldr>`, `<synopsis>`, `<tip>` | YAML 源文件的实际字段名，尖括号是语法标识 | ✅ **是** |
| **变量占位符** | `<变量描述>` | `<module>`, `<name-of-subcmd>`, `<args>` | 表示此处应填入实际值的占位符 | ❌ **否** |
| **特殊标记** | `<subcmd:分类名>` | `<subcmd:View>`, `<subcmd:Edit>` | 仅用于 help 显示的分类标记 | ✅ **是** |
| **v1 新增字段** | `<option>` | `<option>:` | 显式声明选项（替代 `-` 前缀） | ✅ **是**（v1） |

**核心规则（必须牢记）**:

1. **真实的 YAML 字段**: `<name>`, `<desc>`, `<tldr>`, `<synopsis>`, `<tip>`, `<meta>`, `<1>-<n>`, `<exec>`, `<cand>`, `<regex>`, `<option>`（v1）
2. **变量占位符**: `<module>`, `<name-of-subcmd>`, `<args>`, `<默认子命令名>`
3. **不存在 `<subcmd>` 字段**: 子命令直接在根级别定义

---

## 八、YAML 语法注意事项

### 8.1 必须加引号的情况

| 情况 | 示例 | 说明 |
|------|------|------|
| 值中包含 `:` | `"示例: xxx"` | 冒号是键值分隔符 |
| 值以 `!` 开头 | `"!|false"` | `!` 是 YAML 标签保留字符 |
| 值中包含 `&` | `"A&B"` | `&` 是锚点保留字符 |
| 值以 `*` 开头 | `"*keyword"` | `*` 是别名保留字符 |
| 值以 `-` 开头但不是列表项 | `"-not-option"` | 避免被解析为列表 |

### 8.2 多行字符串

使用 `|` 保留换行符：

```yaml
<desc>:
  cn: |
    第一行
    第二行
    第三行
```

### 8.3 缩进

- 使用空格缩进，**禁止使用 Tab**
- 统一使用 2 个空格缩进

---

## 九、错误模式与规避（Error Patterns）

> **重要**: 本章节专门记录常见的 advise 编写错误，用于 AI 学习避免踩坑。

### 9.1 子命令定义位置错误

```yaml
# ❌ 错误 - 包裹在 <subcmd>: 下
<subcmd>:
  cat:
    <desc>: Description

# ✅ 正确 - 直接在根级别定义
cat:
  <desc>:
    cn: 显示内容
    en: Display content
```

### 9.2 修改时改变子命令顺序

```yaml
# ❌ 错误 - 改变了原有顺序
c|copy|cp|-c|--cp:      # 改变了！原顺序是 c|cp|copy|--cp|-c

# ✅ 正确 - 保持原有顺序
c|cp|copy|--cp|-c:      # 保持原始设计
```

**为什么要保持顺序**:
1. **向后兼容**: 用户可能已经习惯了某些别名
2. **作者意图**: 原作者可能有意将短别名放在前面（如 `c|` 比 `copy|` 更常用）
3. **一致性**: 保持代码和文档的一致性

### 9.3 选项定义使用 `<synopsis>`

```yaml
# ❌ 错误 - 选项/子命令级别不能使用 <synopsis>
schd:
  -i|--interval:
    <synopsis>: <interval>    # ❌ 不能在选项级别使用 synopsis
    <desc>:
      en: Interval between executions
      cn: 执行间隔

# ✅ 正确 - 选项级别只用 <desc>
schd:
  -i|--interval:
    <desc>:
      en: Interval between executions
      cn: 执行间隔
```

### 9.4 效率模块的 TLDR 位置错误

```yaml
# ❌ 错误 - 效率模块（assert/is/str）的子命令下不能放 tldr
is-int:
  <tldr>:           # 底层模块不支持！
    - cmd: ...

# ✅ 正确 - 效率模块所有 TLDR 必须在根级别
<tldr>:
  - cmd: x assert is-int 1 2 3
    cn: "测试: 批量验证"

is-int:
  <desc>:
    cn: 验证是整数
    en: Check if integers
```

### 9.5 描述含冒号未加引号

```yaml
# ❌ 错误
--backend:
  <desc>:
    en: Backend: faster-whisper, openai-api   # ❌ 冒号导致 YAML 解析错误

# ✅ 正确
--backend:
  <desc>:
    en: "Backend: faster-whisper, openai-api"  # ✅ 加引号
```

### 9.6 YAML 特殊字符未加引号

```yaml
# ❌ 错误 - ! 和 | 都是 YAML 保留字符
<subcmd:Command>:
  - !|false        # 解析错误

# ✅ 正确 - 使用引号包裹
<subcmd:Command>:
  - "!|false"      # 正确解析
```

### 9.7 重复定义内置子命令

```yaml
# ❌ 错误 - -h|--help 是内置的，不需要定义
cat:
  <desc>: Display content
  -h|--help:        # ❌ 不要定义，会冲突
    <desc>: Show help

# ✅ 正确 - 代码中处理 -h|--help
# lib/main 中：
# case "$1" in -h|--help) ___x_cmd help -m modname cat; return ;;
```

### 9.8 忘记 `<meta>` 标记效率模块

```yaml
# ❌ 错误 - 效率模块没有标记 <subcmd-help>: disable
<name>:
  str:
  cn: 字符串处理
  en: String manipulation
# 没有 <meta>: <subcmd-help>: disable

# ✅ 正确
<meta>:
  <subcmd-help>: disable
```

---

## 十、完整示例

### 10.1 普通模块示例

```yaml
<name>:
  host:
    cn: Host 管理
    en: Host management

<meta>:
  default-subcmd: app

<synopsis>:
  - x host [subcommand] [options]...:
  - x host cat:
  - x host get <hostname>:

<desc>:
  cn: |
    通过 /etc/hosts 文件管理本地主机名映射。
    提供安全编辑功能。
  en: |
    Manage local hostname to IP mappings via /etc/hosts file.
    Provides safe editing with backup.

<tip>:
  - cn: |
      使用 'x host' 或 'x host app' 进行交互式显示
      使用 'x host cat' 在管道脚本中获取完整输出
    en: |
      Use 'x host' or 'x host app' for interactive display
      Use 'x host cat' for full output in scripts

<tldr>:
  - cmd: x host
    cn: "示例: 智能分页显示 hosts 文件"
    en: "Example: Display hosts with pagination"

  - cmd: x host cat
    cn: "示例: 查看所有主机名映射(适合管道)"
    en: "Example: View all mappings (pipe-friendly)"

  - cmd: x host get localhost
    cn: "示例: 获取 localhost 的 IP 地址"
    en: "Example: Get IP for localhost"

<subcmd:View>:
  - cat
  - app
  - fz

<subcmd:Edit>:
  - get
  - ed

# 子命令定义（根级别）
cat:
  <desc>:
    cn: 显示 hosts 文件内容
    en: Display hosts file content

get:
  <desc>:
    cn: 获取主机名的 IP 地址
    en: Get IP address for hostname
  <1>:
    <desc>:
      cn: 要查询的主机名
      en: Hostname to lookup

ed:
  <desc>:
    cn: 编辑 hosts 文件条目
    en: Edit hosts file entries

app:
  <desc>:
    cn: 智能分页显示 hosts
    en: Display with TTY-aware pagination

fz:
  <desc>:
    cn: 交互式模糊查找
    en: Interactive fuzzy finder

<other>:
  cn:
    "请访问我们的主页以获取更多信息：": "https://x-cmd.com"
  en:
    "Please visit our homepage for more information:": "https://x-cmd.com"
```

### 10.2 效率模块示例（assert）

```yaml
<meta>:
  <subcmd-help>: disable

<name>:
  assert:
  cn: 测试断言
  en: Test assertion

<synopsis>:
  - x assert <operator> <args...>:

<desc>:
  cn: |
    测试断言工具，用于验证测试结果。
    所有断言失败时返回非0退出码。
  en: |
    Test assertion tool for verifying results.
    Returns non-zero exit code on failure.

<tip>:
  - cn: |
      测试最佳实践：
      1. 命令成功用 'x assert -- [ test ]'
      2. 预期失败用 'x assert ! cmd'
      3. 变量加引号: 'x assert === "$a" "$b"'
      4. 否定检查用 ^: 'x assert is-file ^nonexist'
    en: |
      Test best practices:
      1. Use 'x assert -- [ test ]' for command success
      2. Use 'x assert ! cmd' for expected failures
      3. Quote variables: 'x assert === "$a" "$b"'
      4. Negate with ^: 'x assert is-file ^nonexist'

<tldr>:
  # 命令执行测试
  - cmd: x assert true [ 1 -eq 1 ]
    cn: "测试: 验证命令成功返回0"
    en: "Test: verify command succeeds"

  - cmd: x assert ! false
    cn: "测试: 验证命令失败返回非0"
    en: "Test: verify command fails"

  # 类型测试 - 多值批量检查
  - cmd: x assert is-int 1 2 3 4 5
    cn: "测试: 批量验证多值都是整数"
    en: "Test: batch verify multiple integers"

  - cmd: x assert is-file /etc/passwd /etc/hosts /etc/resolv.conf
    cn: "测试: 批量验证3个系统文件存在"
    en: "Test: batch verify 3 system files exist"

  # 变量测试 - 支持^否定
  - cmd: x assert is-set HOME PATH USER
    cn: "测试: 批量验证多个变量已设置"
    en: "Test: batch verify variables set"

  - cmd: x assert is-set ^UNDEF ^NOTSET ^EMPTY
    cn: "测试: 批量验证多个变量未设置(^否定)"
    en: "Test: batch verify variables unset"

# 子命令只有简短 desc（不能有 tldr）
is-int:
  <desc>:
    cn: 验证是整数
    en: Check if integers

is-file:
  <desc>:
    cn: 验证文件存在
    en: Check if files exist

is-set:
  <desc>:
    cn: 验证变量已设置
    en: Check if variables are set
```

### 10.3 效率模块示例（str）

```yaml
<meta>:
  <subcmd-help>: disable

<name>:
  str:
  cn: 字符串处理工具
  en: String manipulation tool

<synopsis>:
  - x str <subcmd> <args>:

<desc>:
  cn: |
    高性能字符串处理模块，提供丰富的字符串操作功能。
    支持大小写转换、修剪、分割、替换、编码解码、哈希计算等。
    底层模块，不支持子命令级别的 help。
  en: |
    High-performance string manipulation module providing rich string operations.
    Supports case conversion, trim, split, replace, encoding/decoding, hash calculation, etc.
    Low-level module, subcommand-level help not supported.

<tip>:
  - cn: |
      这是底层高性能模块，所有 TLDR 示例放在根级别。
      支持管道输入和参数输入两种方式。
    en: |
      This is a low-level high-performance module, all TLDR examples are at root level.
      Supports both pipe input and argument input.

<tldr>:
  # === 大小写转换 ===
  - cmd: x str upper hello
    cn: "示例: 将字符串转为大写"
    en: "Example: convert string to uppercase"

  - cmd: echo "Hello World" | x str lower
    cn: "示例: 管道方式将字符串转为小写"
    en: "Example: convert string to lowercase via pipe"

  # === 修剪空白 ===
  - cmd: x str trim "  hello  "
    cn: "示例: 去除字符串两端空白"
    en: "Example: trim whitespace from both ends"

  # === Python 风格切片 ===
  - cmd: x str slice abcdef 1:3
    cn: "示例: 取索引 1-3 的子串（结果: bc）"
    en: "Example: slice index 1 to 3 (result: bc)"

  - cmd: x str slice abcdef -3:
    cn: "示例: 取最后 3 个字符（结果: def）"
    en: "Example: slice last 3 chars (result: def)"

  # === 分割字符串 ===
  - cmd: x str split "," a,b,c
    cn: "示例: 按逗号分割字符串"
    en: "Example: split string by comma"

upper:
  <desc>:
    cn: 转为大写
    en: Convert to uppercase

lower:
  <desc>:
    cn: 转为小写
    en: Convert to lowercase

trim:
  <desc>:
    cn: 去除两端空白
    en: Trim whitespace

slice:
  <desc>:
    cn: Python 风格切片
    en: Python-style slice

split:
  <desc>:
    cn: 分割字符串
    en: Split string
```

---

## 十一、修改规则

### 11.1 绝对规则：不得改变 subcmd 顺序

修改 advise 时，**必须保持原作者的 subcmd 名称顺序设计**。

```yaml
# ✅ 正确 - 保持原始顺序
c|cp|copy|--cp|-c:
  <desc>:
    en: Copy to clipboard

cr|change-repo:
  <desc>:
    en: Change repository mirror

# ❌ 错误 - 改变了顺序！
c|copy|cp|-c|--cp:
change-repo|cr:
```

### 11.2 不得删除或重命名子命令

即使认为某些子命令命名不合理，也不得擅自删除或重命名。

### 11.3 添加新子命令是允许的

在保持原有 subcmd 不变的前提下，可以添加新的子命令：

```yaml
# ✅ 正确 - 添加新子命令，旧的不变
-j|--json:     # 原有
-c|--csv:      # 原有
-a|--all:      # 新增（放在后面）
```

### 11.4 检查命令

```bash
# 查看 subcmd 定义行
grep -E "^[a-z].*|" adv/index.yml

# 对比修改前后的 subcmd 顺序
git diff HEAD -- adv/index.yml | grep -E "^[-+].*|"
```

### 11.5 最佳实践

1. **描述完整**：为每个命令和选项提供中英文描述
2. **使用别名**：为常用子命令提供短别名（如 `ls|list`）
3. **合理分组**：使用 `<subcmd:Category>` 进行分类
4. **优先静态**：简单候选项使用 `<cand>`，复杂场景使用 `<exec>`
5. **引用复用**：通过 `<ref>` 复用其他模块的补全定义
6. **正则兜底**：使用 `<regex>` 处理特殊格式的参数
7. **nospace 谨慎**：仅在需要连续补全时使用

**核心原则**: 润色 advise 时，只改**描述内容**，不改**结构顺序**。

---

## 十二、审查清单

### 12.1 语法检查

- [ ] `x y2j adv/index.yml` 返回有效 JSON，无错误
- [ ] 使用空格缩进，无 Tab 字符
- [ ] 值中的冒号已加引号
- [ ] 特殊字符（! & *）已加引号

### 12.2 必需字段

- [ ] `<name>` 包含 module_name、cn、en
- [ ] `<synopsis>` 至少有一个用法示例
- [ ] `<desc>` 包含 cn 和 en
- [ ] `<tldr>` 至少 3 个示例（简单）或 8+（复杂）
- [ ] 每个 tldr 项包含 cmd、cn、en

### 12.3 子命令语法

- [ ] 子命令在根级别定义，未包裹在 `<subcmd>:` 下
- [ ] `<subcmd:Category>:` 仅用于分类显示
- [ ] 子命令别名顺序与原始一致
- [ ] 每个子命令与实际代码实现匹配

### 12.4 效率模块检查

- [ ] 仅 assert、is、str 标记为效率模块（判定标准：子函数执行时间 < 参数判断开销）
- [ ] 效率模块标记 `<meta>: <subcmd-help>: disable`
- [ ] 所有 TLDR 在根级别
- [ ] 子命令下无 `<tldr>`

### 12.5 TLDR 质量

- [ ] 展示最强能力（批量/多值/复杂模式）
- [ ] 描述简洁（"示例:"/"测试:"/"警告:"）
- [ ] 示例覆盖所有主要功能

### 12.6 `_` 后缀子命令（内部脚本变体）

**规则**: 以 `_` 结尾的子命令（如 `v4_`、`join_`、`split_`）是内部脚本变体，**不需要**在 advise 中单独列出。

**设计原则**:
- 主要版本（如 `v4`）输出到 stdout，供人类使用
- `_` 变体（如 `v4_`）将结果存入 `x_` 变量，供脚本调用
- `_` 变体不提供 help，不显示在子命令列表中

**推荐做法**: 在模块级别的 `<tip>` 中统一说明，不逐个子命令说明。

```yaml
# ✅ 推荐 - 在 tip 中统一说明
<tip>:
  - en: "Most subcommands have a `_` suffix variant that stores result in `x_` variable for scripting (e.g. `join_`, `split_`)."
    cn: "大多数子命令有 `_` 后缀变体，将结果存入 `x_` 变量供脚本使用（如 `join_`、`split_`）。"

# ❌ 不推荐 - 逐个说明会大量增加内容
join:
  <desc>:
    en: Join lines...
    cn: 连接行...
  <tip>:
    - en: "Use `join_` for scripting."
      cn: "脚本开发可用 `join_`"
```

**参考模块**: `line` 模块是这一原则的最佳示例：
- 位置参数: `<tip>` 在模块级别
- 子命令: 只列出 `join`、`split` 等主要版本
- 内部: `join_`、`split_` 等 `_` 变体不显示

---

## 十三、相关文档

### 13.1 规则文件（rule/advise.rule.yml）

`rule/advise.rule.yml` 与本文件（`spec.md`）位于同一目录，**互为参考，同时更新**。

| 文件 | 用途 | 格式 |
|------|------|------|
| `spec.md`（本文件） | 编写规范：字段定义、原则、示例、错误模式 | Markdown |
| `rule/advise.rule.yml` | `x check` / `x rule` 的检查规则 | YAML |

**规则文件结构**：

```yaml
ADV-<category>-<number>:
  name: 规则简称
  apply: adv/index.yml
  level: error | warn | info
  desc:
  - 规则描述
  tldr:           # 可选：正反示例
  - wrong: ...
    right: ...
```

**level 含义**：

| level | 说明 | 效果 |
|-------|------|------|
| `error` | 必须遵守 | lint 失败 |
| `warn` | 应该遵守 | 警告但不失败 |
| `info` | 建议性 | 仅供参考，不影响 lint |

**规则分类**：

| 分类前缀 | 范围 |
|---------|------|
| `ADV-syntax-` | YAML 语法与结构 |
| `ADV-field-` | 必需字段 |
| `ADV-option-` | 选项前置规则 |
| `ADV-tldr-` | TLDR 编写规则 |
| `ADV-tip-` | Tip 编写规则 |
| `ADV-modify-` | 修改规则（顺序、重命名） |
| `ADV-efficiency-` | 效率模块规则 |
| `ADV-subcmd-` | 子命令规则（`_` 后缀等） |
| `ADV-writing-` | 写作优先级 |

> **维护原则**：修改 spec.md 中的任何编写原则时，应在 rule.yml 中添加或更新对应规则；修改 rule.yml 时，应同步更新 spec.md 中的相关章节。

### 13.2 AI 学习指南

**AI 学习 advise 应该执行**：
```bash
x advise spec show
```

这是 advise 的权威文档，包含了所有编写 advise 的规则。

### 13.3 x-cmd-spec 参考文档

x-cmd-spec 中的 advise 相关文档已简化，内容合并到 `x advise spec show`：

| 文档 | 状态 | 说明 |
|------|------|------|
| `705-X-CMD-Advise-Specification-V0.md` | 已废弃 | 合并到 x advise spec |
| `701-核心-advise与补全.md` | 已废弃 | 合并到 x advise spec |
| `702-高信息量TLDR编写指南.md` | 参考 | TLDR 编写规范 |
| `703-核心-子命令-h-help-实现.md` | 参考 | Shell 代码模式（不在 advise 范围内） |
| `704-标准模块组织案例.md` | 参考 | 见 standard-modules.md |
| `706-开发-参数处理.md` | 参考 | 开发者参数处理 |
| `707-sleep-os-advise-cheatsheet.md` | 参考 | 示例参考 |

### 13.4 标准模块参考

参考以下模块的 advise 文件学习最佳实践：

| 模块 | 路径 | 特点 |
|------|------|------|
| **bwh** | `x-bash/bwh/adv/index.yml` | 多段式 advise、`<ref>` 外部引用 |
| **line** | `x-bash/line/adv/index.yml` | 子命令分类、`<tip>` 模块级别 `_` 变体说明 |
| **tldr** | `x-bash/tldr/adv/index.yml` | `<web>` 字段、`tlfz` 快捷命令 |
| **assert** | `x-bash/assert/adv/index.yml` | 效率模块标记（`<subcmd-help>: disable`） |
| **str** | `x-bash/str/adv/index.yml` | 效率模块、TLDR 在根级别 |
| **timeout** | `x-bash/timeout/adv/index.yml` | 选项模式 |
| **passwd** | `x-bash/passwd/adv/index.yml` | 纯选项模式 |
| **tmp** | `x-bash/tmp/adv/index.yml` | 基础模块 |
| **user** | `x-bash/user/adv/index.yml` | 普通模块示例 |
| **home** | `x-bash/home/adv/index.yml` | 基础模块 |
| **uuid** | `x-bash/uuid/adv/index.yml` | 清晰的子命令分类 |
| **tlfz** | `x-bash/tlfz/adv/index.yml` | 独立模块示例 |
| **dbnomics** | `x-bash/dbnomics/adv/index.yml` | 场景化 tldr、auto 模式、多数据源别名、大量 tip |

### 13.5 标准模块说明文档

详细的标准模块参考：
```bash
x advise spec show --standard-modules
```

---

## 附录 A: 字段速查表

| 字段 | 类型 | 用途 |
|------|------|------|
| `<name>` | object | 模块名称（cn, en） |
| `<meta>` | object | 元数据（default-subcmd, <subcmd-help>） |
| `<synopsis>` | array | 命令用法示例（仅模块级别） |
| `<desc>` | object | 描述（cn, en） |
| `<tip>` | array | 使用提示 |
| `<tldr>` | array | 常用示例 |
| `<subcmd:Category>` | array | 子命令分类列表 |
| `<1>`, `<2>`, `<n>` | object | 位置参数定义 |
| `<exec>` | string | 动态补全命令 |
| `<cand>` | array | 静态候选项 |
| `<ref>` | string | 引用其他 advise |
| `<regex>` | object | 正则匹配规则 |
| `<option>` | object | **v1 新增**：显式选项定义（替代 `-` 前缀） |

---

## 附录 B: v1 升级预告

### B.1 `<option>` 字段（计划中）

当前 v0 使用 `-` 前缀识别选项：

```yaml
# v0 - 以 - 开头自动识别为选项
<subcmd>:
  --json|-j:
    <desc>: JSON output
```

v1 将引入 `<option>` 字段：

```yaml
# v1（预期）- 显式 <option> 包裹
<subcmd>:
  <option>:
    --json|-j:
      <desc>: JSON output
```

**目的**: 使选项定义更明确，消除歧义。

---

*本文档版本: v0*
*创建: 2026-05-04*
*最后更新: 2026-05-14*