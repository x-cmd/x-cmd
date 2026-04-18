# Variables expected via -v: simple, tty, richfile
function getval(s,    v) {
    i = index(s, ": ")
    if (i < 1) return ""
    v = substr(s, i + 2)
    gsub(/^[ \t]+/, "", v)
    gsub(/[ \t]+$/, "", v)
    return v
}
function extract_bytes(s,    p, t, q) {
    p = index(s, "(")
    if (p < 1) return 0
    t = substr(s, p + 1)
    q = index(t, " ")
    if (q < 1) return 0
    return substr(t, 1, q - 1) + 0
}
function fmtbytes(b) {
    if (b >= 1099511627776) return sprintf("%.2f TB", b / 1099511627776)
    if (b >= 1073741824) return sprintf("%.0f GB", b / 1073741824)
    if (b >= 1048576) return sprintf("%.0f MB", b / 1048576)
    if (b >= 1024) return sprintf("%.0f KB", b / 1024)
    return b " B"
}
function pc(label, val,    color) {
    if (label ~ /^device|^model|^revision|^serial|^capacity$/) color = "1;36"
    else if (label ~ /^partition|^volume/) color = "1;34"
    else if (label ~ /trim|smart|detach|removable|solid|^media type|aes/) color = "1;32"
    else if (label ~ /^protocol|^location/) color = "1;35"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
function load_rich(    cmd, line, _m, _r, _s, _t, _sm, _d, _b) {
    cmd = "cat " richfile " 2>/dev/null"
    _m = ""; _r = ""; _s = ""; _t = ""; _sm = ""; _d = ""; _b = ""
    while ((cmd | getline line) > 0) {
        if (line ~ /^[ \t]*Model:/ && _m == "") { p = index(line, ": "); if (p > 0) _m = substr(line, p + 2) }
        if (line ~ /^[ \t]*Revision:/ && _r == "") { p = index(line, ": "); if (p > 0) _r = substr(line, p + 2) }
        if (line ~ /^[ \t]*Serial Number:/ && _s == "") { p = index(line, ": "); if (p > 0) _s = substr(line, p + 2) }
        if (line ~ /^[ \t]*TRIM Support:/) { p = index(line, ": "); if (p > 0) _t = substr(line, p + 2) }
        if (line ~ /^[ \t]*S.M.A.R.T./) { p = index(line, ": "); if (p > 0) _sm = substr(line, p + 2) }
        if (line ~ /^[ \t]*Detachable Drive:/) { p = index(line, ": "); if (p > 0) _d = substr(line, p + 2) }
        if (line ~ /^[ \t]*BSD Name:/ && _b == "") { p = index(line, ": "); if (p > 0) _b = substr(line, p + 2) }
        if (line ~ /^$/ && _m != "") {
            if (_b != "") {
                rich_rev[_b] = _r; rich_serial[_b] = _s
                rich_trim[_b] = _t; rich_smart[_b] = _sm; rich_detach[_b] = _d
            }
            _m = ""; _r = ""; _s = ""; _t = ""; _sm = ""; _d = ""; _b = ""
        }
    }
    close(cmd)
}

BEGIN { load_rich() }

/^   Device Identifier:/ {
    if (is_whole == "Yes" && apfs_store == "" && dev != "") {
        phys_order[++phys_n] = dev
        phys_media[dev] = media_name
        phys_size[dev] = disksize
        phys_ssd[dev] = ssd
        phys_loc[dev] = location
        phys_pmap[dev] = pmap
        phys_removable[dev] = removable
    }
    dev = getval($0)
    is_whole = ""; apfs_store = ""; media_name = ""
    disksize = 0; ssd = ""; location = ""; pmap = ""; removable = ""
}
/^   Whole:/ { is_whole = getval($0) }
/^   APFS Physical Store:/ { apfs_store = getval($0) }
/^   Device \/ Media Name:/ { media_name = getval($0) }
/^   Disk Size:/ { disksize = extract_bytes(getval($0)) }
/^   Solid State:/ { ssd = getval($0) }
/^   Device Location:/ { location = getval($0) }
/^   Partition Map Type:/ { pmap = getval($0) }
/^   Removable Media:/ { removable = getval($0) }

END {
    if (is_whole == "Yes" && apfs_store == "" && dev != "") {
        phys_order[++phys_n] = dev
        phys_media[dev] = media_name
        phys_size[dev] = disksize
        phys_ssd[dev] = ssd
        phys_loc[dev] = location
        phys_pmap[dev] = pmap
        phys_removable[dev] = removable
    }
    if (phys_n == 0) { if (richfile != "") system("rm -f " richfile); exit 1 }
    for (i = 1; i <= phys_n; i++) {
        d = phys_order[i]
        if (i > 1) printf "\n"
        pc("device", d)
        if (phys_media[d]) pc("model", phys_media[d])
        if (rich_rev[d]) pc("revision", rich_rev[d])
        if (!simple && rich_serial[d]) pc("serial", rich_serial[d])
        pc("capacity", fmtbytes(phys_size[d]))
        dtype = ""
        if (phys_ssd[d] == "Yes") dtype = "SSD"
        else if (phys_ssd[d] == "No") dtype = "HDD"
        if (dtype) pc("media type", dtype)
        if (!simple) {
            if (rich_trim[d]) pc("trim support", rich_trim[d])
            if (rich_smart[d]) pc("SMART status", rich_smart[d])
            if (phys_loc[d]) pc("location", phys_loc[d])
            if (phys_pmap[d]) pc("partition map", phys_pmap[d])
            if (rich_detach[d]) pc("detachable", rich_detach[d])
            if (phys_removable[d]) pc("removable", phys_removable[d])
        }
    }
    if (richfile != "") system("rm -f " richfile)
}