BEGIN{
    FS = "\t"
}

BEGIN{
    running_fmt = "\033[34m%6s\t" "\033[36m%s " "\033[32m%8s " "\033[33m%-10s  " "\033[32m%s " "\033[31m%s\033[0m  "  "\033[0;2m%s\033[0m\n"

    paused_fmt = "\033[34m%6s\t" "\033[36m%s " "\033[33m%8s " "\033[33m%-10s " "\033[32m%s " "\033[31m%s\033[0m  "  "\033[0;2m%s\033[0m\n"

    exited_fmt = "\033[2;34m%6s\t" "\033[36m%s " "\033[37m%8s " "\033[33m%-10s  " "\033[32m%s " "\033[31m%s\033[0m  "  "\033[0;2m%s\033[0m\n"
}

NR>1{
    id = $1
    id = substr(id, 1, 6)
    ts = substr($8, 3, 18)

    img = $4
    if (img ~ /sha256:/) {
        img = substr(img, 8, 6)
    }

    state = $11

    if (state == "running") {
        fmt = running_fmt
    } else if (state == "exited") {
        fmt = exited_fmt
    } else {
        fmt = paused_fmt
    }

    port = $6

    printf(fmt, id, ts, state, $2, img, port, $5 )
}

