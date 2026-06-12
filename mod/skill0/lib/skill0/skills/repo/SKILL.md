---
name: repo
description: Convention + tooling for where agent-cloned repos live. Default `~/.x-repo/<provider>/<owner>/<name>`, discovered via `x repo ls`. Use for "where to clone", "git clone path", "workspace layout", "shared repos between agents".
---

# repo

`x repo` defines the **default clone location** for AI agents: `~/.x-repo/<provider>/<owner>/<name>`. Place new clones there unless the user names a different path or an existing convention applies.

## Default layout

```
~/.x-repo/
  github.com/
    x-bash/skill0
    x-bash/repo
  gitlab.com/
    my-team/internal-tool
  gitee.com/
    some-user/demo
```

- `provider` — host domain (`github.com`, `gitlab.com`, `gitee.com`, …)
- `owner` — user or org
- `name` — repo basename

Override the root with `X_REPO_ROOT` (when the default `~/.x-repo` is unsuitable, e.g. small home disk or a shared network mount):

```bash
export X_REPO_ROOT="$HOME/agents/repo"
```

## Why this layout

- **Shared across agents** — every agent sees the same tree
- **Discoverable** — `x repo ls` finds anything already cloned
- **Reusable clones** — re-cloning the same repo into a different path is wasteful
- **Ready for sync / shared cache** — upcoming `x repo` features (push, sync, cache) assume this layout

## Discover what's already cloned

```bash
x repo ls --raw    # provider/owner/name   (scriptable)
x repo ls --tsv    # provider, owner, name, filepath   (with header)
```

Default is interactive (`csv app`) on a TTY, TSV when piped. Use `--raw` when scripting.

## Clone to the convention

```bash
url="https://github.com/x-bash/skill0"
provider="$(printf '%s' "$url" | awk -F/ '{print $3}')"
path="${X_REPO_ROOT:-$HOME/.x-repo}/$provider/x-bash/skill0"
mkdir -p "$(dirname "$path")"
git clone "$url" "$path"
```

If `x repo ls --raw` already lists the target, `cd` into the existing clone instead.

## Rules

- **MUST** default new clones to `~/.x-repo/<provider>/<owner>/<name>` unless the user names a different path.
- **MUST** re-use an existing clone (`x repo ls --raw`) instead of cloning a second copy.
- **MUST NOT** invent a new path layout (e.g. `~/projects/<repo>`, `~/work/<repo>`) when this convention applies.
- **MUST** honor `X_REPO_ROOT` when set — it is authoritative.

## For more information

- `x repo --help` — subcommand reference
