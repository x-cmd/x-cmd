BEGIN {
    FS = "\t"

    C_RESET = "\033[0m"
    C_ID    = "\033[38;5;236m"
    C_DATE  = "\033[38;5;241m"
    C_COUNT = "\033[38;5;244m"
    C_PATH  = "\033[38;5;135m"
    C_CTX   = "\033[38;5;38m"
    C_MAIN  = "\033[1;37m"

    HOME = ENVIRON["HOME"]
}

{
    id      = $1
    date    = $2
    count   = $3
    ctx     = $4
    display = $5
    path    = $6

    gsub("T", " ", date)
    short_date = substr(date, 6, 11)

    if (path != "") {
        if (index(path, HOME) == 1) {
            path = substr(path, length(HOME) + 1)
            if (substr(path, 1, 1) == "/") path = substr(path, 2)
        }
    }

    printf "%s%s%s ", C_DATE, short_date, C_RESET

    printf "%s%3s%s  ", C_COUNT, count, C_RESET

    if (path != "") {
        printf "%s%-20s%s ", C_PATH, path, C_RESET
    }

    if (ctx != "" && ctx != display) {
        printf "%s%s%s %s-%s ", C_CTX, ctx, C_RESET, C_COUNT, C_RESET
    }

    printf "%s%s%s ", C_MAIN, display, C_RESET

    printf "\t%s%s%s\n", C_ID, id, C_RESET
}