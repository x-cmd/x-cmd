# Variables expected via -v: format
function fmtbytes(b) {
    if (b >= 1099511627776) return sprintf("%.2f TB", b / 1099511627776)
    if (b >= 1073741824) return sprintf("%.0f GB", b / 1073741824)
    return b " B"
}
/^DeviceID=/ { dev = substr($0, 10) }
/^Size=/ { size = substr($0, 6) + 0 }
/^FreeSpace=/ { free = substr($0, 11) + 0 }
/^FileSystem=/ { fs = substr($0, 12) }
/^VolumeName=/ { vol = substr($0, 12) }
/^$/ && dev {
    used = size - free
    pct = (size > 0) ? used / size * 100 : 0
    if (format == "tsv") {
        printf "%s\t%s\t%s\t%d\t%d\t%d\t%.0f%%\n", dev, vol, fs, size, used, free, pct
    } else {
        printf "%-8s%-14s%-26s%8s%8s%8s%4.0f%%\n", dev, vol, fs, fmtbytes(size), fmtbytes(used), fmtbytes(free), pct
    }
    dev = ""; size = 0; free = 0; fs = ""; vol = ""
}