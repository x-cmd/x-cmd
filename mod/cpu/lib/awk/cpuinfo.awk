# cpuinfo.awk - Merge /proc/cpuinfo: consolidate identical fields across processors
# Input: /proc/cpuinfo format (paragraph-separated records)

function C(c, s) { return tty ? "\033[" c "m" s "\033[0m" : s }
function pc(label, val,    color) {
    if (label ~ /^(processor|physical id|siblings|core id|model name|vendor|cpu family|model|stepping|apicid|initial apicid|microcode)/) color = "1;36"
    else if (label ~ /cache size|clflush size|L[123] |cache line/) color = "1;33"
    else if (label ~ /cpu MHz|bogomips|frequency|^bus freq/) color = "1;35"
    else if (label ~ /^(page size|memory$)/) color = "1;32"
    else if (label ~ /cpu cores$|cores:/) color = "1;34"
    else if (label ~ /^(flags|fpu|fpu_exception|cpuid level|wp|address sizes|power management)/) color = "37"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

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
    pc("processor count", nproc)
    for (i = 1; i <= nfields; i++) {
        pc(field_order[i], firstval[field_order[i]])
    }
}
