# x-cmd Skill

> 为 AI 助手添加 x-cmd 能力

## 自然语言安装（支持：OpenClaw, Claude Code, Codex, OpenCode）

```text
请帮我安装 x-cmd skills，参考 https://x-cmd.com/llms.txt
```

AI 将自动处理安装。

---

## 通过 x-cmd 安装（支持：Claude Code, Codex, OpenCode, Kimi CLI, OpenClaw）

```bash
x agent setup
```

安装到：
- `~/.claude/skills/x-cmd/`
- `~/.codex/skills/x-cmd/`
- `~/.opencode/skills/x-cmd/`
- `~/.agents/skills/x-cmd/`


## OpenClaw（支持：OpenClaw）

```bash
clawhub install x-cmd
```

## Claude Code（支持：Claude Code）

```bash
/plugin marketplace add x-cmd-skill/x-cmd
/plugin install x-cmd@x-cmd
```

或：
```bash
claude plugin marketplace add x-cmd-skill/x-cmd && claude plugin install x-cmd@x-cmd
```

## Codex（支持：Codex）

```bash
codex plugin marketplace add x-cmd-skill/x-cmd
codex plugin install x-cmd@x-cmd
```

## 手动安装（支持：任意 agent）

```bash
git clone https://github.com/x-cmd-skill/x-cmd.git ~/.claude/skills/x-cmd
```

---

## Skill 结构

```
x-cmd/
├── README.md          # 本文件
├── SKILL.md           # 核心 skill 文档
├── README.cn.md       # 中文文档
└── data/
    └── install.md     # 终端用户安装指南
```

---

## 使用

```bash
# 加载 x-cmd
. ~/.x-cmd.root/X

# 浏览 skills
x skill

# 安装软件包
x env use jq nodejs python3
```

---

## 资源

| 资源 | 地址 |
|------|-----|
| x-cmd 官网 | https://www.x-cmd.com |
| AI 文档 (llms.txt) | https://www.x-cmd.com/llms.txt |
| x-cmd 源码 | https://github.com/x-cmd/x-cmd |
| 本 Skill | https://github.com/x-cmd-skill/x-cmd |

---

*版本: 0.0.6 | 协议: Apache-2.0*
