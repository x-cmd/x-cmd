# Variables expected: -v tty=
# Parses `ip link` output for network interfaces

function print_net_header() {
    if (tty) printf "\033[1;33m%-12s %-11s %-18s %s\033[0m\n", "INTERFACE", "TYPE", "MAC", "STATUS"
    else printf "%-12s %-11s %-18s %s\n", "INTERFACE", "TYPE", "MAC", "STATUS"
}

function print_net_row(iface, ntype, mac, status) {
    if (tty) {
        printf "\033[1;36m%-12s\033[0m \033[1;35m%-11s\033[0m %-18s %s\n", iface, ntype, mac, status
    } else {
        printf "%-12s %-11s %-18s %s\n", iface, ntype, mac, status
    }
}

BEGIN {
    print_net_header()
}

/^[0-9]+:/ {
    # extract interface name
    iface = $2
    gsub(/:$/, "", iface)
    # skip lo
    if (iface == "lo") next
    ntype = "Ethernet"
    mac = ""
    status = "Down"
}

/link\/ether/ && iface != "" {
    mac = $2
}

/state UP/ && iface != "" {
    status = "Connected"
}

/state DOWN/ && iface != "" {
    status = "Inactive"
}

/^$/ && iface != "" {
    # determine type from name
    if (iface ~ /^wl/ || iface ~ /^wlan/) ntype = "Wi-Fi"
    print_net_row(iface, ntype, mac, status)
    iface = ""
}

END {
    if (iface != "") {
        if (iface ~ /^wl/ || iface ~ /^wlan/) ntype = "Wi-Fi"
        print_net_row(iface, ntype, mac, status)
    }
}
