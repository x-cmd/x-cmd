# Variables expected via -v: none
function fmtbytes(b) {
    if (b >= 1099511627776) return sprintf("%.2f TB", b / 1099511627776)
    if (b >= 1073741824) return sprintf("%.0f GB", b / 1073741824)
    return b " B"
}
/^Model=/ { model = substr($0, 7) }
/^Size=/ { size = substr($0, 6) + 0 }
/^MediaType=/ { mtype = substr($0, 11) }
/^InterfaceType=/ { iface = substr($0, 15) }
/^SerialNumber=/ { serial = substr($0, 14) }
/^Status=/ { status = substr($0, 8) }
/^$/ && model {
    printf "%-25s: %s\n", "model", model
    if (size > 0) printf "%-25s: %s\n", "capacity", fmtbytes(size)
    if (mtype) printf "%-25s: %s\n", "media type", mtype
    if (iface) printf "%-25s: %s\n", "interface", iface
    if (serial) printf "%-25s: %s\n", "serial", serial
    if (status) printf "%-25s: %s\n", "status", status
    printf "\n"
    model = ""; size = 0; mtype = ""; iface = ""; serial = ""; status = ""
}