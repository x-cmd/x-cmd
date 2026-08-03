---
name: repo
description: Convention + tooling for where agent-cloned repos live and how their worktrees are arranged. Default bare repo at `~/.x-repo/.bare/<provider>/<owner>/<name>.git` with linked working trees under `~/.x-repo/<provider>/<owner>/<name>[/@<wtname>]`. Discovered via `x repo ls`. Worktree management via `x repo wt`. Use for "where to clone", "git clone path", "workspace layout", "shared repos between agents", "worktree path".
metadata:
  related: "git"
---

# repo

## Why

All clones converge at `~/.x-repo/<provider>/<owner>/<name>`. Same path for every agent, human, CI — mountable into containers or agent sandboxes so they share without re-cloning. One root to back up; discoverable via `x repo ls`. Layout mirrors github paths so `../<sibling>` from any worktree resolves to that sibling's default worktree — configs and scripts that reference siblings work uniformly across wts and agents.

## Path layout

- bare: `~/.x-repo/.bare/<provider>/<owner>/<name>.git`
- default wt: `~/.x-repo/<provider>/<owner>/<name>`
- designed wt: `~/.x-repo/<provider>/<owner>/<name>@<wtname>`

`@<wtname>` — wtname is any identifier for this workspace: agent/worker name, branch name, tag, short SHA, issue id, free-form string. `/` in wtname encodes to `~`.

By default, repos are bare with linked worktrees — the bare in `.bare/`, a separate directory from the worktrees, so `rm -rf` of one wt can't reach it. Plain `git clone` is also accepted (`x repo ls/which/update` see it) but without geometric protection. Please be careful in that case: don't `rm -rf`, prefer `git worktree remove`, and avoid cleanup heuristics that target `.git/`. Mid-task work lost this way can't be realigned with the original repo.

## Commands

```bash
x repo <id>                      # cd to default wt (auto-clones if missing)
x repo wt <id> <wtname>          # attach to existing branch, or create new from HEAD
x repo wt ls <id>                # list wts
x repo wt rm <id> <wtname>       # graceful remove (use this, not rm -rf)
x repo update <id>               # refresh default wt after upstream changes
x repo ls [--raw|--tsv]          # discover what's cloned
x repo which <id>[@<wtname>]     # resolve id to absolute path
```

## Don't

- `rm -rf` a designed worktree. It leaves stale entries in the bare's `worktrees/` registry. Use `x repo wt rm`. If you must, run `git -C <bare> worktree prune` afterwards.

## Related

- [doc/path-layout.md](doc/path-layout.md) — full path grammar and worktree naming
- [doc/workflow.md](doc/workflow.md) — operating procedure and cleanup-non-deletion principles
- [doc/design.md](doc/design.md) — why the layout is shaped this way
