# variables: tty
# Parse xrandr --query for compact table
# Columns: DISPLAY, RESOLUTION, REFRESH, STATUS
function pc_header() {
    if (tty) printf "\033[1;33m%-15s %-20s %-12s %-12s\033[0m\n", "DISPLAY", "RESOLUTION", "REFRESH", "STATUS"
    else printf "%-15s %-20s %-12s %-12s\n", "DISPLAY", "RESOLUTION", "REFRESH", "STATUS"
}
function pc_row(name, res, rate, status,    nc, rc, racc, sc) {
    nc = "1;36"
    rc = "1;32"
    racc = "1;32"
    sc = "1;34"
    if (tty) {
        printf "\033[%sm%-15s\033[0m \033[%sm%-20s\033[0m \033[%sm%-12s\033[0m \033[%sm%-12s\033[0m\n", nc, name, rc, res, racc, rate, sc, status
    } else {
        printf "%-15s %-20s %-12s %-12s\n", name, res, rate, status
    }
}

BEGIN {
    header_printed = 0
    dev_count = 0
    cur_name = ""
    cur_res = ""
    cur_rate = ""
}

# Connected display lines
/ connected / {
    if (header_printed == 0) {
        pc_header()
        header_printed = 1
    }
    # Flush previous
    if (dev_count > 0) {
        pc_row(cur_name, cur_res, cur_rate, "connected")
    }

    cur_name = $1
    cur_res = ""
    cur_rate = ""

    # Extract resolution
    geom = ""
    for (i = 3; i <= NF; i++) {
        if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
            geom = $i
            break
        }
    }
    if (length(geom) > 0) {
        plus = index(geom, "+")
        if (plus > 0) cur_res = substr(geom, 1, plus - 1)
    }
    dev_count++
}

# Current mode (with * marker)
/^[ \t]/ && /\*/ {
    n = split($0, fields)
    for (i = 1; i <= n; i++) {
        if (fields[i] == "*") {
            if (i > 1) {
                cur_rate = fields[i-1]
                gsub(/\+/, "", cur_rate)
                cur_rate = cur_rate " Hz"
            }
            break
        }
    }
}

END {
    if (dev_count > 0) {
        pc_row(cur_name, cur_res, cur_rate, "connected")
    }
}
