---
name: tsv
description: |
  TSV data processing — view, filter, convert tab-separated data.
  Zero barrier — use with x-cmd, awk, or Python.
  Use for "tsv", "tab-separated", "data", "conversion".

metadata:
  version: "0.1.0"
  category: data-processing
  tags: [tsv, data, tab, conversion, awk, csv]
  repository: https://github.com/x-cmd/skill0
  type: skill0
---

# tsv — skill0

Process TSV (Tab-Separated Values) data: view, filter, convert between formats.

## Quick Start

```bash
# With x-cmd
x tsv < data.tsv                   # Display TSV data
x tsv --csv < data.tsv             # Convert to CSV
x tsv awk '{print $1, $3}' < data.tsv  # Process with AWK

# Without x-cmd — AWK handles TSV natively
awk -F'\t' '{print $1, $3}' data.tsv
# Convert TSV to CSV
awk -F'\t' -v OFS=',' '{$1=$1; print}' data.tsv
# Filter rows
awk -F'\t' '$3 > 100 {print}' data.tsv
```

## What's Available

| Command | Description |
|---------|-------------|
| `x tsv` | Display TSV data |
| `x tsv --csv` | Convert to CSV |
| `x tsv awk '{...}'` | AWK-style processing |

## Standalone Alternatives

- AWK: `awk -F'\t' '{...}'` — native TSV support
- Python: `csv` module with `delimiter='\t'`
- Miller: `mlr --tsv cat data.tsv`

## This skill0 grows

Starting with the essentials. Will add:
- Common TSV patterns
- TSV↔CSV conversion recipes
- Column manipulation tips
