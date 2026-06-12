---
name: naming
description: Naming framework for x-cmd modules / commands / subcommands. Subjective + scenario-driven; the skill is a thin shell, NOT a rulebook. Three layers: investigate (goal), naming.<user-task>.yml (OKR + session record, a .rule file), naming.okr-creator.yml (meta-rule that audits the session).
---

# Naming

Naming is **subjective + scenario-driven**. This skill is a **framework**, not a rulebook — it does not bake in subjective naming rules.

## Quick map

```
┌─────────────────────────────────────────────────────────┐
│  1. INVESTIGATE goal                                    │
│     What is being named? What role? What concept?       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  2. naming.<user-task>.yml  (.rule file)                │
│     - goal-*        (the naming task)                   │
│     - keyresult-*   (verifiable outcomes)               │
│     - task-*        (task-specific constraints)         │
│     - session:      (audit trail on goal rule)          │
│         prefer     (5 init-004 answers)                 │
│         init_verdicts  (per-candidate gate decisions)   │
│         scores     (D1-D7 anchored per candidate)       │
│         final      (pick + backup)                      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  3. AUDIT with template/naming.okr-creator.yml          │
│     x rule check -r <naming-dir> naming.<user-task>.yml │
└─────────────────────────────────────────────────────────┘
```

## Workflow — step by step

### Step 1 · Investigate the goal

Before writing anything, answer these questions. Do NOT skip — without answers, the scorer cannot anchor D4 (TRIAL/REAL) or D5 (RUN/TEST).

| Question | Why it matters |
|---|---|
| **What is being named?** | module / subcommand / field / variable — different naming form rules apply |
| **What role does it play?** | anchors the concept (e.g. "trial-run module" → standalone runner, Stage 1 of two-stage test) |
| **What prior MUST it carry?** | the dominant bare-word sense has to match (e.g. trial-run needs TRIAL+RUN, not REAL+TEST) |
| **What priors MUST it AVOID?** | unittest pollution (`*test`/`*case`), fake (`*mock`/`*fake`/`*stub`/`*dry`), real deployment (`field*`/`*live*`) |
| **What archetype fits?** | ship / plane / rocket / factory / abstract — drives D6/D7 |

Output: a one-line goal statement, e.g.
> "Pick a standalone x-cmd module name for trial-run (Stage 1 of two-stage test) that scores 8.0+ on D1-D7, is self-explanatory at first glance, and survives all red-line / dictionary / length fast-fails."

### Step 2 · Create the session record

Copy the template and crop / fill.

```bash
cp naming.template.yml naming.<user-task>.yml
```

Then fill in 4 sections (top-down):

#### 2a. Goal rule (the naming task)

Replace `goal-TBD_task_id` with a real ID. The ID suffix should reflect the task (e.g. `goal-trial-run-naming`, `goal-mvp-prerelease-subcmd`).

```yaml
goal-trial-run-naming:
  name: <one-line goal statement from Step 1>
  apply: "naming.<user-task>.yml (self)"
  level: error
  desc:
  - <concept + role + anti-priors, from Step 1>
```

#### 2b. Key results (verifiable outcomes)

Replace each `keyresult-kr*_TBD_short_label`. Each KR is a rule that must be PASS-able. Add as many as the task has.

```yaml
keyresult-kr1-top-pick-committed:
  name: <verifiable outcome 1>
  level: error
  desc:
  - <what counts as passing — concrete criterion, not "looks good">
```

#### 2c. Task-specific rules (constraints on candidates)

Replace each `TBD_task_id-*` with a real constraint ID matching the goal's task-id suffix. Crop the ones that don't apply, add new ones as needed.

Common patterns:
- `must-be-X-not-Y` — concept alignment (e.g. `must-be-TRIAL-not-REAL`)
- `length-N-to-M-letters` — D1 hard range
- `must-imply-<archetype>` — D7 binding
- `<domain>-specific-acceptable` / `not-acceptable` — narrow domain permission
- `must-be-self-explanatory` — D3

```yaml
trial-run-001:
  name: <constraint, e.g. "must-be-TRIAL-not-REAL">
  apply: "candidate words for <task-id>"
  level: error | warn
  desc:
  - <what the candidate must satisfy>
  - <which D1-D7 dimension this constrains>
  tldr:
  - wrong: <anti-example>
  - right: <good example>
```

#### 2d. Session record (audit trail on the goal rule)

Fill all 4 sub-sections:

**prefer** — MUST answer all 5 questions, even if the answer is "no / weak":
```yaml
prefer:
  vivid: yes | no | weak
  domain_acceptable: [<list of narrow domains OK, e.g. [naval]>]   # [] = no narrow domain OK
  length_priority: shorter | self_explanatory
  origin: english | chinese | coined
  trade_off: single_prior_ok | hit_every_dim
```

