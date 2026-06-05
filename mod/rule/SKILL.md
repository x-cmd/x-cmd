# Rule — Rules to rule

> 用规则统领代码与智能体输出质量

`x rule` 是 x-cmd 的质量治理框架。通过 YAML 规则集对代码和智能体输出进行质量检查、评分、修复和迭代。

## 核心命令

| 命令 | 作用 | 场景 |
|------|------|------|
| `x rule lint <file>` | jq 静态验证 rule.yml 格式 | 提交前自检 |
| `x rule scan <target>` | 贪心快筛，1-5 条最严重问题 | agent 内循环迭代 |
| `x rule check <target>` | 全局合规检查，输出所有违规 | 修复前确认 |
| `x rule audit <target>` | 逐条评分（0-100），出详细报告 | 最终验证 |
| `x rule fix <target>` | 自主修复循环 | 自动合规化 |
| `x rule refine <report>` | 根据报告精调规则 | 规则优化 |
| `x rule evolve <target>` | 根据代码适配规则集 | 规则扩展 |

## 规则文件格式

规则文件以 `.rule.yml` 结尾，每条规则包含：

```yaml
rule-id:
  name: rule-name           # 可选，简短标签
  apply: "shell files"      # 可选，适用文件类型
  level: error             # error/must/warn/info/debug
  desc:                     # 必填，规则描述（列表）
  - 描述文字
  tldr:                     # 可选，正确/错误示例
  - wrong: 错误代码
    right: 正确代码
  memo:                     # 可选，补充说明
  - 备注
```

## 示例

```bash
# 验证规则文件格式
x rule lint lib/po6/local.rule.yml

# 快筛代码问题
x rule scan src/

# 全量检查
x rule check -r lib/po6 src/

# 审计并出报告
x rule audit -o /tmp/report lib/

# 自主修复
x rule fix src/
```

## 内部工具

- `x rule ls` — 列出规则集
- `x rule which` — 显示规则集路径
- `x rule preset ls` — 列出预设规则集

## 架构

```
rule/
├── lib/
│   ├── *.rule.yml      # 规则文件（*.rule.yml 结尾）
│   ├── jq/lint.jq      # jq 静态验证过滤器
│   ├── scan|check|audit|fix|refine|evolve|lint  # 子命令
│   └── preset-data/    # 内置预设规则集
└── adv/index.yml       # 命令行补全配置
```

## 关联

- SKILL.md 在 `/Users/l/.x-cmd.root/v/.repo/x-bash/rule/SKILL.md`
- story 在 `.x-cmd/story/` 目录下