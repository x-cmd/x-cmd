# Variables expected: -v mode=sum|info -v tty=
# Linux peripheral overview — reads from /sys and /proc

function pc(label, val,    color) {
    if (label ~ /^device|^type|^driver/) color = "1;36"
    else if (label ~ /^manufacturer|^vendor|^serial/) color = "1;34"
    else if (label ~ /^status|^capacity|^charge/) color = "1;32"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

function print_row(type, status, detail, device) {
    if (tty) {
        if (type == "Bluetooth") tc = "1;36"
        else if (type ~ /^Audio/) tc = "1;35"
        else if (type == "Camera") tc = "1;34"
        else if (type == "Battery") tc = "1;32"
        else tc = "0"
        printf "\033[%sm%-13s\033[0m %-13s %-30s %s\n", tc, type, status, detail, device
    } else {
        printf "%-13s %-13s %-30s %s\n", type, status, detail, device
    }
}

function section_hdr(name) {
    if (tty) printf "\033[1;37m── %s ──\033[0m\n", name
    else printf "-- %s --\n", name
}

BEGIN {
    if (mode == "sum") {
        # Bluetooth
        while (("bluetoothctl list 2>/dev/null" | getline) > 0) {
            if ($0 ~ /Controller/) {
                print_row("Bluetooth", "Available", $2, $3)
            }
        }
        close("bluetoothctl list 2>/dev/null")

        # Audio sinks
        n_audio = 0
        while (("pactl list sinks 2>/dev/null" | getline) > 0) {
            if ($0 ~ /Name:/) { n_audio++; audio_name[n_audio] = substr($0, index($0, ": ") + 2) }
            if ($0 ~ /State:/) audio_state[n_audio] = substr($0, index($0, ": ") + 2)
        }
        close("pactl list sinks 2>/dev/null")
        for (i = 1; i <= n_audio; i++) {
            print_row("Audio-Out", audio_state[i], "", audio_name[i])
        }

        # Audio sources
        n_audio = 0
        while (("pactl list sources 2>/dev/null" | getline) > 0) {
            if ($0 ~ /Name:/) { n_audio++; audio_name[n_audio] = substr($0, index($0, ": ") + 2) }
            if ($0 ~ /State:/) audio_state[n_audio] = substr($0, index($0, ": ") + 2)
        }
        close("pactl list sources 2>/dev/null")
        for (i = 1; i <= n_audio; i++) {
            print_row("Audio-In", audio_state[i], "", audio_name[i])
        }

        # Camera
        while (("ls /sys/class/video4linux/ 2>/dev/null" | getline) > 0) {
            cam_dev = $0
            cam_name = ""
            if (("cat /sys/class/video4linux/" cam_dev "/name 2>/dev/null" | getline) > 0) {
                cam_name = $0
            }
            close("cat /sys/class/video4linux/" cam_dev "/name 2>/dev/null")
            print_row("Camera", "Available", cam_name, cam_dev)
        }
        close("ls /sys/class/video4linux/ 2>/dev/null")

        # Battery
        while (("ls /sys/class/power_supply/ 2>/dev/null" | getline) > 0) {
            bat_dev = $0
            bat_type = ""; bat_cap = ""; bat_status = ""
            if (("cat /sys/class/power_supply/" bat_dev "/type 2>/dev/null" | getline) > 0) bat_type = $0
            close("cat /sys/class/power_supply/" bat_dev "/type 2>/dev/null")
            if (bat_type != "Battery") continue
            if (("cat /sys/class/power_supply/" bat_dev "/capacity 2>/dev/null" | getline) > 0) bat_cap = $0
            close("cat /sys/class/power_supply/" bat_dev "/capacity 2>/dev/null")
            if (("cat /sys/class/power_supply/" bat_dev "/status 2>/dev/null" | getline) > 0) bat_status = $0
            close("cat /sys/class/power_supply/" bat_dev "/status 2>/dev/null")
            print_row("Battery", bat_cap "%", bat_status, bat_dev)
        }
        close("ls /sys/class/power_supply/ 2>/dev/null")
    }
}
