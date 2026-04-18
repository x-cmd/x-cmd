# Variables expected via -v: tty, format
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
function trunc(s, max,    n) {
    n = length(s)
    if (n <= max) return s
    return substr(s, 1, max - 2) ".."
}

/^   Device Identifier:/ {
    # Store previous entry metadata
    if (dev != "") {
        part_of[dev] = part_whole
        dev_media[dev] = media_name
        dev_size[dev] = disksize
        dev_ssd[dev] = ssd
        dev_loc[dev] = location
        # Real physical disks have no APFS Physical Store
        if (is_whole == "Yes" && apfs_store == "") phys_order[++phys_n] = dev
        # Container disks: map container -> physical via Physical Store
        # APFS Physical Store: disk0s2 -> strip sN -> disk0
        if (apfs_store != "") {
            phys_disk = apfs_store
            gsub(/s[0-9]+$/, "", phys_disk)
            cont_phys[dev] = phys_disk
        }
    }

    # APFS volume with mount point
    if (container != "" && mounted == "Yes") {
        if (!(container in cnt)) cont_order[++cont_n] = container
        n = ++cnt[container]
        c_vol[container, n] = volname
        c_mp[container, n] = mp
        c_fs[container, n] = fs
        c_ctotal[container] = ctotal
        c_cfree[container] = cfree
    } else if (mounted == "Yes" && container == "" && fs != "" && fs != "None") {
        na = ++na_n
        na_dev[na] = dev; na_vol[na] = volname; na_mp[na] = mp
        na_fs[na] = fs; na_size[na] = disksize; na_used[na] = vused
        na_part[na] = part_whole
    }

    # Reset
    dev = getval($0)
    volname = ""; mounted = ""; mp = ""; fs = ""
    container = ""; ctotal = 0; cfree = 0; vused = 0
    disksize = 0; ssd = ""; location = ""; apfs_store = ""
    is_whole = ""; part_whole = ""; media_name = ""
}

/^   Volume Name:/ { volname = getval($0); if (index(volname, "Not applicable") > 0) volname = "" }
/^   Mounted:/ { mounted = getval($0) }
/^   Mount Point:/ { mp = getval($0) }
/^   File System Personality:/ { fs = getval($0) }
/^   Whole:/ { is_whole = getval($0) }
/^   Part of Whole:/ { part_whole = getval($0) }
/^   Device \/ Media Name:/ { media_name = getval($0) }
/^   APFS Container:/ { container = getval($0) }
/^   APFS Physical Store:/ { apfs_store = getval($0) }
/^   Container Total Space:/ { ctotal = extract_bytes(getval($0)) }
/^   Container Free Space:/ { cfree = extract_bytes(getval($0)) }
/^   Volume Used Space:/ { vused = extract_bytes(getval($0)) }
/^   Disk Size:/ { disksize = extract_bytes(getval($0)) }
/^   Solid State:/ { ssd = getval($0) }
/^   Device Location:/ { location = getval($0) }

