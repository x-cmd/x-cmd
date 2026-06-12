---
name: x-cmd-advise
 description: |
   Authoritative guide for writing x-cmd advise (completion/help specs).
   Covers YAML structure, field semantics, TLDR writing, error patterns, and lint workflow.
   Style: principle-first, concise, with verifiable rules.
---

# x-cmd Advise Writing Guide

> This is the **live instruction** for AI agents writing `adv/index.yml` files.
> For the full spec, run `x advise spec show`.
> For rule-based verification, run `x advise spec lint`.

---

## Core Principles

| Principle | Rule |
|-----------|------|
| **Options first** | In all examples (synopsis, tldr, desc), options MUST precede arguments. `x mod --opt arg` ✅, `x mod arg --opt` ❌ |
| **Root-level subcmds** | Subcommands are defined at root, NOT wrapped under `<subcmd>:` |
| **Preserve order** | Never reorder subcmd aliases. `c|cp|copy` stays `c|cp|copy` |
| **No builtin help** | `-h|--help` is handled by code; do NOT declare it in advise |
| **Efficiency modules** | Only `assert`, `is`, `str` are efficiency modules. Mark with `<meta>: <subcmd-help>: disable`. All TLDR at root only. |
| **YAML safety** | Quote strings containing `:`, `!`, `&`, `*`, or leading `-` |

---

## Field Quick Reference

```yaml
<name>:
  <modname>:
  cn: 中文名
  en: English name

<synopsis>:                 # MODULE level only
  - x <mod> [subcmd] [options]:

<desc>:
  cn: |
    Description.
  en: |
    Description.

<tip>:                      # List of tips, module or subcmd level
  - cn: "Tip content"
    en: "Tip content"

<tldr>:                     # At least 3 items (simple) or 8+ (complex)
  - cmd: x <mod> <subcmd>
    cn: "示例: description"
    en: "Example: description"

<subcmd:Category>:          # Display grouping only
  - subcmd1
  - subcmd2

# Subcommands at ROOT level
subcmd1:
  <desc>:
    cn: ...
    en: ...
  <1>:                        # Positional arg
    <desc>: ...
    <exec>: ___x_cmd_advise__file
  --option|-o:
    <desc>: ...
```

**Required fields**: `<name>`, `<synopsis>`, `<desc>`, `<tldr>` (minimum 3).

---

## Writing Priority

1. **Clarity over brevity** — say what the command does fully, then trim noise
2. **Scenario-first TLDR** — each example targets one real use case, not parameter permutations
3. **First TLDR = simplest** — no format flags, no extra options; pure natural usage
4. **Format flags grouped early** — show `--csv`, `--tsv` once each in early TLDRs, then drop them
5. **Information density** — experts first; AI and agents need to know the module's ceiling

---

## Common Error Patterns

| Error | Fix |
|-------|-----|
| `<subcmd>:` wrapper | Define subcmds at root level |
| Changed alias order | Keep original: `c|cp|copy` not `c|copy|cp` |
| `<synopsis>` in subcmd | Use `<1>`, `<2>`, `<n>` in subcmds; `<synopsis>` is module-only |
| Efficiency TLDR in subcmd | Move all TLDR to root for assert/is/str |
| Unquoted `:` in desc | Wrap in quotes: `"Backend: value"` |
| Declaring `-h\|--help` | Remove; handled by `lib/main` |

---

## Workflow

### 1. Read the spec
```bash
x advise spec show            # full spec in TTY
x advise spec show | cat      # plain text for piping
```

### 2. Initialize template
```bash
x advise spec init            # copies tmpl.mod.yml → adv/index.yml
```

### 3. Write / edit `adv/index.yml`
Follow the field order: `<name>` → `<meta>` → `<synopsis>` → `<desc>` → `<tip>` → `<tldr>` → `<subcmd:Category>` → subcmd definitions.

### 4. Lint and verify
```bash
# From module directory
x advise spec lint

# Or specify path
x advise spec lint --path /path/to/module
```

Lint generates `advise.jso` and renders help. If it passes, the advise is structurally valid.

### 5. Install to local x-cmd
```bash
x scotty mod install          # installs adv/index.yml into x-cmd user directory
```

---

## Efficiency Module Checklist

Only `assert`, `is`, `str` qualify. Check before marking:

- [ ] `<meta>: <subcmd-help>: disable` is present
- [ ] ALL TLDR at root level
- [ ] NO `<tldr>` under any subcmd
- [ ] Subcmds have only `<desc>` (no options, no tldr)

---

## Standard Module Examples

Study these for specific patterns:

| Module | Pattern |
|--------|---------|
| `bwh` | Multi-part advise with `<ref>` |
| `line` | Subcmd categories, `_` suffix tip at module level |
| `dbnomics` | Scenario TLDR, auto mode, format flags |
| `assert` | Efficiency module |
| `str` | Efficiency module, pipe + arg dual input |

---

## Rules (x rule integration)

`rule/advise.rule.yml` lives next to this spec. Key rules:

| Rule | Level | Check |
|------|-------|-------|
| `ADV-syntax-indent` | error | 2-space indent, no tabs |
| `ADV-field-name-required` | error | `<name>` has cn + en |
| `ADV-field-tldr-min` | error | ≥3 TLDR items |
| `ADV-option-prefix` | error | Options precede args in all examples |
| `ADV-modify-order` | error | Subcmd alias order unchanged |
| `ADV-efficiency-tldr-root` | error | Efficiency TLDR only at root |

Run rule checks after editing:
```bash
x rule check -r /path/to/advise/lib/spec/resource/rule/ adv/index.yml
```

---

## Reference Commands

```bash
x advise spec show            # display spec
x advise spec init            # create tmpl.mod.yml
x advise spec lint            # validate and render
x advise ls                   # list loaded advise files
x advise cat <name>           # view advise.jso content
x advise which <name>         # path to advise.jso
```
