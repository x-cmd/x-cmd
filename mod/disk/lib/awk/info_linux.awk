# Variables expected via -v: tty
NR == 1 { next }
{
    name = $1; size = $2; model = $3; rota = $4
    if (tty) {
        printf "\033[1;36m%-25s\033[0m: %s\n", "device", "/dev/" name
        if (model) printf "\033[1;36m%-25s\033[0m: %s\n", "model", model
        printf "\033[1;32m%-25s\033[0m: %s\n", "capacity", size
        printf "\033[1;32m%-25s\033[0m: %s\n", "media type", (rota == "0" ? "SSD" : "HDD")
    } else {
        printf "%-25s: %s\n", "device", "/dev/" name
        if (model) printf "%-25s: %s\n", "model", model
        printf "%-25s: %s\n", "capacity", size
        printf "%-25s: %s\n", "media type", (rota == "0" ? "SSD" : "HDD")
    }
    printf "\n"
}