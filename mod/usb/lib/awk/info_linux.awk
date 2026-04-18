# Expected variables: -v tty=""

function pc(label, val,    color) {
    if (label ~ /^device|^vendor|^product/) color = "1;36"
    else if (label ~ /^serial|^bus/) color = "1;34"
    else if (label ~ /^speed|^class/) color = "1;32"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
{
    # lsusb output: Bus 001 Device 002: ID 1234:5678 Vendor Product
    bus = ""; dev = ""; id = ""; desc = ""
    for (i = 1; i <= NF; i++) {
        if ($i == "Bus") bus = $(i+1)
        if ($i == "Device") dev = $(i+1)
        if ($i == "ID") { id = $(i+1); desc = ""; for (j = i+2; j <= NF; j++) { if (desc != "") desc = desc " "; desc = desc $j } break }
    }
    if (bus == "") next
    if (printed_any > 0) printf "\n"
    printed_any = 1
    pc("bus", bus)
    pc("device", dev)
    pc("ID", id)
    if (length(desc) > 0) pc("description", desc)
}