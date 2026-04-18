# Variables expected: -v tty=
/[a-z]/ { iface = $1 }
/ESSID/ { if (tty) printf "\033[1;36m%-25s\033[0m: %s\n", "interface", iface; else printf "%-25s: %s\n", "interface", iface }