END {
    # Flush last entry
    if (dev != "") {
        part_of[dev] = part_whole
        dev_media[dev] = media_name
        dev_size[dev] = disksize
        dev_ssd[dev] = ssd
        dev_loc[dev] = location
        if (is_whole == "Yes" && apfs_store == "") phys_order[++phys_n] = dev
        if (apfs_store != "") {
            phys_disk = apfs_store
            gsub(/s[0-9]+$/, "", phys_disk)
            cont_phys[dev] = phys_disk
        }
    }
    if (container != "" && mounted == "Yes") {
        if (!(container in cnt)) cont_order[++cont_n] = container
        n = ++cnt[container]
        c_vol[container, n] = volname
        c_mp[container, n] = mp
        c_fs[container, n] = fs
        c_ctotal[container] = ctotal
        c_cfree[container] = cfree
    } else if (mounted == "Yes" && container == "" && fs != "" && fs != "None") {
        na = ++na_n
        na_dev[na] = dev; na_vol[na] = volname; na_mp[na] = mp
        na_fs[na] = fs; na_size[na] = disksize; na_used[na] = vused
        na_part[na] = part_whole
    }

    # Build physical disk -> containers list (ordered)
    # cont_phys is already populated from APFS Physical Store parsing
    for (ci = 1; ci <= cont_n; ci++) {
        c = cont_order[ci]
        p = cont_phys[c]; if (p == "") p = "other"
        pc_n[p] = ++pc_cnt[p]
        pc_list[p, pc_cnt[p]] = c
    }

    # ── TSV output ──
    if (format == "tsv") {
        printf "physical_disk\tcontainer\tvolume\tmount\ttotal_bytes\tused_bytes\tavail_bytes\tuse_pct\tfs\tother_volumes\n"
        for (ci = 1; ci <= cont_n; ci++) {
            c = cont_order[ci]
            p = cont_phys[c]; if (p == "") p = "unknown"
            best = pick_best(c)
            total = c_ctotal[c]; free = c_cfree[c]; used = total - free
            pct = (total > 0) ? sprintf("%.0f", used / total * 100) : "0"
            om = build_other(c, best)
            printf "%s\t%s\t%s\t%s\t%d\t%d\t%d\t%s%%\t%s\t%s\n", \
                p, c, c_vol[c, best], c_mp[c, best], total, used, free, pct, c_fs[c, best], om
        }
        for (i = 1; i <= na_n; i++) {
            p = na_part[i]; if (p == "") p = "unknown"
            printf "%s\t%s\t%s\t%s\t%d\t%d\t%d\t0%%\t%s\t\n", \
                p, na_dev[i], na_vol[i], na_mp[i], na_size[i], na_used[i], na_size[i] - na_used[i], na_fs[i]
        }
        exit
    }

    # ── Table output (TTY or plain) ──
    for (pi = 1; pi <= phys_n; pi++) {
        p = phys_order[pi]
        if (!(p in pc_cnt)) continue

        # Physical disk header
        model = dev_media[p]
        size_s = fmtbytes(dev_size[p])
        dtype = ""
        if (dev_ssd[p] == "Yes") dtype = "SSD"
        else if (dev_ssd[p] == "No") dtype = "HDD"
        loc = dev_loc[p]

        if (tty) {
            printf "\n\033[1;37m-- %s", p
            if (model != "") printf " | %s", model
            printf " | %s", size_s
            if (dtype != "") printf " | %s", dtype
            if (loc != "") printf " | %s", loc
            printf "\033[0m\n"
        } else {
            printf "\n-- %s", p
            if (model != "") printf " | %s", model
            printf " | %s", size_s
            if (dtype != "") printf " | %s", dtype
            if (loc != "") printf " | %s", loc
            printf "\n"
        }

        # Table header
        if (tty) {
            printf "\033[1;33m%-7s%8s%8s%8s%5s  %-14s%s\033[0m\n", "DEVICE", "TOTAL", "USED", "AVAIL", "USE%", "VOLUME", "MOUNT"
        } else {
            printf "%-7s%8s%8s%8s%5s  %-14s%s\n", "DEVICE", "TOTAL", "USED", "AVAIL", "USE%", "VOLUME", "MOUNT"
        }

        # Container rows
        for (ci = 1; ci <= pc_cnt[p]; ci++) {
            c = pc_list[p, ci]
            best = pick_best(c)
            total = c_ctotal[c]; free = c_cfree[c]; used = total - free
            pct = (total > 0) ? used / total * 100 : 0

            if (tty) {
                pct_c = pct < 20 ? "1;32" : (pct < 60 ? "1;36" : (pct < 90 ? "1;33" : "1;31"))
                printf "\033[1;36m%-7s\033[0m%8s%8s%8s  \033[%sm%4.0f%%  \033[0;90m%-14s%s\033[0m\n", \
                    c, fmtbytes(total), fmtbytes(used), fmtbytes(free), pct_c, pct, c_vol[c, best], c_mp[c, best]
            } else {
                printf "%-7s%8s%8s%8s%4.0f%%  %-14s%s\n", \
                    c, fmtbytes(total), fmtbytes(used), fmtbytes(free), pct, c_vol[c, best], c_mp[c, best]
            }

            # Other volumes on next line
            om = build_other(c, best)
            if (om != "") {
                if (tty) printf "%38s\033[0;90m+ %s\033[0m\n", "", om
                else printf "%38s+ %s\n", "", om
            }
        }
    }

    # Non-APFS volumes
    if (na_n > 0) {
        if (tty) printf "\n\033[1;37m-- Other\033[0m\n"
        else printf "\n-- Other\n"
        if (tty) {
            printf "\033[1;33m%-7s%8s%8s%8s%5s  %-14s%s\033[0m\n", "DEVICE", "TOTAL", "USED", "AVAIL", "USE%", "VOLUME", "MOUNT"
        } else {
            printf "%-7s%8s%8s%8s%5s  %-14s%s\n", "DEVICE", "TOTAL", "USED", "AVAIL", "USE%", "VOLUME", "MOUNT"
        }
        for (i = 1; i <= na_n; i++) {
            used = na_used[i]; size = na_size[i]
            pct = (size > 0) ? used / size * 100 : 0
            if (tty) {
                pct_c = pct < 20 ? "1;32" : (pct < 60 ? "1;36" : (pct < 90 ? "1;33" : "1;31"))
                printf "\033[1;36m%-7s\033[0m%8s%8s%8s  \033[%sm%4.0f%%  \033[0;90m%-14s%s\033[0m\n", \
                    na_dev[i], fmtbytes(size), fmtbytes(used), fmtbytes(size - used), pct_c, pct, na_vol[i], na_mp[i]
            } else {
                printf "%-7s%8s%8s%8s%4.0f%%  %-14s%s\n", \
                    na_dev[i], fmtbytes(size), fmtbytes(used), fmtbytes(size - used), pct, na_vol[i], na_mp[i]
            }
        }
    }
}

function pick_best(c,    best, i, m) {
    best = 1
    for (i = 1; i <= cnt[c]; i++) {
        m = c_mp[c, i]
        if (m == "/") { best = i; break }
        if (m == "/System/Volumes/Data" && c_mp[c, best] != "/") best = i
    }
    return best
}

function build_other(c, best,    om, i, v) {
    om = ""
    for (i = 1; i <= cnt[c]; i++) {
        if (i == best) continue
        v = c_vol[c, i]
        if (om != "") om = om ", "
        if (v != "") om = om v
        else om = om c_mp[c, i]
    }
    return om
}