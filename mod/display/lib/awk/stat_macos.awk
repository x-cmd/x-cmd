# variables: tty
# Parse system_profiler SPDisplaysDataType (text) for basic stat info
# Shows: online status, auto brightness, connection
function getval(s,    i) {
    i = index(s, ": ")
    return i > 0 ? substr(s, i + 2) : ""
}
function pc(label, val,    color) {
    if (label ~ /^online$/) color = "1;32"
    else if (label ~ /^auto brightness$/) color = "1;33"
    else if (label ~ /^connection$/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}

/Displays:/ { in_displays = 1; next }
in_displays && /^        [A-Za-z]/ && index($0, ":") > 0 {
    # New display block
    if (in_dev && length(dname) > 0) {
        flush_stat()
    }
    dname = $0
    gsub(/^[ \t]+/, "", dname)
    gsub(/:$/, "", dname)
    in_dev = 1
    online = ""; autobright = ""; conn = ""
}
/Online:/                { online = getval($0) }
/Automatically Adjust Brightness:/ { autobright = getval($0) }
/Connection Type:/       { conn = getval($0) }

END {
    if (in_dev && length(dname) > 0) flush_stat()
}

function flush_stat() {
    pc("display", dname)
    if (length(online) > 0) pc("online", online)
    if (length(autobright) > 0) pc("auto brightness", autobright)
    if (length(conn) > 0) pc("connection", conn)
    printf "\n"
}
