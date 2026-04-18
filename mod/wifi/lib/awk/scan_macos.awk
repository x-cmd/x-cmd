# Variables expected: -v tty= -v preferfile=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function signal_color(rssi) {
    if (rssi == "") return "0"
    if (rssi + 0 >= -50) return "1;32"
    if (rssi + 0 >= -60) return "1;36"
    if (rssi + 0 >= -70) return "1;33"
    return "1;31"
}
function load_prefer(    cmd, line) {
    cmd = "cat " preferfile " 2>/dev/null"
    while ((cmd | getline line) > 0) {
        gsub(/^[ \t]+/, "", line)
        gsub(/[ \t]+$/, "", line)
        if (length(line) > 0) prefer[line] = 1
    }
    close(cmd)
}
function flush_entry() {
    if (prev_ssid == "") return
    n = ++net_n
    nets_ssid[n] = prev_ssid
    nets_phy[n] = phy
    nets_channel[n] = channel
    nets_security[n] = security
    nets_signal[n] = signal
}

BEGIN { load_prefer() }

/Other Local Wi-Fi Networks:/ { if (scan_done) next; in_scan = 1; next }
in_scan && /^        [a-z0-9]+:/ && !/Other Local Wi-Fi Networks:/ { in_scan = 0; scan_done = 1; flush_entry(); next }

in_scan && /:$/ && NF == 1 {
    flush_entry()
    prev_ssid = $0
    gsub(/:$/, "", prev_ssid)
    gsub(/^[ \t]+/, "", prev_ssid)
    phy = ""; channel = ""; security = ""; signal = ""
    next
}
in_scan && /PHY Mode:/ { phy = getval($0) }
in_scan && /Channel:/ { channel = getval($0) }
in_scan && /Security:/ { security = getval($0) }
in_scan && /Signal \/ Noise:/ {
    sn = getval($0)
    p = index(sn, " / ")
    if (p > 0) { signal = substr(sn, 1, p - 1); gsub(/ dBm/, "", signal) }
}

END {
    flush_entry()
    if (preferfile != "") system("rm -f " preferfile)
    if (net_n == 0) exit 0

    # Table header
    if (tty) printf "\033[1;33m%-24s %-10s %-18s %-20s %-5s %s\033[0m\n", "SSID", "PHY", "CHANNEL", "SECURITY", "SAVED", "SIGNAL"
    else printf "%-24s %-10s %-18s %-20s %-5s %s\n", "SSID", "PHY", "CHANNEL", "SECURITY", "SAVED", "SIGNAL"

    for (i = 1; i <= net_n; i++) {
        sig = nets_signal[i]
        saved = (nets_ssid[i] in prefer) ? "*" : ""
        sig_str = (sig != "") ? sig " dBm" : ""
        if (tty) {
            sc = signal_color(sig)
            saved_c = (saved == "*") ? "1;32" : "0;90"
            printf "\033[1;36m%-24s\033[0m %-10s \033[1;34m%-18s\033[0m \033[1;35m%-20s\033[0m \033[%sm%-5s\033[0m \033[%sm%s\033[0m\n", \
                nets_ssid[i], nets_phy[i], nets_channel[i], nets_security[i], saved_c, saved, sc, sig_str
        } else {
            printf "%-24s %-10s %-18s %-20s %-5s %s\n", \
                nets_ssid[i], nets_phy[i], nets_channel[i], nets_security[i], saved, sig_str
        }
    }

    # Hint for connecting
    if (tty) printf "\n\033[0;90m* = saved network. Connect with: x wifi connect <SSID> [password]\033[0m\n"
    else printf "\n* = saved network. Connect with: x wifi connect <SSID> [password]\n"
}