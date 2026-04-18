# cpuinfo.awk - Merge /proc/cpuinfo: consolidate identical fields across processors
# Input: /proc/cpuinfo format (paragraph-separated records)

BEGIN { RS = ""; FS = "\n" }

{
    nproc++
    for (i = 1; i <= NF; i++) {
        colon = index($i, ":")
        if (colon == 0) continue
        key = substr($i, 1, colon - 1)
        gsub(/^[ \t]+|[ \t]+$/, "", key)
        val = substr($i, colon + 1)
        gsub(/^[ \t]+/, "", val)
        if (key == "processor") continue
        if (!(key in seen)) {
            seen[key] = 1
            nfields++
            field_order[nfields] = key
            firstval[key] = val
        }
    }
}

END {
    printf "%-25s: %d\n", "processor count", nproc
    for (i = 1; i <= nfields; i++) {
        printf "%-25s: %s\n", field_order[i], firstval[field_order[i]]
    }
}
