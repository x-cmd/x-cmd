# workflow · general operating procedure & cleanup-non-deletion principles

> When and how agents should create worktrees, when to delete them, and
> when **not** to delete. Read this once before doing significant multi-repo
> work; refer back when in doubt.

This document sits alongside SKILL.md (recipe) and design.md (why).
**SKILL** tells you what commands exist; **this** tells you how to use them sensibly across a multi-agent workflow; **design** tells you why the layout looks the way it does.

---

## the real waste we're solving

Before the workflow rules, a note on **why** x repo looks the way it does.

The actual waste we care about is **the same repo being cloned over and over**:

- the same user, on the same machine, clones `x-bash/repo` into three
  different directories because each build script invents its own path
- the same user, on the same host, opens a new container, clones
  `x-bash/repo` again — and again — and again
- the same user, switching between machines, re-clones because each
  machine has its own local copy

x repo's design defends against this by **mirroring the provider path 1:1**: `github.com/x-bash/repo` lives at `~/.x-repo/github.com/x-bash/repo`, everywhere, deterministically. Given the URL, you (or an agent) know the local path; given the local path, you know which repo it is.

Consequences:

- **one clone per repo per machine** — no path drift, no re-cloning
- **portable across hosts** — the path is the same everywhere, so NFS or
  a shared home directory works directly
- **portable across containers** — mount `~/.x-repo/` into the container
  instead of re-cloning
- **predictable from the URL** — an agent can compute the local path
  without querying x repo, and vice versa

This is why the path convention is not a stylistic preference but a **data-reuse strategy**. The default `~/.x-repo/<provider>/<owner>/<name>` shape is the cheapest way to ensure no two clones of the same repo exist on the same machine.

**Use this to your advantage**:

- if you have multiple machines, set up the same path everywhere (NFS,
  shared home, scripted setup). The clone you made on machine A is the
  clone you can use on machine B.
- if you work across host and container, mount `~/.x-repo/` into the
  container — don't re-clone.
- if you find yourself about to clone `x-bash/repo` for the third time on
  the same machine, stop and check `x repo ls` first — it's probably
  already there.

This is a recommendation, not a rule — take what's useful for your situation. The data-reuse gain is largest in multi-host / multi-container / long-running setups; for one-off scripts on a single laptop the gain is smaller but the cost (convention overhead) is also small.

Note that **different devices have different disk budgets**: a beefy workstation with terabytes to spare, a shared NFS mount you don't want to fill, a laptop with a 256 GB SSD, a container with a small overlay volume — each fits a different strategy. NFS / shared mounts aren't practical when the network is slow or unreliable; keeping clones local isn't practical when local disk is tight. **Pick a strategy that fits your devices' constraints**, and re-evaluate as the device mix changes.

---

## workflow

### 1. independent agent development: name your worktree

If you are an agent doing solo work on a branch, create a worktree whose **wtname** (the part after `@`) identifies **you** or **your task**, so others (humans or agents) can see at a glance what's going on. The wtname can be **any** identifier — a branch name, an agent name, an issue id, a date, anything that helps your collaborators:

```bash
# by agent name (long-running personal branch)
x repo wt x-bash/repo agent-claude/cleanup-pass

# by issue / ticket id (task-scoped branch)
x repo wt x-bash/repo fix-1234
x repo wt x-bash/repo issue-567

# by tag (point at a specific release)
x repo wt x-bash/repo v1.2.0

# by short SHA (point at a specific commit)
x repo wt x-bash/repo abc1234
```

The directory will end up at `~/.x-repo/<provider>/<owner>/<repo>@agent-claude~cleanup-pass` or similar — the encoding preserves the hierarchy without breaking the depth-3 layout, and the directory name tells everyone on the system who's working on what.

### 2. preparing a fresh repo: default wt is for humans, not for you

When `x repo prepare <repo>` runs on a repo that doesn't exist locally, it clones the bare and creates the **default worktree** (one per repo, on the default branch). That default wt is the **stable, human-facing view** — other worktrees and human sessions may depend on it.

