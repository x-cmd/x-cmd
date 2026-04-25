function pc(label, val) {
    if (tty) printf "\033[1;32m%-25s\033[0m: %s\n", label, val
    else printf "%-25s: %s\n", label, val
}

NR == 1 {
    u = $2 + 0
    n = $3 + 0
    s = $4 + 0
    i = $5 + 0
    w = $6 + 0
    total = u + n + s + i + w
    if (total > 0) {
        pc("cpu user",   sprintf("%.1f%%", u / total * 100))
        pc("cpu nice",   sprintf("%.1f%%", n / total * 100))
        pc("cpu system", sprintf("%.1f%%", s / total * 100))
        pc("cpu idle",   sprintf("%.1f%%", i / total * 100))
        pc("cpu iowait", sprintf("%.1f%%", w / total * 100))
    }
}