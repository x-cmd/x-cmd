BEGIN{
    FS = "\t"
}

BEGIN{
    named_fmt =     "\033[34m%6s\t" "\033[36m%10s  " "\033[2;32m%8s  " "\033[0;36m%s\033[2m:\033[0;35m%s\033[0m  "  "\033[0;2m%s\033[0m\n"

    xcmd_fmt =      "\033[34m%6s\t" "\033[36m%10s  " "\033[2;32m%8s  " "\033[0;7;36m%s\033[2m:\033[0;35m%s\033[0m  " "\033[0;2m%s\033[0m\n"

    unamed_fmt =    "\033[2;34m%6s\t" "\033[36m%10s  " "\033[2;32m%8s  " "\033[0;2;36m%s\033[2m:\033[35m%s\033[0m  " "\033[0;2m%s\033[0m\n"
}

NR>1{
    id          = $1
    id = substr(id, 1, 6)

    repo        = $2
    tag         = $3

    usize       = $4

    vsize       = $5

    gsub("(KB)|(MB)|(GB)|(TB)", " &", vsize)

    createdat   = $6
    createdat   = substr( createdat, 3, 14 )

    createdsince = $7

    if (repo == "<none>") {
        fmt = unamed_fmt
    } else if (repo ~ "(^s/)|(^xal-)|(^xde-)|(^xub-)|(^xar-)|(^xka-)|(^xfe-)|(^xwt-)") {
        fmt = xcmd_fmt
    } else {
        fmt = named_fmt
    }


    printf(fmt,     id, vsize, createdat, repo, tag, createdsince )
}

