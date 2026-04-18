# Variables expected: -v tty=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function signal_bar(rssi) {
    if (rssi + 0 >= -50) return "||||"
    if (rssi + 0 >= -60) return "|||"
    if (rssi + 0 >= -70) return "||"
    return "|"
}
function signal_color(rssi) {
    if (rssi + 0 >= -50) return "1;32"
    if (rssi + 0 >= -60) return "1;36"
    if (rssi + 0 >= -70) return "1;33"
    return "1;31"
}
/BSS/ { if (ssid) flush_entry(); ssid=""; signal=""; channel=""; security=""; freq="" }
/SSID:/ { ssid = getval($0) }
/signal:/ { signal = $2 }
/freq:/ { freq = $2 }
/WPA/ || /RSN/ { security = $0; gsub(/^[ \t]+/, "", security) }
/DS Parameter set/ { channel = $NF }
END { if (ssid) flush_entry(); print_entries() }

function flush_entry() {
    n = ++net_n
    nets_ssid[n] = ssid
    nets_signal[n] = signal
    nets_channel[n] = channel
    nets_freq[n] = freq
    nets_security[n] = security
}
function print_entries(    i, bar, sc) {
    if (net_n == 0) return
    if (tty) printf "\033[1;33m%-24s %-6s %-10s %s\033[0m\n", "SSID", "CH", "FREQ", "SIGNAL"
    else printf "%-24s %-6s %-10s %s\n", "SSID", "CH", "FREQ", "SIGNAL"
    for (i = 1; i <= net_n; i++) {
        bar = signal_bar(nets_signal[i])
        if (tty) {
            sc = signal_color(nets_signal[i])
            printf "\033[1;36m%-24s\033[0m %-6s %-10s \033[%sm%s (%s dBm)\033[0m\n", \
                nets_ssid[i], nets_channel[i], nets_freq[i], sc, bar, nets_signal[i]
        } else {
            printf "%-24s %-6s %-10s %s (%s dBm)\n", \
                nets_ssid[i], nets_channel[i], nets_freq[i], bar, nets_signal[i]
        }
    }
}