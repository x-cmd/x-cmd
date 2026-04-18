# Variables expected: -v mode=sum -v tty=
# Parses system_profiler SPThunderboltDataType

function getval(s,    p) {
    p = index(s, ": ")
    if (p > 0) return substr(s, p + 2)
    return ""
}

function print_row(type, status, detail, device) {
    if (tty) {
        printf "\033[1;34m%-13s\033[0m %-13s %-30s %s\n", type, status, detail, device
    } else {
        printf "%-13s %-13s %-30s %s\n", type, status, detail, device
    }
}

/Thunderbolt\/USB4 Bus/ {
    # flush previous
    if (tb_name != "") {
        tb_status = tb_connected ? "Connected" : "No device"
        tb_detail = tb_speed != "" ? tb_speed : ""
        print_row("Thunderbolt", tb_status, tb_detail, tb_name)
    }
    tb_name = $0
    gsub(/:$/, "", tb_name)
    gsub(/^[ \t]+/, "", tb_name)
    tb_speed = ""
    tb_connected = 0
    next
}
/Status:.*connected$/ && !/No device/ { tb_connected = 1 }
/Speed: Up to/  { tb_speed = getval($0) }

END {
    if (tb_name != "") {
        tb_status = tb_connected ? "Connected" : "No device"
        tb_detail = tb_speed != "" ? tb_speed : ""
        print_row("Thunderbolt", tb_status, tb_detail, tb_name)
    }
}
