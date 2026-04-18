# variables: tty
function pc(label, val,    color) {
    if (label ~ /^refresh rate|^online|^ambient/) color = "1;33"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
/_spdisplays_resolution/ {
    n = split($0, a, "@")
    if (n > 1) { gsub(/[" \t,]/, "", a[2]); pc("refresh rate", a[2]) }
}
/spdisplays_online/        { gsub(/spdisplays_/, "", $0); gsub(/[" \t]/, "", $0); if (index($0, "=yes")) pc("online", "yes") }
/spdisplays_ambient_brightness/ { gsub(/spdisplays_/, "", $0); gsub(/[" \t]/, "", $0); if (index($0, "=yes")) pc("ambient brightness", "yes") }