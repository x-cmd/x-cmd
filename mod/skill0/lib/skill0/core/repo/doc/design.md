# design rationale

This document explains **why** the x repo layout looks the way it does.
SKILL.md covers the operational rules; this covers the background, the threat model, and the geometric argument for the bare-in-`.bare`
separation.

Read this if you want to understand the reasoning, not just follow the recipe.

---

## the threat model

The single most important thing to internalize: **AI agents rm -rf things**.

Two failure modes have actually occurred in practice (the second one is the canonical incident that motivates this design):

1. **AI cleanup heuristic** — AI is told "clean up after the task" and rm -rfs
   the wrong directory.
2. **AI cross-context confusion** — AI is told "clean up" while working with
   both plain repos and bare+worktree repos in the same context. AI confuses
   "main checkout" with "an extra worktree, safe to delete" and rm -rfs the
   main checkout of a VIP repo. Concurrent agents holding worktrees of that
   repo lose their work.

These failures are not "AI is broken" — they are properties of how AI applies broad heuristics. The fix is **geometric**, not "train AI to be more careful".

---

## the core idea: separate the data, not the workflow

git worktree already gives us the right primitive: a single bare repo can hold many linked working trees. The question is **where the bare repo lives** — and that question is the entire design.

### naive: bare inside the project directory (the "poweruser" pattern)

```
project/
  .bare/                # real git data
  main/                 # human main worktree
  feat-auth/            # extra worktree
  fix-123/              # extra worktree
```

This looks tidy — one project, one place — but the AI threat model says:

- AI's `rm -rf project/` still kills `.bare/`.
- AI's "is this safe to delete?" heuristics treat `.bare/` as project
  metadata, exactly the kind of thing cleanup should remove.
- All worktrees of the project are in the same directory blast radius.

The pattern makes the protection **conditional on AI not making the exact mistake the protection is supposed to defend against**.

### what we do instead: bare in an independent subtree

```
~/.x-repo/
  .bare/                                                # bare repos, hidden
    github.com/x/other-vip-repo.git
    github.com/x/main-repo.git
  github.com/                                           # working trees, visible
    x/other-vip-repo/                                   # main wt (linked to .bare/)
    x/other-vip-repo@feat-auth/                         # extra wt
    x/main-repo/                                        # main wt
    x/main-repo@feat-xxx/                               # extra wt
```

Now to kill a bare, an attacker / bug / overzealous cleanup has to:

- target `~/.x-repo/.bare/...` **specifically** (no project or org level
  command reaches it)
- do so without `rm -rf` blowing up the rest of the workspace along the way

This is the geometric protection. It does **not** depend on the actor (human or AI) being careful.

---

## why the directory layout is what it is

### `~/.x-repo/.bare/<provider>/<owner>/<name>.git`

- `~/.x-repo/` is already the x-cmd convention for shared agent state — agents
  already know not to mess with it lightly.
- `.bare/` is dot-prefixed so casual `ls` doesn't surface it as "stuff to
  look at" or "stuff to clean".
- Mirroring the provider/owner/name path keeps it discoverable for debugging
  (`x repo bare <id>` resolves the absolute path).
- `.git` suffix is the standard git convention for bare repositories — git
  tooling recognizes it.

### `~/.x-repo/<provider>/<owner>/<name>` (default worktree)

- Identical to where a normal `git clone` would land. Agents and humans
  trained on `git clone github.com/foo/bar` see the exact same directory
  shape as the result.
- The worktree's `.git` is a file containing `gitdir: <bare-path>` — a
  one-line pointer to the bare. 99% of tools don't care that it's a file
  rather than a directory; `git` itself supports this natively (it's how
  worktrees work).
- This is also the answer to "why is there no `main` checkout category":
  **the default worktree is not special**. It's just one of the linked
  working trees. The "human main" concept dissolves into "the wt on the
  default branch".

### `~/.x-repo/<provider>/<owner>/<name>@<branch-encoded>` (extra worktree)

- Sibling of the default worktree, same depth, same parent directory.
- The `@` separator is reserved: GitHub/GitLab forbid `@` in repo names,
  and `git check-ref-format` allows but discourages it in branch names
  (so collisions are rare in practice). When we do see `@` in a branch
  name we split on the **first** `@` to disambiguate.
- Branch name's `/` segments are encoded to `~`:

  | branch | directory segment |
  |---|---|
  | `main` | `main` |
  | `feat/auth` | `feat~auth` |
  | `fix/123` | `fix~123` |

  This is what keeps every worktree at depth 3. If we let `/` through, `feat/auth` would create `repo/feat/auth/` — depth 4 — and any code that hard-codes `../sibling` from one wt to a sibling would silently miss because the parent is the repo, not the namespace.

  `~` is git-forbidden in branch names, so the encoding is **lossless**: every `~` in a directory came from our encoding of a `/`.

### why depth 3 (and no deeper)

- `github.com/x-bash/repo` is depth 3 from `~/.x-repo/`. Hard-coded
  `../<sibling>` works from any worktree because they share the same
  parent.
- depth 4 would mean agent worktrees nest inside the project — `repo@feat/`
  or worse `repo@feat/auth/` — and every cross-repo relative reference
  breaks.

---

## why `x repo wt` exists

Earlier design drafts argued that "x repo is a path manager, not a git wrapper" and pushed for agents to use raw `git worktree add` directly, given the bare path via a helper. That approach forced agents to know:

- that there is a separate `.bare/` tree
- the `/` → `~` branch encoding
- the `@<branch>` suffix
- the exact `git worktree add` incantation with `-b` / no `-b` switching

Every one of those is implementation detail that the agent has to remember.
The cost of remembering grows linearly with the number of worktrees an agent creates, and a mistake (e.g. `cd wt && git worktree add ../foo`, which silently produces a broken worktree because the parent wt's `.git`
is a file) can lose data.

`x repo wt <id> <branch>` / `wt ls` / `wt rm` collapses all of that into three verbs. The path encoding, the bare lookup, the attach-vs-create detection, and the cleanup semantics are all centralized in one place.

The principle is **the encapsulation cost is justified by the complexity it hides**. The old rule "don't wrap git" is a guideline, not a law — when the user-facing interface gets simpler, wrap.

---

## the three defense layers

Layers that protect against AI误删. They are **independent and complementary** —
any one failing is caught by the next.

| # | layer | nature | what it defends against |
|---|---|---|---|
| 1 | skill: AI only acts in worktrees | behavioral | limits AI误删 blast radius to a single wt |
| 2 | bare in independent subtree | geometric | keeps误删 of one wt from touching bare or other wts |
| 3 | `x repo wt rm` (graceful) | workflow | keeps the bare's `worktrees/` registry in sync with reality |

Earlier design drafts included "ls/util use git metadata" and "no x repo wt subcommand" as defense layers; these are now classified as **implementation quality** rather than defenses. They make the system more robust but don't directly counter AI误删.

`x repo wt rm` is layer 3 in practice: when an agent is done with a wt, the path of least resistance is the graceful `wt rm` (one command, registers the cleanup with git) rather than `rm -rf` (silently breaks the registry).
This is why SKILL.md says "never rm -rf a worktree" — it isn't about correctness, it's about preserving the invariants the rest of the design depends on.

---

## what is *not* solved by this design

To set expectations honestly:

- **AI hallucination itself** is not solved. We can only make accidents
  harder to cause and easier to recover from.
- **Force-pushes and dirty worktrees** during `wt rm` will fail loudly —
  that's git's job, not ours.
- **The user must know enough to use `x repo`**. Outside x repo's reach,
  the user is on their own. This is by design: x repo can only fix things
  inside the namespace it owns.