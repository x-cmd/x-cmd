# Variables expected: -v mode=sum -v tty=
# Parses system_profiler multi-type output:
#   SPBluetoothDataType, SPAudioDataType, SPCameraDataType,
#   SPCardReaderDataType, SPPowerDataType
#
# All rows buffered, printed in END block in fixed type order

function getval(s,    p) {
    p = index(s, ": ")
    if (p > 0) return substr(s, p + 2)
    return ""
}
function add_row(t, s, det, dev) {
    n++; r_type[n] = t; r_status[n] = s; r_detail[n] = det; r_dev[n] = dev
}
function print_row(type, status, detail, device,    tc) {
    if (tty) {
        if (type == "Bluetooth")  tc = "1;36"
        else if (type ~ /^Audio/) tc = "1;35"
        else if (type == "Camera") tc = "1;34"
        else if (type == "CardReader") tc = "1;33"
        else if (type == "Battery") tc = "1;32"
        else tc = "0"
        printf "\033[%sm%-13s\033[0m %-13s %-30s %s\n", tc, type, status, detail, device
    } else {
        printf "%-13s %-13s %-30s %s\n", type, status, detail, device
    }
}

# ── Section tracking ──
/^Bluetooth:$/       { section = "bt"; next }
/^Audio:$/           { section = "audio"; next }
/^Camera:$/          { section = "camera"; next }
/^Card Reader:$/     { section = "card"; next }
/^Power:$/           { section = "power"; next }

# ── Bluetooth ──
section == "bt" && /Bluetooth Controller:/ { in_bt_ctrl = 1; bt_conn = 0; bt_known = 0; next }
section == "bt" && in_bt_ctrl && /Address:/ { bt_addr = getval($0) }
section == "bt" && in_bt_ctrl && /State:/   { bt_state = getval($0) }
section == "bt" && in_bt_ctrl && /Chipset:/ { bt_chip = getval($0) }
section == "bt" && in_bt_ctrl && /Firmware Version:/ { bt_fw = getval($0) }
section == "bt" && in_bt_ctrl && /Vendor ID:/ { bt_vendor = getval($0) }
section == "bt" && /Not Connected:/   { in_bt_ctrl = 0; in_bt_nc = 1; next }
section == "bt" && /Connected:/ && !/Not Connected/ { in_bt_ctrl = 0; in_bt_nc = 0; next }
section == "bt" && in_bt_nc && /^[ \t]+.*Address:/ { bt_known++ }

# ── Audio ──
section == "audio" && /^        [^ \t].*:/ {
    if (au_name != "") {
        d = au_transport != "" ? au_transport : ""
        if (au_sr != "") d = d (d ? ", " : "") au_sr "Hz"
        s = au_type == "Audio-Out" ? "Output" : "Input"
        if (au_default) s = s " (Default)"
        add_row(au_type, s, d, au_name)
    }
    au_name = $0
    gsub(/:$/, "", au_name)
    gsub(/^[ \t]+/, "", au_name)
    au_type = ($0 ~ /扬声器/) ? "Audio-Out" : "Audio-In"
    au_sr = ""; au_transport = ""; au_default = 0
    next
}
section == "audio" && /Current SampleRate:/ { au_sr = getval($0) }
section == "audio" && /Transport:/          { au_transport = getval($0) }
section == "audio" && /Default Input Device:/ { au_default = 1 }
section == "audio" && /Default Output Device:/ { au_default = 1 }

# ── Camera ──
section == "camera" && /^    [^ \t].*[^ \t]:$/ {
    if (cam_name != "") {
        if (cam_model == cam_name || cam_model == "") s = "Built-in"
        else s = "External"
        d = (cam_model != "" && cam_model != cam_name) ? cam_model : ""
        add_row("Camera", s, d, cam_name)
    }
    cam_name = $0
    gsub(/:$/, "", cam_name)
    gsub(/^[ \t]+/, "", cam_name)
    cam_model = ""
    next
}
section == "camera" && /Model ID:/ {
    cam_model = getval($0)
}

# ── Card Reader ──
section == "card" && /Built in SD Card Reader:/ {
    card_name = "SD Card Reader"
    next
}
section == "card" && /Vendor ID:/ && card_name != "" {
    add_row("CardReader", "Built-in", "Vendor " getval($0), card_name)
    card_name = ""
}

# ── Power / Battery ──
section == "power" && /Device Name:/ { bat_name = getval($0) }
section == "power" && /Serial Number:/ && !bat_serial { bat_serial = getval($0) }
section == "power" && /State of Charge/ { bat_pct = getval($0); gsub(/[^0-9]/, "", bat_pct) }
section == "power" && /Cycle Count:/ { bat_cycles = getval($0) }
section == "power" && /Condition:/ { bat_cond = getval($0) }
section == "power" && /Maximum Capacity:/ { bat_max = getval($0) }

END {
    # Header
    if (tty) printf "\033[1;33m%-13s %-13s %-30s %s\033[0m\n", "TYPE", "STATUS", "DETAIL", "DEVICE"
    else printf "%-13s %-13s %-30s %s\n", "TYPE", "STATUS", "DETAIL", "DEVICE"

    # Flush remaining items into buffer
    if (au_name != "") {
        d = au_transport != "" ? au_transport : ""
        if (au_sr != "") d = d (d ? ", " : "") au_sr "Hz"
        s = au_type == "Audio-Out" ? "Output" : "Input"
        if (au_default) s = s " (Default)"
        add_row(au_type, s, d, au_name)
    }
    if (cam_name != "") {
        if (cam_model == cam_name || cam_model == "") s = "Built-in"
        else s = "External"
        d = (cam_model != "" && cam_model != cam_name) ? cam_model : ""
        add_row("Camera", s, d, cam_name)
    }

    # Bluetooth (from collected vars)
    if (bt_chip != "") {
        add_row("Bluetooth", bt_state, bt_conn " connected, " bt_known " known", bt_chip " Controller")
    }

    # Battery (from collected vars)
    if (bat_name != "") {
        bat_detail = bat_cycles " cycles, " bat_cond
        if (bat_max != "") bat_detail = bat_detail ", " bat_max " capacity"
        add_row("Battery", bat_pct "%", bat_detail, bat_name)
    }

    # Print in type order: BT, Audio, Camera, CardReader, Battery
    for (i = 1; i <= n; i++) {
        if (r_type[i] == "Bluetooth") print_row(r_type[i], r_status[i], r_detail[i], r_dev[i])
    }
    for (i = 1; i <= n; i++) {
        if (r_type[i] ~ /^Audio/) print_row(r_type[i], r_status[i], r_detail[i], r_dev[i])
    }
    for (i = 1; i <= n; i++) {
        if (r_type[i] == "Camera") print_row(r_type[i], r_status[i], r_detail[i], r_dev[i])
    }
    for (i = 1; i <= n; i++) {
        if (r_type[i] == "CardReader") print_row(r_type[i], r_status[i], r_detail[i], r_dev[i])
    }
    for (i = 1; i <= n; i++) {
        if (r_type[i] == "Battery") print_row(r_type[i], r_status[i], r_detail[i], r_dev[i])
    }
}
