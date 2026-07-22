---
name: score-vs-rule
description: Score vs Rule — score ranks weighted candidates (pick the best); rule gates pass/fail (find problems). Decision matrix for when to use which; many workflows combine both.
---

# Rule vs Score

Two complementary frameworks for different problems.

| | Rule | Score |
|---|---|---|
| **Purpose** | Find problems — ensure minimum quality | Evaluate quality — pick the best option |
| **Analogy** | Quality gate / checklist | Ranking / leaderboard |
| **Output** | Pass / fail per rule | Weighted total + rank |
| **Typical target** | Single object (one file, one repo, one system) | Multiple candidates (3+ alternatives to compare) |
| **Action after** | Fix the violations | Make a decision |
| **Question answered** | "Is this good enough?" | "Which one is best?" |
| **Hard filter** | Rule `level: error` = must pass | TSV `block` column = disqualified, rank X |

## How scoring works

**Score**: weighted by factor, 100-point scale.

```
total = Σ(factor × score) ÷ Σ(factor) × 10   →   0–100
```

Each dimension has a 0-10 score and a factor (1-10, baseline=2). Dimension headers show weight %. Factors amplify — a dimension with factor 8 counts 4× more than factor 2. The formula normalizes automatically.

**Rule**: counted by rule. No weighting, no aggregation.

One object checked against N rules → N independent results. Each rule gives a score 0-100 on its own — 100 = pass, below 100 = violation. You don't average them. If 3 out of 10 rules fail, you have 3 problems to fix.

```
pass_count = number of rules with score = 100
fail_count = number of rules with score < 100
```

## Typical scenarios

### Rule scenarios — "is there a problem here?"

| Domain | Example rule | What it checks |
|--------|-------------|----------------|
| Code quality | `no-console-log` | Production code must not have `console.log` |
| Documentation | `doc-orphan-010` | Every .md must be referenced from a SKILL.md |
| Config safety | `no-hardcoded-secrets` | No API keys or passwords in committed files |
| Structure | `rule-struct-010` | Every rule.yml must have a `desc` field |
| Naming | `file-naming-convention` | Files must follow the naming pattern |
| Git hygiene | `no-merge-commit-to-main` | Main branch only accepts squash/rebase |

The question is always: "does this object violate the rule?" The answer is always: "yes (score < 100, here's the violation)" or "no (score = 100)."

### Score scenarios — "which one should I pick?"

| Domain | Example template | What you're choosing between |
|--------|-----------------|------------------------------|
| Tech | `tech-stack` | Python vs Go vs Rust for a new service |
| Life | `house` | 3 apartments you toured last weekend |
| Career | `job` | 2 job offers on the table |
| Consumer | `car` | SUV vs sedan vs EV |
| Plants | `plant-cat` | 12 plants that are safe for your cat |
| Pets | `pet-office` | What pet to keep at the office |
| Gifting | `gift` | What to buy for your girlfriend's birthday |
| Travel | `travel` | Where to go for the next holiday |

The question is always: "among these candidates, which is best?" The answer is always a ranked list with scores — and the user may disagree and want to adjust factors.

### Combined scenarios — rule then score

Some decisions need both:

1. **Rule** eliminates non-viable candidates ("this plant is toxic → out")
2. **Score** ranks the survivors ("among the safe plants, which is easiest to care for and prettiest?")

Other examples:
- Job search: rule filters out companies without visa sponsorship → score ranks offers by comp, growth, culture
- Apartment: rule filters out over-budget / no-pets buildings → score ranks by commute, space, neighborhood
- Library choice: rule filters out unmaintained libraries → score ranks by API design, performance, community

## But the boundary is soft

- A rule can check multiple files. A score can evaluate a single candidate.
- The distinction is **intent**, not object count.
- If the question is "does this pass?" → rule.
- If the question is "how good is this, compared to alternatives?" → score.

## When to use which

**Use rule when:**
- You have a clear pass/fail criterion (field must exist, value must be in range)
- You're enforcing standards across a codebase
- Violations are actionable — you know exactly what to fix
- Example: "every .rule.yml must have a `desc` field"

**Use score when:**
- You're comparing options and need a decision
- Criteria are preferences, not absolutes (weighing trade-offs)
- The answer depends on the user's priorities (factor tuning)
- Example: "which framework should we use for this project?"

**Use both when:**
- First, rule filters out non-viable candidates (hard gates)
- Then, score ranks the survivors (weighted comparison)
- Example: rule blocks toxic plants → score ranks safe ones by care difficulty and aesthetics

## See also

- [SKILL.md](SKILL.md) — weighted dimension scoring framework (this skill)
- [../rule/SKILL.md](../rule/SKILL.md) — rule-based compliance checking
