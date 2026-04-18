# Variables expected: -v mode=ls -v tty=
# Linux compact device listing

function print_ls_header() {
    if (tty) printf "\033[1;33m%-13s %-30s %s\033[0m\n", "TYPE", "DETAIL", "DEVICE"
    else printf "%-13s %-30s %s\n", "TYPE", "DETAIL", "DEVICE"
}

function print_ls_row(type, detail, device,    tc) {
    if (tty) {
        if (type == "Bluetooth") tc = "1;36"
        else if (type ~ /^Audio/) tc = "1;35"
        else if (type == "Camera") tc = "1;34"
        else if (type == "Battery") tc = "1;32"
        else tc = "0"
        printf "\033[%sm%-13s\033[0m %-30s %s\n", tc, type, detail, device
    } else {
        printf "%-13s %-30s %s\n", type, detail, device
    }
}

BEGIN {
    print_ls_header()

    # Bluetooth
    while (("bluetoothctl list 2>/dev/null" | getline) > 0) {
        if ($0 ~ /Controller/) {
            print_ls_row("Bluetooth", $2, "Controller")
        }
    }
    close("bluetoothctl list 2>/dev/null")

    # Audio
    while (("pactl list sinks short 2>/dev/null" | getline) > 0) {
        print_ls_row("Audio-Out", "", $2)
    }
    close("pactl list sinks short 2>/dev/null")
    while (("pactl list sources short 2>/dev/null" | getline) > 0) {
        print_ls_row("Audio-In", "", $2)
    }
    close("pactl list sources short 2>/dev/null")

    # Camera
    while (("ls /sys/class/video4linux/ 2>/dev/null" | getline) > 0) {
        cam_dev = $0
        cam_name = ""
        if (("cat /sys/class/video4linux/" cam_dev "/name 2>/dev/null" | getline) > 0) {
            cam_name = $0
        }
        close("cat /sys/class/video4linux/" cam_dev "/name 2>/dev/null")
        print_ls_row("Camera", cam_name, cam_dev)
    }
    close("ls /sys/class/video4linux/ 2>/dev/null")

    # Battery
    while (("ls /sys/class/power_supply/ 2>/dev/null" | getline) > 0) {
        bat_dev = $0
        bat_cap = ""
        if (("cat /sys/class/power_supply/" bat_dev "/type 2>/dev/null" | getline) > 0) {
            if ($0 != "Battery") { close("cat /sys/class/power_supply/" bat_dev "/type 2>/dev/null"); continue }
        }
        close("cat /sys/class/power_supply/" bat_dev "/type 2>/dev/null")
        if (("cat /sys/class/power_supply/" bat_dev "/capacity 2>/dev/null" | getline) > 0) bat_cap = $0
        close("cat /sys/class/power_supply/" bat_dev "/capacity 2>/dev/null")
        print_ls_row("Battery", bat_cap "%", bat_dev)
    }
    close("ls /sys/class/power_supply/ 2>/dev/null")
}
