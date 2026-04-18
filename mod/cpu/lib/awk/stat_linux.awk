function pc(label, val) {
    if (tty) printf "\033[1;32m%-25s\033[0m: %s\n", label, val
    else printf "%-25s: %s\n", label, val
}
NR == 1 {
    user   = $2 + 0
    nice   = $3 + 0
    system = $4 + 0
    idle   = $5 + 0
    iowait = $6 + 0
    total  = user + nice + system + idle + iowait
    if (total > 0) {
        pc("cpu user",   sprintf("%.1f%%", user / total * 100))
        pc("cpu nice",   sprintf("%.1f%%", nice / total * 100))
        pc("cpu system", sprintf("%.1f%%", system / total * 100))
        pc("cpu idle",   sprintf("%.1f%%", idle / total * 100))
        pc("cpu iowait", sprintf("%.1f%%", iowait / total * 100))
    }
}
