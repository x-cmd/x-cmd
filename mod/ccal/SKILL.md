---
name: ccal
description: Chinese Calendar with Lunar-Solar Conversion
---

## Overview

ccal is a Chinese calendar module that provides:
- Gregorian and lunar calendar conversion
- Solar terms (节气)
- Traditional Chinese holidays
- Almanac guidance (黄历宜忌)
- Heavenly Stems and Earthly Branches (干支)
- Six-day cycle (六曜)
- Duty star (值星)

## AI Agent Usage

### Output Modes

| Mode | Command | Use Case |
|------|---------|----------|
| **YML** (default in pipe) | `x ccal info <date>` | AI parsing, structured key-value output |
| **TSV** | `x ccal info --tsv <date>` | Piping to other tools, tab-separated |
| **CSV** | `x ccal info --csv <date>` | Spreadsheet import |
| **TTY** (default in terminal) | `x ccal info --tty <date>` | Human viewing, colorful calendar draw |

### Auto-Detection

When output is not a TTY (piped to another process):
- Automatically outputs YML format
- Same as calling `x ccal info --yml <date>`

When output is a TTY (interactive terminal):
- Uses `x ccal draw` to render colorful calendar
- Same as calling `x ccal info --tty <date>`

### Basic Examples

```bash
# AI: Get today's date info (auto-detects pipe vs terminal)
x ccal info

# AI: Get specific date in YML format
x ccal info --yml 2025-05-09

# AI: Parse YML output with your favorite tool
x ccal info --yml 2025-05-09 | grep "jianchu"

# TSV format (tab-separated)
x ccal info --tsv 2025-05-09

# CSV format (comma-separated)
x ccal info --csv 2025-05-09

# Force TTY mode even in pipe
x ccal info --tty 2025-05-09
```

### YML Output Format

```yaml
date: 2025-05-09
lunar_date: 2025-4-12
lunar_daycount: 29
jianchu: 收
weekday: 五
bazi: 乙巳 辛巳 戊寅
jieqi: 无
jieqi_next: 小满 (5, 21)
holiday: 无
xiuxi: 无
related: 无
yi: 结网 解除 馀事勿取
ji: 诸事不宜
```

### YML Field Descriptions

| Field | Description | Example |
|-------|-------------|---------|
| date | Gregorian date (YYYY-MM-DD) | 2025-05-09 |
| lunar_date | Lunar date (YYYY-M-D) | 2025-4-12 |
| lunar_daycount | Days in lunar month (29/30) | 29 |
| **jianchu** | **值星** (auspicious/inauspicious star) | 收/满/定/执... |
| weekday | Day of week (一-日) | 五 |
| bazi | Year/Month/Day Heavenly Stems | 乙巳 辛巳 戊寅 |
| **jieqi** | Solar term | 立夏/清明/无 |
| jieqi_next | Next solar term with date | 小满 (5, 21) |
| holiday | Holiday name | 劳动节/无 |
| xiuxi | 休(holiday)/工(workday)/空 | 休 |
| related | Holiday adjustment info | 劳动节 2025-05-01 |
| **yi** | **宜** (auspicious activities) | 出行 嫁娶 安葬... |
| **ji** | **忌** (inauspicious activities) | 动土 破土 祈福... |

### Key Fields for AI

**值星 (jianchu)** - Duty star for the day:
- 吉: 满/平/定/执 (auspicious)
- 凶: 收/破 (inauspicious)

**宜 (yi)** - Auspicious activities for the day
**忌 (ji)** - Inauspicious activities for the day

**六曜 (liuyao)** - Six-day cycle:
- 大安 ( auspicious)
- 赤口 (inauspicious)
- 先胜/友引/先负/佛灭

## Data Format (TSV)

The raw TSV data has 13 columns:

```
date    lunar_date  daycount  jianchu  wd  bazi         jieqi  jieqi_next  holiday  xiuxi  related    yi               ji
2025-05-09  2025-4-12  29       收       五   乙巳 辛巳 戊寅  无    小满 (5, 21)  无     无    无       结网 解除 馀事勿取  诸事不宜
```

## Data Source

### Archive Location

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

### Archive Contents

```
ccal-data/
├── index/
│   ├── year.tsv      # Year index
│   └── month.tsv     # Month index
└── lunar/
    └── {year}_{month}.tsv   # Monthly data (e.g., 2026_03.tsv)
```

### Direct Read (No Extraction)

```bash
DATA="$___X_CMD_ROOT_DATA/ccal/data/ccal-data-v0.0.6.tar.xz"

# Read specific month: 2026 March
x zuz cat "$DATA" ccal-data/lunar/2026_03.tsv

# Read all months of 2026
x zuz cat "$DATA" ccal-data/lunar/2026_*.tsv
```

## Reference

- `lib/awk/lunar.awk` - Lunar calendar computation
- `lib/awk/gongli.awk` - Gregorian calendar computation
- `lib/awk/ccal.awk` - Main calendar logic
