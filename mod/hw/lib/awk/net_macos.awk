# Variables expected: -v mode=sum -v tty=
# Parses system_profiler SPNetworkDataType
# Buffers rows, prints Wi-Fi first then others

function getval(s,    p) {
    p = index(s, ": ")
    if (p > 0) return substr(s, p + 2)
    return ""
}
function add_net(iface, ntype, mac, status) {
    nn++
    ni[nn] = iface; nt[nn] = ntype; nm[nn] = mac; ns[nn] = status
}
function print_net_row(iface, ntype, mac, status) {
    if (tty) {
        printf "\033[1;36m%-12s\033[0m \033[1;35m%-11s\033[0m %-18s %s\n", iface, ntype, mac, status
    } else {
        printf "%-12s %-11s %-18s %s\n", iface, ntype, mac, status
    }
}

# Section start: indented device name ending with :
/^    [A-Za-z]/ && /:$/ {
    # flush previous
    if (net_iface != "") {
        if (net_ipv4 != "") net_status = "Connected"
        else if (net_mac != "") net_status = "Inactive"
        else net_status = "Unavailable"
        add_net(net_iface, net_type, net_mac, net_status)
    }
    net_iface = ""; net_type = ""; net_mac = ""; net_ipv4 = ""
    next
}

/BSD Device Name:/ { net_iface = getval($0) }
/Type: AirPort/     { net_type = "Wi-Fi" }
/Type: Ethernet/    { net_type = "Ethernet" }
/MAC Address:/ && !net_mac { net_mac = getval($0) }
/IPv4 Addresses:/   { net_ipv4 = getval($0) }

END {
    # flush last
    if (net_iface != "") {
        if (net_ipv4 != "") net_status = "Connected"
        else if (net_mac != "") net_status = "Inactive"
        else net_status = "Unavailable"
        add_net(net_iface, net_type, net_mac, net_status)
    }

    # Header
    if (tty) printf "\033[1;33m%-12s %-11s %-18s %s\033[0m\n", "INTERFACE", "TYPE", "MAC", "STATUS"
    else printf "%-12s %-11s %-18s %s\n", "INTERFACE", "TYPE", "MAC", "STATUS"

    # Wi-Fi first
    for (i = 1; i <= nn; i++) {
        if (nt[i] == "Wi-Fi") print_net_row(ni[i], nt[i], nm[i], ns[i])
    }
    # Then others (Connected first, then Inactive, then Unavailable)
    for (i = 1; i <= nn; i++) {
        if (nt[i] != "Wi-Fi" && ns[i] == "Connected") print_net_row(ni[i], nt[i], nm[i], ns[i])
    }
    for (i = 1; i <= nn; i++) {
        if (nt[i] != "Wi-Fi" && ns[i] == "Inactive") print_net_row(ni[i], nt[i], nm[i], ns[i])
    }
    for (i = 1; i <= nn; i++) {
        if (nt[i] != "Wi-Fi" && ns[i] == "Unavailable") print_net_row(ni[i], nt[i], nm[i], ns[i])
    }
}
