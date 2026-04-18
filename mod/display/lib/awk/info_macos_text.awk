# variables: tty
# Parse system_profiler SPDisplaysDataType (text format)
# Extracts: name, display type, resolution, main display, mirror, online,
#           auto brightness, connection type
function getval(s,    i) {
    i = index(s, ": ")
    return i > 0 ? substr(s, i + 2) : ""
}
function pc(label, val,    color) {
    if (label ~ /^display$|^name$/) color = "1;36"
    else if (label ~ /^type$/) color = "1;36"
    else if (label ~ /^resolution$|^pixel resolution$/) color = "1;32"
    else if (label ~ /^main display$|^online$|^mirror$/) color = "1;34"
    else if (label ~ /^connection$/) color = "1;35"
    else if (label ~ /^auto brightness$|^ambient brightness$/) color = "1;33"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

/Displays:/ { in_displays = 1; next }
in_displays && /^[^ \t]/ { in_displays = 0; in_dev = 0 }
in_displays && /^        [A-Za-z]/ && index($0, ":") > 0 {
    # New display block, e.g., "        Color LCD:"
    if (in_dev) {
        # Flush previous device
        flush_dev()
    }
    name = $0
    gsub(/^[ \t]+/, "", name)
    gsub(/:$/, "", name)
    in_dev = 1
    dtype = ""; res = ""; main = ""; mirror = ""; online = ""; autobright = ""; conn = ""
}
/Display Type:/          { dtype = getval($0) }
/Resolution:/            { res = getval($0) }
/Main Display:/          { main = getval($0) }
/Mirror:/                { mirror = getval($0) }
/Online:/                { online = getval($0) }
/Automatically Adjust Brightness:/ { autobright = getval($0) }
/Connection Type:/       { conn = getval($0) }

END {
    if (in_dev) flush_dev()
}

function flush_dev() {
    if (length(name) == 0) return
    pc("display", name)
    if (length(dtype) > 0) pc("type", dtype)
    if (length(res) > 0) pc("resolution", res)
    if (length(main) > 0) pc("main display", main)
    if (length(mirror) > 0) pc("mirror", mirror)
    if (length(online) > 0) pc("online", online)
    if (length(autobright) > 0) pc("auto brightness", autobright)
    if (length(conn) > 0) pc("connection", conn)
    printf "\n"
}