As an agent, you should **not** start working in the default wt. Create your own:

```bash
# this just brought x-bash/repo to your machine
x repo prepare x-bash/repo x-bash/wsl
# /Users/l/.x-repo/github.com/x-bash/repo       <- default wt, for humans
# /Users/l/.x-repo/github.com/x-bash/wsl        <- default wt, for humans

# claim your own workspace
x repo wt x-bash/repo feat/my-task
x repo wt x-bash/wsl feat/my-task
# ~/.x-repo/.../x-bash/repo@feat~my-task
# ~/.x-repo/.../x-bash/wsl@feat~my-task
```

This way:

- the default wt stays clean (no in-progress edits that block the human)
- your work is isolated and removable as a unit
- `../<sibling>` references work between your worktrees (both at depth 3)

### 3. after a successful merge: refresh the default wt

When your PR merges into main, the default wt is now stale — it still points at the pre-merge commit. Update it so anyone (you, the human, other agents) who `cd`s in sees current main:

```bash
x repo update x-bash/repo    # fetch + ff-merge in the default wt
```

This is **the agent's responsibility** at the end of their task. It's cheap (one fetch, one ff-merge) and it keeps the workspace honest.

If you skip this and someone else updates the default wt first, that's fine — the operation is idempotent. Just don't be the one who left the default wt pointing at a pre-merge commit for days.

---

## cleanup · don't delete, then do delete carefully

The instinct after a task is "clean up everything I created." With worktrees this instinct is **partly wrong** and **partly expensive**.

### 1. don't rush to delete a worktree — build caches are expensive

Modern repos have heavy build caches:

- node_modules / venv / cargo target / go build cache — **gigabytes**
- incremental compilation caches — re-download + rebuild is **minutes**
- language servers' analysis cache — re-indexing is **CPU + memory bound**

A worktree shares its build cache with the rest of the repo at the OS level (hard links, copy-on-write, or simply a shared cache directory), so **deleting a worktree often invalidates nothing**. The cache lives on.

But if you delete too eagerly and the cache actually does get cleaned up (some `cargo clean` / `rm -rf node_modules` workflows do this aggressively), the next task on a fresh worktree pays the full rebuild cost.

**Default**: keep worktrees around until the result is settled (PR merged, branch deleted upstream, or you're sure you won't iterate again). The disk cost is usually small relative to the rebuild cost.

### 2. when the task is done: delete your worktrees, **not** the defaults

When you're sure you don't need a worktree anymore:

```bash
x repo wt rm x-bash/repo feat/my-task    # graceful, registry stays in sync
```

What **must not** be deleted:

- the default worktree (`~/.x-repo/<provider>/<owner>/<name>` — no `@`)
- the bare repo (`~/.x-repo/.bare/<provider>/<owner>/<name>.git`)

Both of these are **shared infrastructure**:

- the default wt is the human's stable view of the repo; other agents
  and human sessions may have it open
- the bare holds the git history and the `worktrees/` registry; if it
  goes, every other worktree of this repo breaks

The bare is the thing the whole geometric protection design is built around. Treat it as the durable record. Don't delete it on task completion; delete it only when the repo is genuinely no longer of interest (and even then, prefer `x repo rm <id>` if it exists, which removes both the bare and the default wt atomically — check the help output for current behavior).

### 3. if you really must delete: audit first

If you're in a "tidy up everything" mood and want to delete more than your own worktrees:

```bash
x repo wt ls <id>          # what worktrees does this repo have?
x repo ls --tsv            # all repos on this machine
```

For each thing you might delete, ask:

- is anyone else using it? (`x repo wt ls` shows paths; check for recent mtime)
- is it the default wt for a repo? **don't delete**
- is it the bare? **don't delete** (unless you're removing the whole repo)
- is it your own worktree from a finished task? safe to delete via `x repo wt rm`

If you can't answer "no one is using this" with confidence, leave it alone. The disk cost of leaving worktrees around is small; the cost of breaking another agent's working state is real.

