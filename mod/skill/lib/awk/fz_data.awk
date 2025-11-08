BEGIN {
    color = "\033[1;32m"
    reset = "\033[0m"
}
NR > 1 {
    printf "%s%s%s", color, $1, reset
    for (i = 2; i <= NF; i++) {
        printf "\t%s", $i
    }
    print ""
}
