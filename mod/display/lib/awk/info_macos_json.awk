# variables: tty
# Parse system_profiler SPDisplaysDataType -json
# Extracts: refresh rate, product ID, vendor ID, serial number,
#           display ID, pixel resolution
# JSON format: "key" : "value",
function pc(label, val,    color) {
    if (label ~ /^refresh rate$/) color = "1;32"
    else if (label ~ /^product id$|^vendor id$|^display id$/) color = "1;35"
    else if (label ~ /^serial$/) color = "1;34"
    else if (label ~ /^pixel resolution$/) color = "1;32"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
# Extract value from JSON "key" : "value" or "key" : value
function get_json_str(s,    p, v) {
    # Find " : " separator
    p = index(s, " : ")
    if (p == 0) return ""
    v = substr(s, p + 3)
    # Trim trailing comma
    gsub(/,$/, "", v)
    # Remove surrounding quotes
    gsub(/^[ \t]*"/, "", v)
    gsub(/"[ \t]*$/, "", v)
    return v
}
function get_json_val(s,    p, v) {
    p = index(s, " : ")
    if (p == 0) return ""
    v = substr(s, p + 3)
    gsub(/,$/, "", v)
    gsub(/^[ \t]*"/, "", v)
    gsub(/"[ \t]*$/, "", v)
    return v
}

# Refresh rate from _spdisplays_resolution: "1512 x 982 @ 120.00Hz"
/_spdisplays_resolution/ {
    val = get_json_str($0)
    at = index(val, "@")
    if (at > 0) {
        rate = substr(val, at + 2)
        gsub(/[ \t]+$/, "", rate)
        pc("refresh rate", rate)
    }
}

# Product ID
/_spdisplays_display-product-id/ {
    val = get_json_str($0)
    if (length(val) > 0) pc("product id", val)
}

# Vendor ID
/_spdisplays_display-vendor-id/ {
    val = get_json_str($0)
    if (length(val) > 0) pc("vendor id", val)
}

# Serial number
/_spdisplays_display-serial-number/ {
    val = get_json_str($0)
    if (length(val) > 0) pc("serial", val)
}

# Display ID
/_spdisplays_displayID/ {
    val = get_json_val($0)
    if (length(val) > 0) pc("display id", val)
}

# Pixel resolution (native pixels): "3024 x 1964"
/_spdisplays_pixels/ {
    val = get_json_str($0)
    if (length(val) > 0) pc("pixel resolution", val)
}
