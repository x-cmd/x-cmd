# Variables expected: -v tty=
# Parses output from: x cpu info --simple, x gpu info --simple, x free, x disk stat --simple
# Outputs one table row per module's key info

function getval(s,    p) {
    p = index(s, ": ")
    if (p > 0) return substr(s, p + 2)
    return ""
}
function trim(s) { gsub(/^[ \t]+/, "", s); gsub(/[ \t]+$/, "", s); return s }
function print_core(type, status, detail, device,    tc) {
    if (type == "CPU") tc = "1;36"
    else if (type == "GPU") tc = "1;35"
    else if (type == "Memory") tc = "1;32"
    else if (type == "Disk") tc = "1;34"
    else tc = "0"
    if (tty) printf "\033[%sm%-13s\033[0m %-13s %-30s %s\n", tc, type, status, detail, device
    else printf "%-13s %-13s %-30s %s\n", type, status, detail, device
}

# ── CPU ──
/model name/ { cpu_model = trim(getval($0)) }
/physical cores/ { cpu_cores = trim(getval($0)) }
/^memory/ { cpu_mem = trim(getval($0)) }

# ── GPU ──
/^gpu[ \t]*:/ { gpu_name = trim(getval($0)) }
/^cores[ \t]*:/ && !gpu_cores { gpu_cores = trim(getval($0)) }
/^metal[ \t]*:/ { gpu_metal = trim(getval($0)) }

# ── Memory (x free): "  Mem:   32.0 Gi   24.7 Gi   7.3 Gi ..." ──
/^  Mem:/ {
    mem_total = $2 " " $3
    mem_used = $4 " " $5
}

# ── Disk: "-- disk0 | MODEL | SIZE | TYPE | LOCATION" ──
/^-- disk/ {
    if (disk_model != "") {
        print_core("Disk", disk_size, disk_detail, disk_model)
    }
    rest = $0
    gsub(/^-- /, "", rest)
    p1 = index(rest, "|")
    if (p1 > 0) {
        disk_dev = trim(substr(rest, 1, p1 - 1))
        rest2 = substr(rest, p1 + 1)
        p2 = index(rest2, "|")
        if (p2 > 0) {
            disk_model = trim(substr(rest2, 1, p2 - 1))
            rest3 = substr(rest2, p2 + 1)
            p3 = index(rest3, "|")
            if (p3 > 0) {
                disk_size = trim(substr(rest3, 1, p3 - 1))
            }
        }
    }
    disk_detail = ""
    next
}
# Disk data line: disk3  926 GB  280 GB  646 GB  30%  Macintosh HD  /
# Fields: $1=dev $2=num $3=unit $4=used_num $5=unit $6=avail_num $7=unit $8=pct
/^disk[0-9]/ && /%/ && /\// {
    disk_used_pct = $8
    gsub(/%/, "", disk_used_pct)
    disk_detail = $4 " " $5 " used / " $2 " " $3 " (" disk_used_pct "%)"
}

END {
    if (cpu_model != "") {
        detail = cpu_cores " cores"
        if (cpu_mem != "") detail = detail ", " cpu_mem " RAM"
        print_core("CPU", cpu_model, detail, "")
    }
    if (gpu_name != "") {
        detail = ""
        if (gpu_cores != "") detail = gpu_cores " cores"
        if (gpu_metal != "") detail = detail (detail ? ", " : "") gpu_metal
        print_core("GPU", gpu_name, detail, "")
    }
    if (mem_total != "") {
        print_core("Memory", mem_total, mem_used " used", "")
    }
    if (disk_model != "") {
        if (disk_detail == "") disk_detail = disk_size
        print_core("Disk", disk_size, disk_detail, disk_model)
    }
}
