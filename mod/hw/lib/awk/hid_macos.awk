# Variables expected: -v mode=sum|info|ls -v tty=
# Parses ioreg -r -c AppleDeviceManagementHIDEventService -l
# Extracts built-in keyboard and trackpad info

function getstr(s,    p, t, q) {
    p = index(s, "= \"")
    if (p < 1) return ""
    t = substr(s, p + 3)
    q = index(t, "\"")
    if (q < 1) return ""
    return substr(t, 1, q - 1)
}

function print_row(type, status, detail, device) {
    if (tty) {
        if (type == "Keyboard")  tc = "1;36"
        else if (type == "Trackpad") tc = "1;35"
        else tc = "0"
        printf "\033[%sm%-13s\033[0m %-13s %-30s %s\n", tc, type, status, detail, device
    } else {
        printf "%-13s %-13s %-30s %s\n", type, status, detail, device
    }
}

function pc(label, val,    color) {
    if (label ~ /^device|^product|^type/) color = "1;36"
    else if (label ~ /^manufacturer|^vendor/) color = "1;35"
    else if (label ~ /^built|^transport/) color = "1;32"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

/AppleDeviceManagementHIDEventService/ {
    # flush previous
    if (hid_product != "") {
        if (hid_product ~ /Keyboard/) {
            hid_type = "Keyboard"
        } else if (hid_product ~ /Trackpad/) {
            hid_type = "Trackpad"
        } else {
            hid_type = "HID"
        }
        hid_status = hid_builtin ? "Built-in" : "External"
        if (mode == "sum") {
            print_row(hid_type, hid_status, hid_transport, hid_product)
        } else if (mode == "info") {
            printf "\n"
            if (tty) printf "\033[1;37m── %s ──\033[0m\n", hid_type
            else printf "-- %s --\n", hid_type
            pc("device", hid_product)
            pc("manufacturer", hid_manuf)
            pc("built-in", hid_builtin ? "Yes" : "No")
            pc("transport", hid_transport)
        } else if (mode == "ls") {
            printf "%-13s %-30s %s\n", hid_type, hid_status, hid_product
        }
    }
    hid_product = ""; hid_manuf = ""; hid_builtin = 0; hid_transport = ""
    next
}

/"Product" = /   { hid_product = getstr($0) }
/"Manufacturer" = / { hid_manuf = getstr($0) }
/"Built-In" = Yes/ { hid_builtin = 1 }
/"Transport" = / { hid_transport = getstr($0) }

END {
    # flush last
    if (hid_product != "") {
        if (hid_product ~ /Keyboard/) {
            hid_type = "Keyboard"
        } else if (hid_product ~ /Trackpad/) {
            hid_type = "Trackpad"
        } else {
            hid_type = "HID"
        }
        hid_status = hid_builtin ? "Built-in" : "External"
        if (mode == "sum") {
            print_row(hid_type, hid_status, hid_transport, hid_product)
        } else if (mode == "info") {
            printf "\n"
            if (tty) printf "\033[1;37m── %s ──\033[0m\n", hid_type
            else printf "-- %s --\n", hid_type
            pc("device", hid_product)
            pc("manufacturer", hid_manuf)
            pc("built-in", hid_builtin ? "Yes" : "No")
            pc("transport", hid_transport)
        } else if (mode == "ls") {
            printf "%-13s %-30s %s\n", hid_type, hid_status, hid_product
        }
    }
}
