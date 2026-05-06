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
  subcmd-help: disable             # 效率模块标记
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `default-subcmd` | string | 当用户只输入模块名时使用的默认子命令 |
| `trailing-option` | boolean | 是否支持选项出现在位置参数之后 |
| `subcmd-help` | string | `disable` 表示子命令无 help 支持（效率模块） |

### 3.3 `<synopsis>` - 命令用法

```yaml
<synopsis>:
  - x <module> [name-and-alias-of-subcmd] [options] [args...]:
  - x <module> <name-of-subcmd> <args>:
```

**注意**: `<synopsis>` **只能在模块级别**定义，子命令/选项级别不可使用。

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

### 3.6 `<tldr>` - 常用示例

```yaml
<tldr>:
  - cmd: x <module> <name-of-subcmd> <args>    # 命令示例
    cn: "示例: 中文描述"                        # 中文描述
    en: "Example: English description"          # 英文描述
```

**TLDR 编写原则**:
- 描述前缀规范:
  - 功能模块: `"示例: xxx"`
  - 测试模块: `"测试: xxx"`
  - 危险操作: `"警告: xxx"`
- 展示最强能力: 多值、批量、复杂模式
- 覆盖主要功能点

**强弱示例对比**:

```yaml
# ❌ 弱示例 - 只展示单值
- cmd: x assert is-int 42
  cn: "示例: 整数检查"

# ✅ 强示例 - 展示批量能力
- cmd: x assert is-int 1 2 3 4 5
  cn: "测试: 批量验证多值都是整数"
```

---

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

效率模块（assert、is、str、env、path）为高性能设计，**子命令无 help 支持**。

```yaml
<meta>:
  subcmd-help: disable      # 标记为效率模块

# 所有 TLDR 必须在根级别
tldr:
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
| 示例 | assert, is, str, env, path | host, git, bwh |
| `<meta>: subcmd-help` | `disable` | 不需要或 `enable` |
| TLDR 位置 | **根级别** | 根级别或子命令下 |
| 子命令 help | **不支持** | 支持 |
| `_` 变体 | 通常有 | 可选 |

```yaml
# 效率模块
<meta>:
  subcmd-help: disable

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

> **重要**：`-h|--help` 是**内置子命令**，不需要在 advise 中显式定义。代码中通过 `case "$1" in -h|--help) ...` 处理。

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
# ❌ 错误 - 效率模块没有标记 subcmd-help: disable
<name>:
  str:
  cn: 字符串处理
  en: String manipulation
# 没有 <meta>: subcmd-help: disable

# ✅ 正确
<meta>:
  subcmd-help: disable
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
  subcmd-help: disable

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
  subcmd-help: disable

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

- [ ] 效率模块标记 `<meta>: subcmd-help: disable`
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

### 13.1 AI 学习指南

**AI 学习 advise 应该执行**：
```bash
x advise spec show
```

这是 advise 的权威文档，包含了所有编写 advise 的规则。

### 13.2 x-cmd-spec 参考文档

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

### 13.3 标准模块参考

参考以下模块的 advise 文件学习最佳实践：

| 模块 | 路径 | 特点 |
|------|------|------|
| **bwh** | `x-bash/bwh/adv/index.yml` | 多段式 advise、`<ref>` 外部引用 |
| **line** | `x-bash/line/adv/index.yml` | 子命令分类、`<tip>` 模块级别 `_` 变体说明 |
| **tldr** | `x-bash/tldr/adv/index.yml` | `<web>` 字段、`tlfz` 快捷命令 |
| **assert** | `x-bash/assert/adv/index.yml` | 效率模块标记（`subcmd-help: disable`） |
| **str** | `x-bash/str/adv/index.yml` | 效率模块、TLDR 在根级别 |
| **timeout** | `x-bash/timeout/adv/index.yml` | 选项模式 |
| **passwd** | `x-bash/passwd/adv/index.yml` | 纯选项模式 |
| **tmp** | `x-bash/tmp/adv/index.yml` | 基础模块 |
| **user** | `x-bash/user/adv/index.yml` | 普通模块示例 |
| **home** | `x-bash/home/adv/index.yml` | 基础模块 |
| **uuid** | `x-bash/uuid/adv/index.yml` | 清晰的子命令分类 |
| **tlfz** | `x-bash/tlfz/adv/index.yml` | 独立模块示例 |

### 13.4 标准模块说明文档

详细的标准模块参考：
```bash
x advise spec show --standard-modules
```

---

## 附录 A: 字段速查表

| 字段 | 类型 | 用途 |
|------|------|------|
| `<name>` | object | 模块名称（cn, en） |
| `<meta>` | object | 元数据（default-subcmd, subcmd-help） |
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
*最后更新: 2026-05-04*