# Variables expected: -v simple= -v tty=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function pc(label, val,    color) {
    if (label ~ /^interface|^card type|^mac address|^bsd/) color = "1;36"
    else if (label ~ /^firmware|^software|^driver/) color = "1;34"
    else if (label ~ /^supported|^phy mode|^channel/) color = "1;32"
    else if (label ~ /^country|^locale|^wake|^airdrop|^auto/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/^      Interfaces:/ { in_iface = 1; next }
in_iface && /^        [a-z]/ && !iface {
    p = index($0, ":")
    if (p > 0) { iface = substr($0, 1, p - 1); gsub(/^[ \t]+/, "", iface) }
}
in_iface && /Card Type:/ { card = getval($0) }
in_iface && /Firmware Version:/ { fw = getval($0); if (index(fw, "version") > 0) { p = index(fw, "version"); fw = substr(fw, p) } }
in_iface && /MAC Address:/ && !mac { mac = getval($0) }
in_iface && /Locale:/ { locale = getval($0) }
in_iface && /Country Code:/ && !country { country = getval($0) }
in_iface && /Supported PHY Modes:/ { phy = getval($0) }
in_iface && /Wake On Wireless:/ { wow = getval($0) }
in_iface && /AirDrop:/ { airdrop = getval($0) }
in_iface && /Auto Unlock:/ { autounlock = getval($0) }
in_iface && /Status:/ { status = getval($0) }
END {
    if (!iface) exit 1
    pc("interface", iface)
    if (card)      pc("card type", card)
    if (mac)       pc("MAC address", mac)
    pc("status", status)
    if (!simple) {
        if (fw)        pc("firmware", fw)
        if (locale)    pc("locale", locale)
        if (country)   pc("country code", country)
        if (phy)       pc("supported PHY modes", phy)
        if (wow)       pc("wake on wireless", wow)
        if (airdrop)   pc("AirDrop", airdrop)
        if (autounlock) pc("auto unlock", autounlock)
    }
}