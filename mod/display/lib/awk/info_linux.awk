# variables: tty
# Parse xrandr --query output
# Extracts display name, connected status, resolution, refresh rate, position
function pc(label, val,    color) {
    if (label ~ /^display$/) color = "1;36"
    else if (label ~ /^resolution$|^mode$/) color = "1;32"
    else if (label ~ /^refresh rate$/) color = "1;32"
    else if (label ~ /^position$/) color = "1;34"
    else if (label ~ /^status$|^connected$/) color = "1;34"
    else if (label ~ /^primary$/) color = "1;33"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

# Connected display lines: "DP-1 connected primary 2560x1440+0+0 (normal left ...)"
/ connected / {
    name = $1
    # Check if primary
    primary = "no"
    if (index($0, " primary ") > 0) primary = "yes"

    # Extract resolution and position from geometry field
    geom = ""
    for (i = 3; i <= NF; i++) {
        if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
            geom = $i
            break
        }
    }

    pc("display", name)
    pc("connected", "yes")
    pc("primary", primary)

    if (length(geom) > 0) {
        # Split geometry: 2560x1440+0+0
        res = geom
        plus = index(res, "+")
        if (plus > 0) res = substr(res, 1, plus - 1)
        pc("resolution", res)
        pos = geom
        x_pos = index(pos, "+")
        if (x_pos > 0) {
            pos = substr(pos, x_pos + 1)
            pc("position", "+" pos)
        }
    }
    printf "\n"
    first_mode = 1
}

# Current mode line (marked with *): "   2560x1440     59.95 +  74.91 *"
/^[ \t]/ && /\*/ {
    # Extract refresh rate from current mode
    n = split($0, fields)
    for (i = 1; i <= n; i++) {
        if (index(fields[i], "*") > 0) {
            # Rate is the field containing * (e.g. "59.96*+")
            rate = fields[i]
            gsub(/\*|\+/, "", rate)
            if (rate + 0 > 0) pc("refresh rate", rate " Hz")
            break
        }
    }
}

# Disconnected display lines: "HDMI-1 disconnected"
/ disconnected/ && !/ connected/ {
    # Optionally show disconnected displays
}
