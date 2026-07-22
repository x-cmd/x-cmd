---
name: ccal
description: |
  China-region calendar with 调休, 农历, 节气, 生肖, 黄历吉凶、干支纪年.
  Multiple access modes: `x ccal`, direct archive download, or tsv.

metadata:
  version: "0.1.0"
  category: calendar
  tags: [calendar, lunar, chinese, solar-terms, holidays, almanac]
  repository: https://github.com/x-cmd/skill0
  type: skill0
x-meta:
  references:
  - x-cmd-mod: ccal
  - datasource: https://codeberg.org/x-cmd/ccal-data/releases/download/latest/ccal-data.tar.xz
---

# ccal — skill0

调休 — the rule that a weekend may be borrowed to make a weekday-off, or a weekday given back when a holiday falls on a weekend — is the key feature for Chinese users planning around the official work calendar.

## Quick Start with `x ccal`

```bash
# Show all date info in tsv form. TSV column as below:
# Date   LunarDate   建除   WeekDay(周几)   Jieqi(节气)   Xiuxi(三个状态:休，工，无-非调休导致的假期或工作日)   Yi（宜）  Ji（忌）  Holiday
x ccal ls 2026
# Show all date info in tsv form
x ccal ls 2026-07
# Specific date in YAML
x ccal info 2026-05-31
# Get data directory. If it is empty, try `x ccal update`
x ccal datadir
```

`x ccal -h` for more info.

Notice: the data source is https://codeberg.org/x-cmd/ccal-data/releases/download/latest/ccal-data.tar.xz

To save space, `x ccal` navigate the tar.xz using command tar without decompression. 我们鼓励这种方法，但如果需要更自由的处理，你可以按需解压。
