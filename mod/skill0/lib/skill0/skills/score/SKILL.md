---
name: score
description: Weighted dimension scoring framework for AI agents — "Don't guess. Score." Core idea: understand needs first, draft then iterate, the agent is the analyst. Outputs ranked TSV via `x score compute`.
---

# Score
"Don't guess. Score."
Weighted dimension scoring framework for AI agents.
## How to use
**Understand first, score second.** Ask enough questions before defining dimensions. Wrong dimensions → wrong scores, no matter the precision.
**Draft then iterate.** When needs are not fully clear, make a best-effort standard, score, and show results. Users react to concrete rankings — "this factor should be higher", "you missed X". That's the signal. Refine and re-score. One iteration beats ten rounds of guessing.
**The agent is the analyst.** After compute, read the TSV. Explain why X beat Y. Highlight surprises. Suggest adjustments. The ranking starts the conversation, not ends it.
## Core flow
```
① Understand needs  → ② Define score.yml  → ③ Score score.tsv  → ④ x score compute  → ⑤ Report & iterate
```
Output: `target, total, rank, block, reason, <dim> (X%), evidence`. Total 0–100, sorted descending. rank=1 best.
## Example — helping a user decide on promotional slogans
1. Discuss with the user to define evaluation dimensions and criteria. Write `slogan.score.yml`.
2. AI scores each slogan per dimension (0–10, with evidence) → `slogan.score.tsv`. Leave total and rank blank.
3. `x score compute slogan.score.yml slogan.score.tsv` → fills total + rank.
4. Read results, discuss with user. Adjust scores or add candidates, repeat.
5. Or: `x score iter -f slogan.score.yml slogan.score.tsv "<feedback>"`
More examples: [EXAMPLE.md](EXAMPLE.md).
## Two-file model
| File | Role |
|------|------|
| `*.score.yml` | Reusable standard: dimensions, factors, descriptions |
| `**.score.tsv` | Targets + scores + evidence; column 1 = target name |
`x score compute <yml> <tsv>` same as `python compute.py`.
## Application scenarios
1. **Gives agents a decision workflow.** score.yml anchors the agent to a structured process — the agent follows the standard, not the mood of the last message.
2. **Decisions are rule-based.** Dimensions × factors × evidence → weighted total → rank. Every score is anchored to facts. Reasoning is transparent.
3. **Tunes to different needs.** Swap dimensions, adjust factors, add hard filters (`block` column). Same template, different users.
4. **Evolves as needs clarify.** Draft → score → feedback → refine → sharper.
5. **Standard file + archived results for any skill.** score.yml = decision standard. score.tsv = decision record. Both archivable, reviewable, shareable.
---
## Formula
```
total = Σ(factor × score) ÷ Σ(factor) × 10   →   0–100
```
- **factor** — integer 1–10. Baseline = 2. 1=minor, 4=2×, 6=3×, 8=4×, 10=5×. Auto-normalized.
- **score** — 0–10 per dimension, evidence-anchored.
- **total** — weighted total 0–100.
Dimension headers show weight %: `factor ÷ Σ(factor) × 100`.
## Output columns
| Column | Source | Description |
|--------|--------|-------------|
| `target` | input | Candidate name |
| `total` | computed | Weighted score (0–100) |
| `rank` | computed | 1 = best. `X` if blocked |
| `block` | input | Hard filter — non-empty = disqualified, pushed to bottom, rank=X |
| `reason` | input/output | Optional: AI notes on score nuances |
| `<dim> (X%)` | computed | Scores per dimension, header shows weight % |
| `evidence` | input | Facts backing each score |
## Scale
| Score | Meaning |
|-------|---------|
| 9–10 | Excellent — fully meets criteria |
| 7–8 | Good — meets criteria, minor gap |
| 5–6 | Adequate — direction right, notable miss |
| 3–4 | Weak — significant gap |
| 1–2 | Fail — barely addressed |
| 0 | N/A — not applicable |
## Rules
1. **Evidence anchoring** — every score MUST have evidence. Facts, not feelings.
2. **Use the full range** — 5 is midpoint, not default. 0 and 10 are rare but possible.
3. **Factors are relative amplifiers** — factor 2 = 2× influence of factor 1. Auto-normalized.
4. **Targets unique and non-empty** — column 1 every row must have a target name. No duplicates, no blanks.
5. **Agent reads, reports, decides** — after compute, explain results. Re-score or re-weight as needed.
## Files
| File | Purpose |
|------|---------|
| `SKILL.cn.md` | Chinese version |
| `compute.py` | Validates + computes total + rank |
| `template/*.score.yml` | 35+ templates. `x score ls` lists, `x score init -t <name>` copies |
| `EXAMPLE.md` | More usage examples |
| `rule-vs-score.md` | When to use rule vs score |
| `score-template-writer.md` | How to write scoring templates |
