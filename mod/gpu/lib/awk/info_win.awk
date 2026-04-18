function fmtbytes(b) {
    if (b >= 1073741824) return sprintf("%.0f GB", b / 1073741824)
    if (b >= 1048576) return sprintf("%.0f MB", b / 1048576)
    return b " B"
}
/^Caption=/              { gpu = substr($0, 9) }
/^AdapterRAM=/           { ram = substr($0, 12) + 0 }
/^DriverVersion=/        { drvver = substr($0, 15) }
/^VideoModeDescription=/ { mode = substr($0, 23) }
/^$/ && gpu {
    printf "%-25s: %s\n", "gpu", gpu
    if (ram > 0)  printf "%-25s: %s\n", "memory", fmtbytes(ram)
    if (drvver)   printf "%-25s: %s\n", "driver version", drvver
    if (mode)     printf "%-25s: %s\n", "video mode", mode
    gpu = ""; ram = 0; drvver = ""; mode = ""
}