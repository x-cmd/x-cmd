# Variables expected: -v tty=
# Parses system_profiler multi-type output for compact device list
#   SPBluetoothDataType, SPAudioDataType, SPCameraDataType,
#   SPCardReaderDataType, SPPowerDataType, SPThunderboltDataType

function getval(s,    p) {
    p = index(s, ": ")
    if (p > 0) return substr(s, p + 2)
    return ""
}

function print_ls_header() {
    if (tty) printf "\033[1;33m%-13s %-30s %s\033[0m\n", "TYPE", "DETAIL", "DEVICE"
    else printf "%-13s %-30s %s\n", "TYPE", "DETAIL", "DEVICE"
}

function print_ls_row(type, detail, device,    tc) {
    if (tty) {
        if (type == "Bluetooth") tc = "1;36"
        else if (type ~ /^Audio/) tc = "1;35"
        else if (type == "Camera") tc = "1;34"
        else if (type == "CardReader") tc = "1;33"
        else if (type == "Battery") tc = "1;32"
        else if (type == "Thunderbolt") tc = "1;34"
        else tc = "0"
        printf "\033[%sm%-13s\033[0m %-30s %s\n", tc, type, detail, device
    } else {
        printf "%-13s %-30s %s\n", type, detail, device
    }
}

BEGIN {
    print_ls_header()
}

# ── Section tracking ──
/^Bluetooth:$/       { section = "bt"; next }
/^Audio:$/           { section = "audio"; next }
/^Camera:$/          { section = "camera"; next }
/^Card Reader:$/     { section = "card"; next }
/^Power:$/           { section = "power"; next }
/^Thunderbolt\/USB4:/ { section = "tb"; next }

# ── Bluetooth ──
section == "bt" && /Bluetooth Controller:/ { in_bt_ctrl = 1; bt_conn = 0; bt_known = 0; next }
section == "bt" && in_bt_ctrl && /Chipset:/ { bt_chip = getval($0) }
section == "bt" && in_bt_ctrl && /State:/   { bt_state = getval($0) }
section == "bt" && /Not Connected:/   { in_bt_ctrl = 0; in_bt_nc = 1; next }
section == "bt" && /Connected:/       { in_bt_ctrl = 0; in_bt_nc = 0; next }
section == "bt" && in_bt_nc && /Address:/ { bt_known++ }

# ── Audio ──
section == "audio" && /^        .*麦克风:/ {
    au_name = $0; gsub(/:$/, "", au_name); gsub(/^[ \t]+/, "", au_name)
    au_type = "Audio-In"; au_sr = ""; au_transport = ""
    next
}
section == "audio" && /^        .*扬声器:/ {
    au_name = $0; gsub(/:$/, "", au_name); gsub(/^[ \t]+/, "", au_name)
    au_type = "Audio-Out"; au_sr = ""; au_transport = ""
    next
}
section == "audio" && /Current SampleRate:/ { au_sr = getval($0) }
section == "audio" && /Transport:/          { au_transport = getval($0) }
section == "audio" && /^[ \t]*$/ && au_name != "" {
    detail = au_transport != "" ? au_transport : ""
    if (au_sr != "") detail = detail (detail ? ", " : "") au_sr "Hz"
    print_ls_row(au_type, detail, au_name)
    au_name = ""
    next
}

# ── Camera ──
section == "camera" && /^    [^ \t].*[^ \t]:$/ {
    if (cam_name != "") {
        detail = (cam_model != "" && cam_model != cam_name) ? cam_model : "Built-in"
        print_ls_row("Camera", detail, cam_name)
    }
    cam_name = $0; gsub(/:$/, "", cam_name); gsub(/^[ \t]+/, "", cam_name)
    cam_model = ""
    next
}
section == "camera" && /Model ID:/ { cam_model = getval($0) }

# ── Card Reader ──
section == "card" && /Built in SD Card Reader:/ { card_name = "SD Card Reader"; next }
section == "card" && /Vendor ID:/ && card_name != "" {
    print_ls_row("CardReader", "Built-in, Vendor " getval($0), card_name)
    card_name = ""
}

# ── Power / Battery ──
section == "power" && /Device Name:/ { bat_name = getval($0) }
section == "power" && /State of Charge/ { bat_pct = getval($0); gsub(/[^0-9]/, "", bat_pct) }
section == "power" && /Cycle Count:/ { bat_cycles = getval($0) }

# ── Thunderbolt ──
section == "tb" && /Thunderbolt\/USB4 Bus/ {
    if (tb_name != "") {
        detail = tb_speed != "" ? tb_speed : ""
        print_ls_row("Thunderbolt", detail, tb_name)
    }
    tb_name = $0; gsub(/:$/, "", tb_name); gsub(/^[ \t]+/, "", tb_name)
    tb_speed = ""
    next
}
section == "tb" && /Speed: Up to/ { tb_speed = getval($0) }

END {
    # Bluetooth
    if (bt_chip != "") {
        print_ls_row("Bluetooth", bt_state ", " bt_known " known", "Controller")
    }

    # Last audio
    if (au_name != "") {
        detail = au_transport != "" ? au_transport : ""
        if (au_sr != "") detail = detail (detail ? ", " : "") au_sr "Hz"
        print_ls_row(au_type, detail, au_name)
    }

    # Last camera
    if (cam_name != "") {
        detail = (cam_model != "" && cam_model != cam_name) ? cam_model : "Built-in"
        print_ls_row("Camera", detail, cam_name)
    }

    # Battery
    if (bat_name != "") {
        print_ls_row("Battery", bat_pct "%", bat_name)
    }

    # Last Thunderbolt
    if (tb_name != "") {
        detail = tb_speed != "" ? tb_speed : ""
        print_ls_row("Thunderbolt", detail, tb_name)
    }
}
