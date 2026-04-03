---
name: ccal
description: Chinese Calendar with Lunar-Solar Conversion
---

## Data

### Location

```
$___X_CMD_ROOT_DATA/ccal/data/
├── ccal-data-v0.0.6.tar.xz      # Main archive (stream-read, not extracted)
└── v0.0.6/cache/                # Pre-extracted index (after first run)
    ├── year.tsv                  # Year index
    └── month.tsv                 # Month index
```

### Download

- **URL**: https://codeberg.org/x-cmd/ccal-data/releases/download/v0.0.6/ccal-data.tar.xz
- **Trigger**: First run or `x ccal lunar update`

## Archive Contents

```
ccal-data/
├── index/
│   ├── year.tsv      # Year index
│   └── month.tsv     # Month index
└── lunar/
    └── {year}_{month}.tsv   # Monthly data (e.g., 2026_03.tsv)
```

## Direct Read (No Extraction)

Use `x zuz cat <archive> <path>` to stream-read from archive:

```bash
DATA="$___X_CMD_ROOT_DATA/ccal/data/ccal-data-v0.0.6.tar.xz"

# Read year index
x zuz cat "$DATA" ccal-data/index/year.tsv

# Read month index
x zuz cat "$DATA" ccal-data/index/month.tsv

# Read specific month: 2026 March
x zuz cat "$DATA" ccal-data/lunar/2026_03.tsv

# Read all months of 2026
x zuz cat "$DATA" ccal-data/lunar/2026_*.tsv
```

## Cached Read (After First Run)

```bash
CACHE="$___X_CMD_ROOT_DATA/ccal/data/v0.0.6/cache"

# Use cached index if available
[ -f "$CACHE/year.tsv" ] && cat "$CACHE/year.tsv"
```

## Reference

- `lib/awk/lunar.awk` - Lunar calendar computation
- `lib/awk/gongli.awk` - Gregorian calendar computation
- `lib/awk/ccal.awk` - Main calendar logic
