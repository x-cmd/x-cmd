# variables: tty
# Parse xrandr --verbose for brightness info
function pc(label, val,    color) {
    if (label ~ /^display$/) color = "1;36"
    else if (label ~ /^brightness$/) color = "1;33"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

# Connected display
/ connected / {
    if (length(cur_name) > 0) {
        if (has_brightness == 1) printf "\n"
    }
    cur_name = $1
    has_brightness = 0
}

# Brightness line (xrandr --verbose): "Brightness: 1.00"
/Brightness:/ {
    val = $0
    p = index(val, ":")
    if (p > 0) {
        val = substr(val, p + 2)
        gsub(/^[ \t]+/, "", val)
        pc("display", cur_name)
        pc("brightness", val)
        has_brightness = 1
    }
}

END {
    if (has_brightness == 1) printf "\n"
}