---

## summary

| action | who | when | how |
|---|---|---|---|
| prepare multi-repo workspace | agent or human | start of task | `x repo prepare <id>...` |
| create own worktree | agent | start of own work | `x repo wt <id> <branch>` |
| refresh default wt after merge | agent who merged | end of task | `x repo update <id>` |
| delete own finished worktree | agent | when result is settled | `x repo wt rm <id> <branch>` |
| **never** | anyone | — | `rm -rf` worktree directory (breaks registry) |
| **never** | anyone | — | delete the bare or default wt directly |

---

## end-to-end example

**Scenario**: agent is asked to fix issue #1234 in `x-bash/repo`. The fix needs to touch `x-bash/wsl` as well — `x-bash/repo` consumes `x-bash/wsl`
via a hard-coded `../wsl` reference in build scripts. The agent is named `claude` and works in branch `fix-1234`.

### step 1 — prepare

```bash
x repo prepare x-bash/repo x-bash/wsl
# /Users/l/.x-repo/github.com/x-bash/repo
# /Users/l/.x-repo/github.com/x-bash/wsl
```

After this, the layout on disk is:

```
~/.x-repo/
  .bare/
    github.com/x-bash/repo.git
    github.com/x-bash/wsl.git
  github.com/x-bash/
    repo/                          # default wt for repo
    wsl/                           # default wt for wsl
```

The agent reads the two printed paths and confirms `../wsl` will resolve to the default wt of `x-bash/wsl`. **The default wts are for humans**, not the agent's workspace.

### step 2 — claim your own worktrees

```bash
x repo wt x-bash/repo claude/fix-1234
x repo wt x-bash/wsl claude/fix-1234
# both branches are new, so each gets `-b <branch> HEAD`
```

After this:

```
~/.x-repo/github.com/x-bash/
  repo/                          # default wt, untouched
  repo@claude~fix-1234/          # agent's wt for repo
  wsl/                           # default wt, untouched
  wsl@claude~fix-1234/           # agent's wt for wsl
```

The agent `cd`s into `repo@claude~fix-1234/` and edits. The hard-coded `../wsl` in build configs now points at `wsl@claude~fix-1234/` — exactly the wsl snapshot the agent wants to test against.

### step 3 — do the work, push, open PR

Standard git workflow inside the wt:

```bash
cd ~/.x-repo/github.com/x-bash/repo@claude~fix-1234
git add ... && git commit -m "fix: ..."
git push -u origin claude/fix-1234
# open PR via gh / web / whatever
```

The agent does **not** touch the default wt `repo/` while working. The default wt stays at clean main, available for anyone (human or other agent) who `cd`s in.

### step 4 — PR merged, refresh the default wt

After the PR is merged upstream:

```bash
x repo update x-bash/repo    # fetch + ff-merge in default wt
x repo update x-bash/wsl     # also refresh wsl default
```

Now `~/.x-repo/github.com/x-bash/repo/` reflects post-merge main. Anyone opening the default wt sees current state, not stale pre-merge commits.

### step 5 — wait, then clean up

The agent waits until they're sure they don't need to iterate (a day or two, or until the next task comes along). Then:

```bash
x repo wt rm x-bash/repo claude/fix-1234
x repo wt rm x-bash/wsl  claude/fix-1234
```

The default wts `repo/` and `wsl/` and both `.bare/*.git` bares are **untouched** — they remain as shared infrastructure and as the durable record of the work.

### what **not** to do during this scenario

- ❌ `rm -rf repo@claude~fix-1234` instead of `x repo wt rm` — breaks
  the bare's `worktrees/` registry
- ❌ editing directly in `repo/` (the default wt) — that's the human's
  view, leave it for them
- ❌ `rm -rf ~/.x-repo/.bare/...` to "save space" — the bare is the
  data, deleting it kills every other wt of this repo
- ❌ re-cloning `x-bash/repo` from scratch because "I want a fresh
  state" — `x repo wt ls x-bash/repo` first; the data is shared, you
  don't need a second copy