# Variables expected: -v tty=
BEGIN { FS = ":" }
{
    n = ++net_n
    names[n] = $1; types[n] = $2; devs[n] = $3
}
END {
    if (net_n == 0) { printf "No saved connections.\n"; exit 0 }
    if (tty) printf "\033[1;33m%-4s %-30s %-15s %s\033[0m\n", "#", "NAME", "TYPE", "DEVICE"
    else printf "%-4s %-30s %-15s %s\n", "#", "NAME", "TYPE", "DEVICE"
    for (i = 1; i <= net_n; i++) {
        if (tty) printf "\033[1;36m%-4d\033[0m %-30s \033[1;34m%-15s\033[0m \033[1;32m%s\033[0m\n", i, names[i], types[i], devs[i]
        else printf "%-4d %-30s %-15s %s\n", i, names[i], types[i], devs[i]
    }
}