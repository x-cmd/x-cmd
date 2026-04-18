# Variables expected: -v tty=
function getval(s) { i = index(s, ":"); return i > 0 ? substr(s, i + 1) : "" }
function pc(label, val,    color) {
    if (label ~ /^ssid|^bssid/) color = "1;36"
    else if (label ~ /^signal|^quality/) color = "1;32"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/[a-z]/ { iface = $1 }
/ESSID/ { p = index($0, "\""); if (p > 0) { ssid = substr($0, p + 1); q = index(ssid, "\""); if (q > 0) ssid = substr(ssid, 1, q - 1) } }
/Signal level/ { p = index($0, "Signal level"); if (p > 0) signal = substr($0, p + 13); gsub(/ .*/, "", signal) }
END {
    if (iface) pc("interface", iface)
    if (ssid) pc("SSID", ssid)
    if (signal) pc("signal", signal " dBm")
}