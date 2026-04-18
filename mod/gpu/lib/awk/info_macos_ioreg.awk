# variables: tty
function fmtbytes(b) {
    if (b >= 1073741824) return sprintf("%.0f GB", b / 1073741824)
    if (b >= 1048576) return sprintf("%.0f MB", b / 1048576)
    if (b >= 1024) return sprintf("%.0f KB", b / 1024)
    return b " B"
}
function pc(label, val,    color) {
    if (label ~ /^metal plugin|^memory allocated/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/MetalPluginName/ && !metalplug {
    split($0, a, "\""); if (a[4]) pc("metal plugin", a[4]); metalplug = 1
}
/"Alloc system memory"/ && !gpumem {
    gsub(/.*"Alloc system memory"=/, "", $0)
    gsub(/[^0-9].*/, "", $0)
    if ($0 + 0 > 0) { pc("memory allocated", fmtbytes($0 + 0)); gpumem = 1 }
}