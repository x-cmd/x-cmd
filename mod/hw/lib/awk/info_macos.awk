# Variables expected: -v tty=
# Parses system_profiler multi-type output for detailed info (key:value format)
#   SPBluetoothDataType, SPAudioDataType, SPCameraDataType,
#   SPCardReaderDataType, SPPowerDataType, SPThunderboltDataType

function getval(s,    p) {
    p = index(s, ": ")
    if (p > 0) return substr(s, p + 2)
    return ""
}
function pc(label, val,    color) {
    if (label ~ /^controller|^device|^address|^model|^name/) color = "1;36"
    else if (label ~ /^firmware|^software|^revision|^vendor|^serial/) color = "1;34"
    else if (label ~ /^state|^status|^condition|^charge|^cycles|^capacity/) color = "1;32"
    else if (label ~ /^type|^channels|^sample rate|^transport|^speed/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
function section_hdr(name) {
    printf "\n"
    if (tty) printf "\033[1;37m── %s ──\033[0m\n", name
    else printf "-- %s --\n", name
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
section == "bt" && in_bt_ctrl && /Address:/ { bt_addr = getval($0) }
section == "bt" && in_bt_ctrl && /State:/   { bt_state = getval($0) }
section == "bt" && in_bt_ctrl && /Chipset:/ { bt_chip = getval($0) }
section == "bt" && in_bt_ctrl && /Firmware Version:/ { bt_fw = getval($0) }
section == "bt" && in_bt_ctrl && /Product ID:/ { bt_pid = getval($0) }
section == "bt" && in_bt_ctrl && /Vendor ID:/ { bt_vid = getval($0) }
section == "bt" && /Not Connected:/   { in_bt_ctrl = 0; in_bt_nc = 1; next }
section == "bt" && /Connected:/ && !/Not Connected/ { in_bt_ctrl = 0; in_bt_nc = 0; next }
section == "bt" && in_bt_nc && /Address:/ { bt_known++ }
section == "bt" && /Supported services:/ { bt_services = getval($0) }

# ── Audio ──
section == "audio" && /^        [^ \t].*:/ {
    # flush previous audio device
    if (au_name != "") {
        flush_au()
    }
    au_name = $0
    gsub(/:$/, "", au_name)
    gsub(/^[ \t]+/, "", au_name)
    au_manuf = ""; au_sr = ""; au_transport = ""
    au_channels = ""; au_au_type = ""; au_default_in = 0; au_default_out = 0
    au_source = ""
    next
}
section == "audio" && /Default Input Device:/ { au_default_in = 1 }
section == "audio" && /Default Output Device:/ { au_default_out = 1 }
section == "audio" && /Input Channels:/ { au_channels = getval($0); au_au_type = "Input" }
section == "audio" && /Output Channels:/ { au_channels = getval($0); au_au_type = "Output" }
section == "audio" && /Manufacturer:/ { au_manuf = getval($0) }
section == "audio" && /Current SampleRate:/ { au_sr = getval($0) }
section == "audio" && /Transport:/ { au_transport = getval($0) }
section == "audio" && /Input Source:/ { au_source = getval($0) }
section == "audio" && /Output Source:/ { au_source = getval($0) }

function flush_au() {
    section_hdr("Audio")
    pc("device", au_name)
    if (au_manuf != "") pc("manufacturer", au_manuf)
    pc("type", au_au_type (au_default_in ? " (Default)" : "") (au_default_out ? " (Default)" : ""))
    if (au_channels != "") pc("channels", au_channels)
    if (au_sr != "") pc("sample rate", au_sr)
    if (au_transport != "") pc("transport", au_transport)
    if (au_source != "") pc("source", au_source)
}

# ── Camera ──
section == "camera" && /^    [^ \t].*[^ \t]:$/ {
    if (cam_name != "") {
        flush_cam()
    }
    cam_name = $0
    gsub(/:$/, "", cam_name)
    gsub(/^[ \t]+/, "", cam_name)
    cam_model = ""; cam_uid = ""
    next
}
section == "camera" && /Model ID:/ { cam_model = getval($0) }
section == "camera" && /Unique ID:/ { cam_uid = getval($0) }

function flush_cam() {
    section_hdr("Camera")
    pc("device", cam_name)
    if (cam_model != "") pc("model ID", cam_model)
    if (cam_uid != "") pc("unique ID", cam_uid)
}

# ── Card Reader ──
section == "card" && /Built in SD Card Reader:/ {
    card_name = "Built-in SD Card Reader"
    card_vid = ""; card_did = ""; card_rev = ""
    next
}
section == "card" && /Vendor ID:/ && card_name != "" { card_vid = getval($0) }
section == "card" && /Device ID:/ && card_name != "" { card_did = getval($0) }
section == "card" && /Revision:/ && card_name != "" { card_rev = getval($0) }

# ── Power / Battery ──
section == "power" && /Device Name:/ { bat_name = getval($0) }
section == "power" && /Serial Number:/ && !bat_serial { bat_serial = getval($0) }
section == "power" && /Firmware Version:/ && !bat_fw { bat_fw = getval($0) }
section == "power" && /State of Charge/ { bat_pct = getval($0); gsub(/[^0-9]/, "", bat_pct) }
section == "power" && /Cycle Count:/ { bat_cycles = getval($0) }
section == "power" && /Condition:/ { bat_cond = getval($0) }
section == "power" && /Maximum Capacity:/ { bat_max = getval($0) }
section == "power" && /Charging:/ && !bat_charging_done { bat_charging = getval($0); bat_charging_done = 1 }
section == "power" && /Fully Charged:/ { bat_full = getval($0) }

# ── Thunderbolt ──
section == "tb" && /Thunderbolt\/USB4 Bus/ {
    if (tb_name != "") {
        flush_tb()
    }
    tb_name = $0
    gsub(/:$/, "", tb_name)
    gsub(/^[ \t]+/, "", tb_name)
    tb_vendor = ""; tb_uid = ""; tb_speed = ""; tb_connected = 0
    next
}
section == "tb" && /Vendor Name:/ { tb_vendor = getval($0) }
section == "tb" && /UID:/ && !tb_uid { tb_uid = getval($0) }
section == "tb" && /Speed: Up to/ { tb_speed = getval($0) }
section == "tb" && /Status:.*connected$/ && !/No device/ { tb_connected = 1 }

function flush_tb() {
    section_hdr("Thunderbolt")
    pc("bus", tb_name)
    if (tb_vendor != "") pc("vendor", tb_vendor)
    if (tb_uid != "") pc("UID", tb_uid)
    if (tb_speed != "") pc("speed", tb_speed)
    pc("status", tb_connected ? "Connected" : "No device connected")
}

END {
    # Bluetooth
    if (bt_chip != "") {
        section_hdr("Bluetooth")
        pc("controller", bt_chip)
        if (bt_addr != "") pc("address", bt_addr)
        pc("state", bt_state)
        if (bt_fw != "") pc("firmware", bt_fw)
        if (bt_vid != "") pc("vendor", bt_vid)
        if (bt_pid != "") pc("product ID", bt_pid)
        if (bt_services != "") pc("supported services", bt_services)
        pc("connected devices", bt_conn + 0)
        pc("known devices", bt_known + 0)
    }

    # Last audio device
    if (au_name != "") {
        flush_au()
    }

    # Last camera
    if (cam_name != "") {
        flush_cam()
    }

    # Card reader
    if (card_name != "") {
        section_hdr("Card Reader")
        pc("device", card_name)
        if (card_vid != "") pc("vendor ID", card_vid)
        if (card_did != "") pc("device ID", card_did)
        if (card_rev != "") pc("revision", card_rev)
    }

    # Battery
    if (bat_name != "") {
        section_hdr("Battery")
        pc("device", bat_name)
        if (bat_serial != "") pc("serial", bat_serial)
        if (bat_fw != "") pc("firmware", bat_fw)
        pc("charge", bat_pct "%")
        pc("charging", bat_charging != "" ? bat_charging : "Unknown")
        if (bat_full != "") pc("fully charged", bat_full)
        pc("cycle count", bat_cycles)
        pc("condition", bat_cond)
        if (bat_max != "") pc("maximum capacity", bat_max)
    }

    # Last Thunderbolt
    if (tb_name != "") {
        flush_tb()
    }
}
