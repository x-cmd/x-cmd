# Variables expected: -v tty=
NR == 1 { next }
{
    n = ++net_n
    nets[n] = $0
}
END {
    for (i = 1; i <= net_n; i++) {
        if (tty) printf "\033[1;36m%-4d\033[0m %s\n", i, nets[i]
        else printf "%-4d %s\n", i, nets[i]
    }
}