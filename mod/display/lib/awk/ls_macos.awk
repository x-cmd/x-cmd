# variables: tty
# Parse system_profiler SPDisplaysDataType -json for compact table
# Columns: DISPLAY, TYPE, RESOLUTION, REFRESH, CONNECTION
function pc_header() {
    if (tty) printf "\033[1;33m%-15s %-35s %-20s %-12s %-12s\033[0m\n", "DISPLAY", "TYPE", "RESOLUTION", "REFRESH", "CONNECTION"
    else printf "%-15s %-35s %-20s %-12s %-12s\n", "DISPLAY", "TYPE", "RESOLUTION", "REFRESH", "CONNECTION"
}
function pc_row(name, dtype, res, rate, conn,    nc, tc, rc, racc, cc) {
    nc = "1;36"; tc = "0;90"; rc = "1;32"; racc = "1;32"; cc = "1;35"
    if (tty) {
        printf "\033[%sm%-15s\033[0m \033[%sm%-35s\033[0m \033[%sm%-20s\033[0m \033[%sm%-12s\033[0m \033[%sm%-12s\033[0m\n", \
            nc, name, tc, dtype, rc, res, racc, rate, cc, conn
    } else {
        printf "%-15s %-35s %-20s %-12s %-12s\n", name, dtype, res, rate, conn
    }
}
function get_json_str(s,    p, v) {
    p = index(s, " : ")
    if (p == 0) return ""
    v = substr(s, p + 3)
    gsub(/,$/, "", v)
    gsub(/^[ \t]*"/, "", v)
    gsub(/"[ \t]*$/, "", v)
    return v
}
function clean_conn(s) {
    gsub(/spdisplays_/, "", s)
    return s
}

BEGIN {
    header_printed = 0
    dev_count = 0
    d_name = ""; d_type = ""; d_res = ""; d_rate = ""; d_conn = ""
    in_ndrvs = 0
}

# Detect spdisplays_ndrvs array (contains display entries)
/spdisplays_ndrvs/ { in_ndrvs = 1 }
/^[ \t]*\][ \t]*$/ {
    if (in_ndrvs) {
        in_ndrvs = 0
        if (dev_count > 0) {
            if (header_printed == 0) {
                pc_header()
                header_printed = 1
            }
            pc_row(d_name, d_type, d_res, d_rate, d_conn)
            dev_count = 0
        }
    }
}

# Display name (only inside ndrvs array)
/"_name"/ && in_ndrvs {
    if (dev_count > 0) {
        if (header_printed == 0) {
            pc_header()
            header_printed = 1
        }
        pc_row(d_name, d_type, d_res, d_rate, d_conn)
    }
    d_name = get_json_str($0)
    d_type = ""; d_res = ""; d_rate = ""; d_conn = ""
    dev_count++
}

# Resolution with refresh rate: "1512 x 982 @ 120.00Hz"
/_spdisplays_resolution/ {
    val = get_json_str($0)
    at = index(val, "@")
    if (at > 0) {
        d_res = substr(val, 1, at - 2)
        d_rate = substr(val, at + 2)
        gsub(/[ \t]+$/, "", d_rate)
    } else {
        d_res = val
    }
}

# Connection type
/spdisplays_connection_type/ {
    val = get_json_str($0)
    d_conn = clean_conn(val)
}

# Display type: keep the raw JSON value which is like "spdisplays_built-in-liquid-retina-xdr"
# We just strip the spdisplays_ prefix and capitalize nicely
/spdisplays_display_type/ {
    val = get_json_str($0)
    # val = "spdisplays_built-in-liquid-retina-xdr"
    # Remove prefix
    gsub(/^spdisplays_built-in-/, "", val)
    gsub(/^spdisplays_external-/, "", val)
    gsub(/^spdisplays_/, "", val)
    # val = "liquid-retina-xdr"
    # Replace hyphens with spaces and capitalize
    gsub(/-/, " ", val)
    # Simple capitalize: first char uppercase, rest as-is
    # Split to words, capitalize each
    out = ""
    nw = split(val, w, " ")
    for (i = 1; i <= nw; i++) {
        if (length(w[i]) > 0) {
            w[i] = toupper(substr(w[i], 1, 1)) tolower(substr(w[i], 2))
        }
    }
    # Rejoin
    for (i = 1; i <= nw; i++) {
        if (length(w[i]) > 0) {
            if (length(out) > 0) out = out " "
            out = out w[i]
        }
    }
    d_type = out
}

END {
    if (dev_count > 0) {
        if (header_printed == 0) {
            pc_header()
        }
        pc_row(d_name, d_type, d_res, d_rate, d_conn)
    }
}
