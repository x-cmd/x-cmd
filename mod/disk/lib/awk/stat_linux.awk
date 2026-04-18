# Variables expected via -v: tty, format
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
NR == 1 { next }
{
    if ($1 ~ /^(tmpfs|devtmpfs|cgroup|overlay|proc|sys|devpts|binfmt|mqueue|securityfs|debugfs|pstore|efivarfs|bpf)/) next
    if ($1 ~ /^none$/) next

    dev = $1; fs = $2; total = $3; used = $4; avail = $5; pct = $6; mount = $7
    for (i = 8; i <= NF; i++) mount = mount " " $i
    gsub(/%/, "", pct)

    if (dev in seen) {
        seen_mounts[dev] = seen_mounts[dev] ", " mount
        next
    }
    seen[dev] = 1
    seen_mounts[dev] = mount

    n = ++dn
    d_dev[n] = dev; d_fs[n] = fs
    d_total[n] = total * 1024; d_used[n] = used * 1024; d_avail[n] = avail * 1024
    d_pct[n] = pct; d_mount[n] = mount
}
END {
    if (format == "tsv") {
        printf "device\tfs\tmount\ttotal_bytes\tused_bytes\tavail_bytes\tuse_pct\tother_mounts\n"
        for (i = 1; i <= dn; i++) {
            om = ""
            n = split(seen_mounts[d_dev[i]], parts, ", ")
            if (n > 1) {
                for (j = 2; j <= n; j++) {
                    if (om != "") om = om "; "
                    om = om parts[j]
                }
            }
            printf "%s\t%s\t%s\t%d\t%d\t%d\t%s%%\t%s\n", \
                d_dev[i], d_fs[i], d_mount[i], d_total[i], d_used[i], d_avail[i], d_pct[i], om
        }
        exit
    }
    # Table
    if (tty) {
        printf "\033[1;33m%-13s%8s%8s%8s%5s  %-6s%s\033[0m\n", "DEVICE", "TOTAL", "USED", "AVAIL", "USE%", "FS", "MOUNT"
    } else {
        printf "%-13s%8s%8s%8s%5s  %-6s%s\n", "DEVICE", "TOTAL", "USED", "AVAIL", "USE%", "FS", "MOUNT"
    }
    for (i = 1; i <= dn; i++) {
        pval = d_pct[i] + 0
        if (tty) {
            pct_c = pval < 20 ? "1;32" : (pval < 60 ? "1;36" : (pval < 90 ? "1;33" : "1;31"))
            printf "\033[1;36m%-13s\033[0m%8s%8s%8s  \033[%sm%4s%%  \033[0;90m%-6s%s\033[0m\n", \
                trunc(d_dev[i], 12), fmtbytes(d_total[i]), fmtbytes(d_used[i]), fmtbytes(d_avail[i]), pct_c, d_pct[i], d_fs[i], d_mount[i]
        } else {
            printf "%-13s%8s%8s%8s%4s%%  %-6s%s\n", \
                trunc(d_dev[i], 12), fmtbytes(d_total[i]), fmtbytes(d_used[i]), fmtbytes(d_avail[i]), d_pct[i], d_fs[i], d_mount[i]
        }
        n = split(seen_mounts[d_dev[i]], parts, ", ")
        if (n > 1) {
            om = ""
            for (j = 2; j <= n; j++) {
                if (om != "") om = om ", "
                om = om parts[j]
            }
            if (tty) printf "%44s\033[0;90m+ %s\033[0m\n", "", om
            else printf "%44s+ %s\n", "", om
        }
    }
}