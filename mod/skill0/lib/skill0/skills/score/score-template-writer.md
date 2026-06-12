---
name: score-template-writer
description: How to write a good `.score.yml` template for the score framework — comment format, choosing 5-7 dimensions, factor assignment (baseline=2), writing anchored desc, file naming, and anti-patterns.
---

# Score Template Writer

How to write a good `.score.yml` template for the skill0/score framework.

A template is a **reusable scoring standard** that agents can copy with `x score init -t <name>` and customize. It should work out of the box for the most common case, while guiding the agent to adapt it for edge cases.

## Template comment format

Every template file has two kinds of comments: a **header block** that lists adjustable dimensions, and **inline notes** on individual dimensions.

### Header comment block

```
# <filename> — <one-line English description>

# == Notes for Agents ==
# This is the default standard for <scenario>. Adjust based on user needs:
#
# Common adjustments:
#   - <condition>? → <action>: add/remove <dimension>, bump <factor> to <value>
#   - <condition>? → <action>: swap <dim-a> for <dim-b>
#   ...
#
# Draft then iterate: run with defaults first, user feedback will reveal gaps.
```

Rules:
- The header lists concrete, actionable conditions — not vague suggestions.
- Each line follows `条件 → 动作` or `condition → action`.
- Always end with the "draft then iterate" reminder.
- Keep it scannable. An agent should be able to read the bullets in 10 seconds and know what to ask the user.

### Dimension inline comments

```
  - name: <dim>
    factor: <n>
    desc: "<0-10 anchored description>"
    # If <condition>, bump factor to <value>. Optional: split into <sub-dims>.
```

Rules:
- Inline comments are optional. Use them when a dimension often needs adjustment.
- Keep to one line. If it takes three lines, it belongs in the header block.

## Choosing dimensions

### Discovery process

1. **Ask the user what matters.** "When picking a <thing>, what do you care about most?"
2. **List 3-5 core dimensions.** These are the non-negotiable factors.
3. **Probe for hidden constraints.** "Do you have pets? Allergies? Budget limits? Specific environment?"
4. **Map each answer to a dimension or an exclusion.** Not every constraint needs a dimension — some are hard filters (e.g. "must be non-toxic to cats").

### Dimension design rules

- **5-7 dimensions is the sweet spot.** Fewer than 4 feels shallow; more than 8 creates noise.
- **Every dimension must actually differentiate candidates.** If all candidates score the same on a dimension, it's wasted weight.
- **Avoid overlapping dimensions.** "Aesthetics" and "beauty" are the same thing. Merge them.
- **Prefer concrete over abstract.** "Survives 2 weeks without watering" > "Low maintenance".

## Factor assignment

Baseline = **2** (normal importance). Scale:

| Factor | Meaning | When to use |
|--------|---------|-------------|
| 1 | Minor consideration | Nice-to-have, barely influences decision |
| 2 | Baseline | Normal weight, equal among peers |
| 4 | 2× important | Clearly more important than baseline |
| 6 | 3× important | Very important, drives the decision |
| 8 | 4× important | Critical dimension |
| 10 | 5× important | Dominant factor — rarely used, reserved for deal-breakers |

Guidelines:
- The most important dimension gets 8 or 10. Don't be shy.
- Most dimensions should be 4 or 6. If everything is baseline, the template is too generic.
- Factor 1 is for dimensions you include "just in case" but don't expect to matter.
- Factors don't need to sum to anything. The formula normalizes automatically.

## Writing desc

### Format

```
"<What this dimension measures>. <High score anchor>: <description>; <Low score anchor>: <description>; <Zero>: <description>."
```

### Rules

1. **Anchor 9-10 and 1-2 concretely.** The middle scores are inferred. The edges must be vivid.
2. **Describe observable facts, not feelings.** "No visible dust on leaves after 1 week" > "Looks clean".
3. **Zero means zero.** Define what "completely fails this dimension" looks like.
4. **Keep it under 200 characters.** If it's longer, the dimension is probably too vague.

### Examples

Good:
```
"Survival difficulty — watering frequency, humidity sensitivity, survives 1-week business trip. 9-10: nearly unkillable, forgives forgotten watering; 7-8: hardy, occasional neglect ok; 5-6: needs regular care; 3-4: fussy, leaves yellow at slightest change; 1-2: requires expertise; 0: beginner will kill within a month."
```

Bad:
```
"Whether the plant is easy to take care of or not."
```

## File naming

```
<category>-<topic>.score.yml
```

Category prefixes:
- `naming-` — Evaluating names (module names, brand names, project names)
- `removed — just use topic prefix` — Comparing alternatives to pick one (tech stack, library, vendor, migration)
- `pet-` — Pet selection (office, home, etc.)
- `plant-` — Plant selection (indoor, cat-safe, etc.)

Add new categories freely. The prefix helps `x score ls` group related templates.

Topic: short kebab-case English descriptor. Keep it specific: `plant-cat` is better than `plant-pet-safe`.

The first line of the file is:
```
# <prefix>-<topic>.score.yml — <English description>
```

This line is parsed by `x score ls` for the `desc` column.

## Workflow: creating a new template

```
1. Talk to user → extract 3-5 core concerns
2. Draft dimensions + factors → write the .score.yml
3. Write header comment block → list what to ask if conditions differ
4. Write inline comments → on dimensions that often change
5. Write desc for each dimension → concrete 0-10 anchors
6. Test: pick 3-5 candidates, score them, compute → does the ranking make sense?
7. Iterate: adjust factors, split/merge dimensions, tighten desc anchors
8. Save to skill0/score/template/ with proper prefix
```

## Hard filters (block column)

Some criteria are not negotiable — they are deal-breakers, not preference weights.

Use the optional `block` column in the TSV (after `target`) for this:
- `block` empty → normal candidate, ranked by total
- `block` non-empty → disqualified, pushed to bottom, rank shows `X`

The total is still computed — useful for comparing among blocked candidates ("if you absolutely had to pick one...").

When to use `block` vs a low-scoring dimension:
- "This plant is toxic to cats" → **block** (it's a binary gate, not a preference)
- "This plant is hard to care for" → **score it low** on maintenance (it's a degree, not a deal-breaker)

In template comments, document what conditions should trigger a block:
```
# 硬过滤（block 列）：
#   对猫有毒 → block = "toxic to cats"
#   需要直射光但你住地下室 → block = "needs direct sun"
```

## Anti-patterns

- **Over-fitting to one user.** If the template only works for "my south-facing Beijing apartment with two cats", it's not a template — it's a one-off score.yml.
- **Too many dimensions.** 12 dimensions = noise. Split into two templates or merge.
- **All factors = 2.** If nothing matters more than anything else, the user doesn't actually have preferences — ask more questions.
- **Vague desc.** "Good quality" is not a scoring anchor. "Zero defects in 1000-unit batch" is.
- **No comments.** A template without agent guidance is just a YAML file. Comments are what make it a *template*.
