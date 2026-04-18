# Variables expected: -v tty=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function signal_quality(rssi,    q) {
    q = (rssi + 90) * 100 / 60
    if (q > 100) q = 100
    if (q < 0) q = 0
    return sprintf("%.0f%%", q)
}
function pc(label, val,    color) {
    if (label ~ /^ssid|^bssid/) color = "1;36"
    else if (label ~ /^channel|^frequency/) color = "1;34"
    else if (label ~ /^signal|^noise|^snr|^quality/) color = "1;32"
    else if (label ~ /^rate|^mcs|^security/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/Connected to/ { bssid = $3; gsub(/ .*/, "", bssid) }
/SSID:/ { ssid = getval($0) }
/freq:/ { freq = getval($0) }
/signal:/ { signal = getval($0); gsub(/ dBm.*/, "", signal) }
/tx bitrate:/ { txrate = getval($0) }
/RX bitrate:/ { rxrate = getval($0) }
/auth/ { security = getval($0) }
END {
    if (ssid) {
        pc("SSID", ssid)
        if (bssid) pc("BSSID", bssid)
        if (freq) pc("frequency", freq " MHz")
        if (signal) {
            pc("signal", signal " dBm")
            pc("signal quality", signal_quality(signal + 0))
        }
        if (txrate) pc("tx bitrate", txrate)
        if (rxrate) pc("rx bitrate", rxrate)
        if (security) pc("security", security)
    } else {
        pc("status", "Not connected")
    }
}