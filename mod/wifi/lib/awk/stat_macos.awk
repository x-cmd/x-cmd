# Variables expected: -v tty=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function signal_color(rssi) {
    if (rssi == "") return "0"
    if (rssi + 0 >= -50) return "1;32"
    if (rssi + 0 >= -60) return "1;36"
    if (rssi + 0 >= -70) return "1;33"
    return "1;31"
}
function flush_net() {
    if (cur_ssid == "") return
    n = ++net_n
    nets_ssid[n] = cur_ssid
    nets_phy[n] = cur_phy
    nets_channel[n] = cur_channel
    nets_security[n] = cur_security
    nets_signal[n] = cur_signal
    nets_noise[n] = cur_noise
    nets_txrate[n] = cur_txrate
    nets_mcs[n] = cur_mcs
    nets_country[n] = cur_country
    nets_type[n] = cur_type
    nets_cur[n] = cur_is_current
}
function reset_cur() {
    cur_ssid = ""; cur_phy = ""; cur_channel = ""; cur_security = ""
    cur_signal = ""; cur_noise = ""; cur_txrate = ""; cur_mcs = ""
    cur_country = ""; cur_type = ""; cur_is_current = 0
}
/^      Interfaces:/ { in_iface = 1; next }
in_iface && /^        [a-z]/ && index($0, ":") > 0 && !iface {
    p = index($0, ":")
    iface = substr($0, 1, p - 1); gsub(/^[ \t]+/, "", iface)
}
/Card Type:/ { card_type = getval($0) }
/Status:/ { status = getval($0) }
/Current Network Information:/ { in_current = 1; next }
/Other Local Wi-Fi Networks:/ { flush_net(); reset_cur(); in_current = 0; in_scan = 1; next }
# awdl0 or any second interface block: stop collecting
in_current && /^        [a-z]/ && index($0, ":") > 0 { flush_net(); in_current = 0; next }
in_scan && /^        [a-z]/ && index($0, ":") > 0 { flush_net(); in_scan = 0; next }
in_current && /:$/ && NF == 1 && cur_ssid == "" {
    p = index($0, ":")
    if (p > 0) { cur_ssid = substr($0, 1, p - 1); gsub(/^[ \t]+/, "", cur_ssid) }
    cur_is_current = 1
}
in_scan && /:$/ && NF == 1 {
    flush_net(); reset_cur()
    cur_ssid = $0; gsub(/:$/, "", cur_ssid); gsub(/^[ \t]+/, "", cur_ssid)
    next
}
(in_current || in_scan) && /PHY Mode:/ { cur_phy = getval($0) }
(in_current || in_scan) && /Channel:/ { cur_channel = getval($0) }
(in_current || in_scan) && /Security:/ { cur_security = getval($0) }
(in_current || in_scan) && /Network Type:/ { cur_type = getval($0) }
(in_current || in_scan) && /Signal \/ Noise:/ {
    sn = getval($0)
    p = index(sn, " / ")
    if (p > 0) {
        cur_signal = substr(sn, 1, p - 1); gsub(/ dBm/, "", cur_signal)
        cur_noise = substr(sn, p + 3); gsub(/ dBm/, "", cur_noise)
    }
}
in_current && /Transmit Rate:/ { cur_txrate = getval($0) }
in_current && /MCS Index:/ { cur_mcs = getval($0) }
in_current && /Country Code:/ { cur_country = getval($0) }
END {
    flush_net()

    # Header bar: -- en0 | Wi-Fi ... | Connected
    if (iface == "") iface = "en0"
    if (tty) printf "\033[1;37m-- %s | %s | %s\033[0m\n", iface, card_type, status
    else printf "-- %s | %s | %s\n", iface, card_type, status

    # Table header
    if (tty) printf "\033[1;33m%-20s %-18s %-20s %-20s %-4s %-10s %s\033[0m\n", "SSID", "PHY", "CHANNEL", "SECURITY", "CUR", "RATE", "SIGNAL"
    else printf "%-20s %-18s %-20s %-20s %-4s %-10s %s\n", "SSID", "PHY", "CHANNEL", "SECURITY", "CUR", "RATE", "SIGNAL"

    for (i = 1; i <= net_n; i++) {
        cur_mark = (nets_cur[i] == 1) ? "*" : ""
        rate_str = (nets_txrate[i] != "") ? nets_txrate[i] " Mbps" : ""
        sig_str = (nets_signal[i] != "") ? nets_signal[i] " dBm" : ""
        if (tty) {
            sc = signal_color(nets_signal[i])
            printf "\033[1;36m%-20s\033[0m %-18s \033[1;34m%-20s\033[0m \033[1;35m%-20s\033[0m \033[1;32m%-4s\033[0m %-10s \033[%sm%s\033[0m\n", \
                nets_ssid[i], nets_phy[i], nets_channel[i], nets_security[i], cur_mark, rate_str, sc, sig_str
        } else {
            printf "%-20s %-18s %-20s %-20s %-4s %-10s %s\n", \
                nets_ssid[i], nets_phy[i], nets_channel[i], nets_security[i], cur_mark, rate_str, sig_str
        }
    }
}