# variables: tty
function fmtbytes(b) {
    if (b >= 1073741824) return sprintf("%.0f GB", b / 1073741824)
    if (b >= 1048576) return sprintf("%.0f MB", b / 1048576)
    if (b >= 1024) return sprintf("%.0f KB", b / 1024)
    return b " B"
}
function pc(label, val,    color) {
    if (label ~ /utilization$/) color = "1;32"
    else if (label ~ /^memory/) color = "1;33"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/"PerformanceStatistics"/ {
    gsub(/.*"PerformanceStatistics" = /, "")
    gsub(/.$/, "")
    n = split($0, pairs, ",")
    for (i = 1; i <= n; i++) {
        colon = index(pairs[i], "=")
        if (colon == 0) continue
        key = substr(pairs[i], 1, colon - 1)
        val = substr(pairs[i], colon + 1)
        gsub(/"/, "", key)
        gsub(/^[ \t]+/, "", key)
        if (key == "Device Utilization %")
            pc("gpu utilization", val "%")
        if (key == "Renderer Utilization %")
            pc("renderer utilization", val "%")
        if (key == "Tiler Utilization %")
            pc("tiler utilization", val "%")
    }
    # Memory (separate loop to group after utilization)
    for (i = 1; i <= n; i++) {
        colon = index(pairs[i], "=")
        if (colon == 0) continue
        key = substr(pairs[i], 1, colon - 1)
        val = substr(pairs[i], colon + 1)
        gsub(/"/, "", key)
        gsub(/^[ \t]+/, "", key)
        if (key == "In use system memory")
            pc("memory in use", fmtbytes(val + 0))
    }
}