# Variables expected: -v tty=
function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
/^[ \t]*Name/ { name = getval($0) }
/^[ \t]*Description/ { desc = getval($0) }
/^[ \t]*Physical address/ { mac = getval($0) }
/^[ \t]*State/ { state = getval($0) }
END {
    if (tty) {
        if (name) printf "\033[1;36m%-25s\033[0m: %s\n", "interface", name
        if (desc) printf "\033[1;34m%-25s\033[0m: %s\n", "description", desc
        if (mac) printf "\033[1;36m%-25s\033[0m: %s\n", "MAC address", mac
        if (state) printf "\033[1;32m%-25s\033[0m: %s\n", "state", state
    } else {
        if (name) printf "%-25s: %s\n", "interface", name
        if (desc) printf "%-25s: %s\n", "description", desc
        if (mac) printf "%-25s: %s\n", "MAC address", mac
        if (state) printf "%-25s: %s\n", "state", state
    }
}