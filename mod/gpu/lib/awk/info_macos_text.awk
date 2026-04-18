# variables: simple, tty
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function pc(label, val,    color) {
    if (label ~ /^gpu$|^cores$|^vendor$|^bus$|^metal$/) color = "1;36"
    else if (label ~ /^display$|^resolution|^main display|^connection|^refresh rate|^online|^ambient/) color = "1;33"
    else if (label ~ /^metal plugin|^memory allocated/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/Chipset Model:/         { gpu = getval($0) }
/Total Number of Cores:/ { gpucores = getval($0) + 0 }
/Vendor:/                { gpuvendor = getval($0) }
/Bus:/                   { gpubus = getval($0) }
/Metal Support:/         { metal = getval($0) }
/Display Type:/          { display = getval($0) }
/Resolution:/            { resolution = getval($0) }
/Main Display:/          { maindisp = getval($0) }
/Connection Type:/       { dispconn = getval($0) }
END {
    if (!gpu) exit 1
    # Identity
    pc("gpu", gpu)
    if (gpucores)  pc("cores", gpucores)
    if (gpuvendor) pc("vendor", gpuvendor)
    if (gpubus)    pc("bus", gpubus)
    if (metal)     pc("metal", metal)
    # Display
    if (!simple) {
        if (display)    pc("display", display)
        if (resolution) pc("resolution", resolution)
        if (maindisp)   pc("main display", maindisp)
        if (dispconn)   pc("connection", dispconn)
    }
}