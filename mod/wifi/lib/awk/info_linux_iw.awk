# Variables expected: -v tty=
/^[ \t]*type/ { if (tty) printf "\033[1;34m%-25s\033[0m: %s\n", "type", $2; else printf "%-25s: %s\n", "type", $2 }
/^[ \t]*wiphy/ { if (tty) printf "\033[1;32m%-25s\033[0m: %s\n", "wiphy", $2; else printf "%-25s: %s\n", "wiphy", $2 }
/^[ \t]*txpower/ { if (tty) printf "\033[1;35m%-25s\033[0m: %s\n", "tx power", $2 " " $3; else printf "%-25s: %s\n", "tx power", $2 " " $3 }