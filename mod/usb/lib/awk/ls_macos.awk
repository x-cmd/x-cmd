# Expected variables: -v tty=""

function getstr(s,    p, t, q) {
    p = index(s, "= \"")
    if (p < 1) return ""
    t = substr(s, p + 3)
    q = index(t, "\"")
    if (q < 1) return ""
    return substr(t, 1, q - 1)
}
function getnum(s,    p, t) {
    p = index(s, "= ")
    if (p < 1) return ""
    t = substr(s, p + 2)
    sub(/,.*/, "", t)
    return t + 0
}
function speed_str(code) {
    if (code == 1) return "12M"
    if (code == 2) return "480M"
    if (code == 3) return "5G"
    if (code == 4) return "10G"
    if (code > 0) return code ""
    return ""
}
function flush_dev(    spd) {
    if (length(dev_name) == 0) return
    n = ++dev_n
    devs_name[n] = dev_name
    devs_vendor[n] = vendor_name
    devs_speed[n] = speed_str(dev_speed + 0)
    devs_serial[n] = serial
}

/IOUSBHostDevice/ {
    flush_dev()
    dev_name = ""; vendor_name = ""; dev_speed = 0; serial = ""
    next
}
/USB Product Name/ { dev_name = getstr($0) }
/USB Vendor Name/ { vendor_name = getstr($0) }
/Device Speed/ { dev_speed = getnum($0) }
/USB Serial Number/ { serial = getstr($0) }

END {
    flush_dev()
    if (dev_n == 0) exit 0

    if (tty) printf "\033[1;33m%-30s %-15s %-8s %s\033[0m\n", "DEVICE", "VENDOR", "SPEED", "SERIAL"
    else printf "%-30s %-15s %-8s %s\n", "DEVICE", "VENDOR", "SPEED", "SERIAL"

    for (i = 1; i <= dev_n; i++) {
        if (tty) {
            printf "\033[1;36m%-30s\033[0m \033[1;35m%-15s\033[0m \033[1;32m%-8s\033[0m \033[1;34m%s\033[0m\n", \
                devs_name[i], devs_vendor[i], devs_speed[i], devs_serial[i]
        } else {
            printf "%-30s %-15s %-8s %s\n", \
                devs_name[i], devs_vendor[i], devs_speed[i], devs_serial[i]
        }
    }
}