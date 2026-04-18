# Expected variables: -v tty=""

function getstr(s,    p, t, q) {
    p = index(s, "= \"")
    if (p < 1) return ""
    t = substr(s, p + 3)
    q = index(t, "\"")
    if (q < 1) return ""
    return substr(t, 1, q - 1)
}
function gethex(s,    p, t) {
    p = index(s, "= 0x")
    if (p < 1) return ""
    t = substr(s, p + 2)
    sub(/,.*/, "", t)
    return t
}
function getnum(s,    p, t) {
    p = index(s, "= ")
    if (p < 1) return ""
    t = substr(s, p + 2)
    sub(/,.*/, "", t)
    return t + 0
}
function speed_str(code) {
    if (code == 1) return "Full Speed (12 Mbps)"
    if (code == 2) return "High Speed (480 Mbps)"
    if (code == 3) return "Super Speed (5 Gbps)"
    if (code == 4) return "Super Speed+ (10 Gbps)"
    if (code > 0) return "Speed " code
    return ""
}
function pc(label, val,    color) {
    if (label ~ /^device|^product|^vendor|^name/) color = "1;36"
    else if (label ~ /^serial|^location|^address/) color = "1;34"
    else if (label ~ /^speed|^class|^protocol|^power/) color = "1;32"
    else if (label ~ /^product id|^vendor id|^release|^version/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

function flush_dev(    spd) {
    if (length(dev_name) == 0) return

    if (printed_any > 0) printf "\n"
    printed_any = 1

    pc("device", dev_name)
    if (length(vendor_name) > 0) pc("vendor", vendor_name)
    if (length(pid_str) > 0) pc("product ID", pid_str)
    if (length(vid_str) > 0) pc("vendor ID", vid_str)
    if (length(serial) > 0) pc("serial", serial)
    spd = speed_str(dev_speed + 0)
    if (length(spd) > 0) pc("speed", spd)
    if (length(bcd) > 0) pc("device release", bcd)
    if (dev_power > 0) pc("max power", dev_power " mA")
}

/IOUSBHostDevice/ {
    flush_dev()
    dev_name = ""; vendor_name = ""; pid_str = ""; vid_str = ""
    serial = ""; dev_speed = 0; bcd = ""; dev_power = 0
    next
}
/USB Product Name/ { dev_name = getstr($0) }
/USB Vendor Name/ { vendor_name = getstr($0) }
/USB Product ID/ { pid_str = gethex($0) }
/USB Vendor ID/ { vid_str = gethex($0) }
/USB Serial Number/ { serial = getstr($0) }
/Device Speed/ { dev_speed = getnum($0) }
/USB Product Release/ { bcd = getnum($0) }
/MaxPower/ { dev_power = getnum($0) }

END { flush_dev() }