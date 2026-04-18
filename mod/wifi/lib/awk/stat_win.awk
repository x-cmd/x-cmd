# Variables expected: -v tty=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function pc(label, val,    color) {
    if (label ~ /^ssid|^bssid/) color = "1;36"
    else if (label ~ /^channel|^band/) color = "1;34"
    else if (label ~ /^signal|^quality/) color = "1;32"
    else if (label ~ /^rate|^security/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/^[ \t]*SSID/ && !ssid { ssid = getval($0) }
/^[ \t]*BSSID/ { bssid = getval($0) }
/^[ \t]*Channel/ { channel = getval($0) }
/^[ \t]*Signal/ { signal = getval($0) }
/^[ \t]*Radio type/ { radio = getval($0) }
/^[ \t]*Authentication/ { auth = getval($0) }
/^[ \t]*Receive rate/ { rxrate = getval($0) }
/^[ \t]*Transmit rate/ { txrate = getval($0) }
/^[ \t]*State/ { state = getval($0) }
END {
    if (ssid) {
        pc("SSID", ssid)
        pc("state", state)
        if (bssid) pc("BSSID", bssid)
        if (channel) pc("channel", channel)
        if (signal) pc("signal", signal)
        if (radio) pc("radio type", radio)
        if (auth) pc("authentication", auth)
        if (rxrate) pc("receive rate", rxrate)
        if (txrate) pc("transmit rate", txrate)
    } else {
        pc("state", state)
    }
}