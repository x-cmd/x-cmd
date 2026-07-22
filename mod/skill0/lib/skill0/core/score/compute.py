"""Score verifier.

Usage: python compute.py <standard.yml> <report.tsv>

Reads a scoring standard YAML (dimensions + factors) and a report TSV
(targets x scores), validates dimension names and target uniqueness,
calculates weighted total (0-100) and rank for each target, outputs TSV
with fixed columns (target, total, rank, reason) followed by dimension
columns annotated with weight percentages, then evidence.
"""

import csv
import re
import sys
from pathlib import Path


def _strip_quotes(s):
    """Strip surrounding double or single quotes from a string."""
    if len(s) >= 2 and s[0] == s[-1] and s[0] in ('"', "'"):
        return s[1:-1]
    return s


def parse_standard_yaml(path):
    """Parse our minimal YAML subset for score standard files.

    Only handles: title, dimensions -> name/factor/desc.
    Returns: {"dimensions": [{"name": ..., "factor": int, ...}, ...]}
    """
    text = Path(path).read_text(encoding="utf-8")
    dims = []
    cur = None
    for line in text.splitlines():
        m = re.match(r"title:\s*\"(.+)\"", line)
        if m:
            continue
        m = re.match(r'\s*-\s*name:\s*(.+)', line)
        if m:
            if cur:
                dims.append(cur)
            cur = {"name": _strip_quotes(m.group(1).strip())}
        m = re.match(r"\s*factor:\s*(\d+)", line)
        if m and cur:
            cur["factor"] = int(m.group(1))
    if cur:
        dims.append(cur)
    return {"dimensions": dims}


def main():
    if len(sys.argv) != 3:
        print("Usage: python compute.py <standard.yml> <report.tsv>", file=sys.stderr)
        sys.exit(64)

    yml_path = Path(sys.argv[1])
    tsv_path = Path(sys.argv[2])

    if not yml_path.exists():
        print(f"Standard file not found: {yml_path}", file=sys.stderr)
        sys.exit(64)
    if not tsv_path.exists():
        print(f"Report file not found: {tsv_path}", file=sys.stderr)
        sys.exit(64)

    standard = parse_standard_yaml(yml_path)
    dims = standard["dimensions"]
    if not dims:
        print("No dimensions found in standard file", file=sys.stderr)
        sys.exit(64)

    dim_names = [d["name"] for d in dims]
    factors = [d["factor"] for d in dims]
    factor_sum = sum(factors)
    if factor_sum == 0:
        print("Factors sum to zero", file=sys.stderr)
        sys.exit(64)

    # Dimension weight percentages: factor_i / factor_sum * 100
    dim_pcts = [f / factor_sum * 100 for f in factors]

    rows = []
    seen_targets = set()
    with tsv_path.open(encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t")
        if reader.fieldnames is None or reader.fieldnames[0] != "target":
            print("Report TSV must start with 'target' column", file=sys.stderr)
            sys.exit(64)

        missing_dims = [d for d in dim_names if d not in reader.fieldnames]
        if missing_dims:
            print(f"Missing dimension columns in TSV: {', '.join(missing_dims)}", file=sys.stderr)
            sys.exit(64)

        for row in reader:
            target = row.get("target", "").strip()
            if not target:
                continue
            if target in seen_targets:
                print(f"Duplicate target: {target}", file=sys.stderr)
                sys.exit(64)
            seen_targets.add(target)

            scores = []
            for d in dim_names:
                s_val = row.get(d, "").strip()
                try:
                    s = int(s_val)
                except ValueError:
                    s = 0
                scores.append(s)

            total = sum(f * s for f, s in zip(factors, scores)) / factor_sum * 10
            rows.append((target, total, scores, row))

    # Separate blocked rows (block column non-empty → push to bottom)
    # block is an optional input column; if absent, all rows pass
    blocked = [r for r in rows if r[3].get("block", "").strip()]
    passed = [r for r in rows if not r[3].get("block", "").strip()]

    passed.sort(key=lambda r: r[1], reverse=True)
    blocked.sort(key=lambda r: r[1], reverse=True)

    # Build output header: fixed columns + annotated dims + evidence
    dim_headers = [f"{name} ({pct:.0f}%)" for name, pct in zip(dim_names, dim_pcts)]
    fixed_cols = ["target", "total", "rank", "block", "reason"]

    # Remaining input columns after target (dimensions + evidence/etc, minus block/reason)
    input_fields = reader.fieldnames
    tail_cols = [c for c in input_fields[1:] if c not in dim_names and c not in ("reason", "block")]

    out_fieldnames = fixed_cols + dim_headers + tail_cols
    writer = csv.DictWriter(sys.stdout, fieldnames=out_fieldnames, delimiter="\t", lineterminator="\n")
    writer.writeheader()

    rank_idx = 0
    for target, total, scores, row in passed:
        rank_idx += 1
        out = {
            "target": target,
            "total": f"{total:.1f}",
            "rank": str(rank_idx),
            "block": "",
            "reason": row.get("reason", ""),
        }
        for name, header in zip(dim_names, dim_headers):
            out[header] = row.get(name, "")
        for col in tail_cols:
            out[col] = row.get(col, "")
        writer.writerow(out)

    for target, total, scores, row in blocked:
        out = {
            "target": target,
            "total": f"{total:.1f}",
            "rank": "X",
            "block": row.get("block", ""),
            "reason": row.get("reason", ""),
        }
        for name, header in zip(dim_names, dim_headers):
            out[header] = row.get(name, "")
        for col in tail_cols:
            out[col] = row.get(col, "")
        writer.writerow(out)


if __name__ == "__main__":
    main()
