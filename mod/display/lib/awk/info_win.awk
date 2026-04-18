# Parse wmic path Win32_DesktopMonitor output (name=value format)
function getval(s,    i) {
    i = index(s, "=")
    return i > 0 ? substr(s, i + 1) : ""
}

/^Name=/ {
    val = getval($0)
    if (length(val) > 0) printf "%-25s: %s\n", "display", val
}
/^MonitorType=/ {
    val = getval($0)
    if (length(val) > 0) printf "%-25s: %s\n", "type", val
}
/^ScreenWidth=/ {
    val = getval($0)
    if (length(val) > 0) printf "%-25s: %s\n", "width", val
}
/^ScreenHeight=/ {
    val = getval($0)
    if (length(val) > 0) printf "%-25s: %s\n", "height", val
}
/^$/ {
    # New device separator
    printf "\n"
}
