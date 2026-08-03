# path layout

Detailed directory structure for the three kinds of paths x repo manages. SKILL.md carries the operational rules; this is the full grammar behind them.

## the three kinds

| kind | path | purpose |
|---|---|---|
| **bare** | `~/.x-repo/.bare/<provider>/<owner>/<name>.git` | git history + worktree registry. Hidden under `.bare/`. |
| **default worktree** | `~/.x-repo/<provider>/<owner>/<name>` | Auto-created by `x repo update <id>`. Default branch. **Human's view** — leave it for humans. |
| **designed worktree** | `~/.x-repo/<provider>/<owner>/<name>@<wtname>` | Created on demand via `x repo wt <id> <wtname>`. One per identifier / agent. **Agent's workspace**. |

## layout diagram

```
~/.x-repo/
  .bare/                                          # bare git data, hidden
    github.com/x-bash/repo.git
    github.com/x-bash/skill0.git
  github.com/                                     # working trees, visible
    x-bash/repo/                                  # default worktree (auto-created)
    x-bash/repo@feat-auth/                        # designed worktree on feat/auth
```

## depth-3 invariant

All paths are exactly **3 levels deep** under `~/.x-repo/` (`<provider>/<owner>/<name>`).

- `github.com/x-bash/repo` → 3 levels (`github.com` / `x-bash` / `repo`)
- `github.com/x-bash/repo@feat~auth` → still 3 levels (`github.com` / `x-bash` / `repo@feat~auth`)

This invariant makes `../<sibling>` from any worktree resolve uniformly to the sibling's default worktree — no matter whether you're in a default wt, a designed wt, or a plain clone.

## plain git clones

A plain `git clone` (no bare, no worktree management) **works** — drop it at `~/.x-repo/<provider>/<owner>/<name>` or any other layout-conforming path and `x repo ls`, `x repo which`, `x repo update` see it alongside bare+wt repos.
The depth-3 invariant is what makes this work: as long as the path matches, x repo resolves it the same way.

The trade-off: a plain clone has no `.bare/` separation. `rm -rf` of the directory deletes `.git/` along with the working tree. The user accepts this when choosing a plain clone; all x repo commands keep working either way.

## wtname encoding

wtname can be any string. The only transformation is `/` → `~`:

- `feat/auth` → `feat~auth`
- `fix/123/bug` → `fix~123~bug`
- anything without `/` passes through unchanged

Reversible: `~` in a directory name always came from our encoding of `/` (git ref names forbid `~`).

## override root with X_REPO_ROOT

For power users who need a different root — see [design.md](./design.md) and the advanced-customization story at x-bash/repo for the only supported escape hatch (`X_REPO_ROOT`). Not documented in the default skill because it is not the recommended path.