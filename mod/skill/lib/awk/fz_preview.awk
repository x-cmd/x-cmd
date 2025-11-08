BEGIN {
    c_key    = "\033[1;33m"
    c_val    = "\033[0;37m"
    c_reset  = "\033[0m"
}
NR == 1 { for (i=1;i<=NF;i++) header[i]=$i; next }
$1 == id {
    for (i=1;i<=NF;i++) {
        printf "%s%s:%s %s%s\n", c_key, header[i], c_reset, c_val, $i
    }
}