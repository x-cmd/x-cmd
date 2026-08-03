---
name: install
description: |
  Install software any way the system allows. Recommends `x install` — one front door listing every
  method and picking the best; plus `x eget`/`x env use`/`x pixi` channels and system package managers
  with mirror switching. All x-cmd channels install in $HOME — no sudo, no pollution.
  Use for "install", "apt", "brew", "eget", "pixi", "package manager", "mirror".
metadata:
  version: "0.1.0"
  category: "package-management"
  tags: "install,package-manager,eget,env,pixi,apt,brew,mirror"
  repository: "https://github.com/x-cmd/skill0"
  type: "skill0"
  related: "x-cmd,agent-browser,env"
---


# install — skill0

Install software any way the system allows. **All x-cmd channels (`x eget`, `x env use`, `x pixi`) install into `$HOME` — no sudo, no system pollution.** Only system package managers (`x apt`, `x brew`, …) touch the OS and may need sudo.

## Choose a channel

- `x install` — **Recommended.** One front door — lists every method for a tool, picks the best
- `x eget` — Latest binaries straight from upstream repos (GitHub / Codeberg releases)
- `x env use` — Runtimes & tools hosted by x-cmd (wraps `x pkg use`)
- `x pixi` — conda / pixi-ecosystem packages
- `x apt/brew/dnf/pacman` — System package managers (may need sudo)

## Prerequisites

x-cmd provides every channel above:
```bash
eval "$(curl https://get.x-cmd.com)"
```

## x install — the recommended front door

Every tool ships several install paths; `x install` auto-picks the best one. All forms below are non-interactive (agent / CI safe):
```bash
x install bun                            # install — auto-picks the best method
x install --printinfo ripgrep            # list every install method first (read-only)
x install --withtool brew jq             # force a manager; or prefix form: brew/jq
x install --sys bun                      # system package manager only
x install --printcmd bun vim             # preview the command, don't run
x install --env                          # platform / arch / distro probe
x install --available-tool --installed   # which package managers exist here
```

### Discover what's installable

`x install --ls` emits a TSV of every indexed tool — grep / awk it offline:
```bash
x install --ls --tsv | head -1                  # header
x install --ls --tsv | grep -i json             # search by keyword
x install --ls --tsv | awk -F'\t' '$3=="Rust"'  # filter by language
x install --search http                         # aggregate search across registries
```
TSV columns: `name category lang source desc_cn desc_en binlist rule other`.

## Change mirrors (faster downloads)

Redirect a slow system package manager to a faster / local mirror. Each has `mirror ls` (list options) and `mirror set <code>` (apply, non-interactive):
```bash
x brew mirror ls          # list: official, ali, tuna, bfsu, ustc, sjtu, ...
x brew mirror set tuna    # apply Tsinghua mirror
x apt mirror set tuna     # same shape on Debian / Ubuntu (also dnf, pacman)
```
Requires the target package manager to be installed.

## For more

- `x install`: https://x-cmd.com/mod/install · `x eget`: https://x-cmd.com/mod/eget
- `x env`: https://x-cmd.com/mod/env · `x pixi`: https://x-cmd.com/mod/pixi

## Related

- [x-cmd](../x-cmd/SKILL.md) — umbrella entry that fronts install
- [agent-browser](../../it/agent-browser/SKILL.md) — install routes to agent-browser when no binary exists
- [env](../env/SKILL.md) — install and env share x-channel architecture
