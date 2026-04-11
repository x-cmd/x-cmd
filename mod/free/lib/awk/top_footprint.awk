# shellcheck shell=awk
# top_footprint.awk - macOS footprint CLI integration for --precise mode
# Loaded after top.awk via: -f top.awk -f top_footprint.awk
#
# Provides: get_group_footprint(), parse_footprint_value()
# Activated by: use_fp=1 (from --precise flag)
#
# When --precise is active, AWK calls footprint CLI per multi-process group
# in END block to get accurate cross-process deduped Summary Footprint.

# Call footprint for a group of PIDs, return Summary Footprint in KB
function get_group_footprint(pids_str,    cmd, line, fp_kb, safe_pids) {
    safe_pids = pids_str
    gsub(/\|/, " ", safe_pids)
    # Safety: only digits and spaces
    if (safe_pids !~ /^[0-9 ]+$/) return 0

    cmd = "footprint --noCategories " safe_pids " 2>/dev/null"
    fp_kb = 0
    while ((cmd | getline line) > 0) {
        if (line ~ /^Summary Footprint: /) {
            fp_kb = parse_footprint_value(line)
        }
    }
    close(cmd)
    return fp_kb
}

# Parse "Summary Footprint: N MB" or "N KB" or "N GB" → KB
function parse_footprint_value(line,    val, unit) {
    val = line
    sub(/^Summary Footprint: /, "", val)
    unit = val
    sub(/^[0-9]+(\.[0-9]+)? /, "", unit)
    sub(/ .*/, "", unit)
    val = val + 0
    if (unit == "GB") return int(val * 1048576)
    if (unit == "MB") return int(val * 1024)
    return int(val)
}