**init_verdicts** — one entry per candidate considered, including rejects:
```yaml
init_verdicts:
  - { name: <candidate>, gate: init-005 | init-006 | init-007 | pass, reason: "<why>" }
  # init-005 = red-line pattern match (auto-reject)
  # init-006 = dictionary first meaning contradicts target
  # init-007 = length out of range (< 2 or > 8)
  # pass     = passed all init gates, eligible for scoring
```

**scores** — one entry per candidate that passed init. All scores >= 6.0. Every score MUST have anchors:
```yaml
scores:
  - name: <candidate>
    score: <0_to_10>
    anchors:
      - "D1: <letter count evidence>"
      - "D2: <dictionary first meaning evidence>"
      - "D3: <compound literal evidence>"
      - "D4: <trial vs real evidence>"
      - "D5: <run vs test evidence>"
      - "D6: <vividness evidence>"
      - "D7: <large equipment evidence>"
    misses:
      - "<what's missing — only list real misses, not always all 7>"
```

**final** — declare the pick + backup:
```yaml
final:
  pick: <winning_candidate>
  backup: <runner_up_or_null>
```

### Step 3 · Audit with the meta-rule

```bash
x rule check -r <naming-dir> naming.<user-task>.yml
```

The OKR-creator (at `template/naming.okr-creator.yml`) runs 11 checks (mix of error and warn):

| Check | Level | What it verifies |
|---|---|---|
| `okr-creator-001` has-goal-rule | error | file has ≥1 `goal-*` rule |
| `okr-creator-002` has-keyresult-rules | error | file has ≥1 `keyresult-*` rule |
| `okr-creator-003` has-task-specific-rules | error | file has ≥1 task rule (not goal/keyresult) |
| `okr-creator-010` has-session-record | error | goal rule has `session:` field |
| `okr-creator-011` prefer-answers-all-five | error | all 5 init-004 questions answered |
| `okr-creator-012` init-verdicts-recorded | error | init_verdicts non-empty |
| `okr-creator-013` scores-have-anchors | error | every score has non-empty anchors list |
| `okr-creator-014` scores-no-below-6 | error | all scores >= 6.0 |
| `okr-creator-015` final-section-present | error | `final.pick` declared |
| `okr-creator-020` pick-backup-gap-le-1 | warn | score(pick) - score(backup) <= 1.0 |
| `okr-creator-021` top-pick-at-least-7 | warn | pick score >= 7.0 |

**If any error check fails**: fix the file and re-run. Common fixes:
- Missing prefer field → add to `session.prefer`
- Bare score → add `anchors: [...]`
- Score < 6 → move to `init_verdicts` (rejected) or reframe the score
- Missing final → add `final: { pick, backup }`

**If warn checks fail**: decide whether to address or document the trade-off.

### Step 4 · User picks the final name

The skill proposes; the user decides. The final name is declared in `session.final.pick` and committed.

## Files

| File | Role | Format |
|---|---|---|
| `SKILL.md` | This file — workflow + file index | markdown |
| `naming.template.yml` | TEMPLATE with `TBD_*` placeholders — copy, rename, fill | `.rule` |
| `naming.trial-run-module.yml` | Worked example of a complete session record | `.rule` |
| `template/naming-concept.yml` | Objective evaluation framework (D1–D7, red-lines, scoring anchors) — as `.rule` entries | `.rule` |
| `template/naming-brand.yml` | x-cmd brand rules (length, case, prior preferences) — as `.rule` entries | `.rule` |
| `template/naming.okr-creator.yml` | Meta-rule: audits a `naming.<user-task>.yml` (the 11 checks above) | `.rule` |
| `template/naming-x-cmd-mod.yml` | Optional x-cmd module naming preset (starter session record) | `.rule` |

## Subjective vs objective split

| Objective (in files / code) | Subjective (asked at init, not scored) |
|---|---|
| Dictionary first meaning | "I want vivid vs abstract" |
| Letter count | "I want domain X acceptable" |
| Trial / Real / Run / Test semantic class | "I want naval metaphor OK or not" |
| Compound literal meaning | "I want Chinese-origin vs English-origin" |
| Prior pollution (unittest testcase, dryrun) | "I want short over self-explanatory" |

## Rules

- **MUST** investigate the goal first — what is being named, what role it plays, what concept anchors.
- **MUST** start from `naming.template.yml` (TBD_* placeholders) and crop / fill as the task requires.
- **MUST** produce a `naming.<user-task>.yml` (`.rule` format) with goal / key results / task rules / session record.
- **MUST** run `x rule check` with `template/naming.okr-creator.yml` to audit the session record.
- **MUST** anchor scores in objective facts — never inflate/deflate based on user reaction.
- **MUST** let user pick the final name — the skill proposes, the user decides.
- **MUST NOT** add subjective rules to `template/naming-concept.yml` — those go into the per-task `session.prefer`.
