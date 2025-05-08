

function output_tsv_header(){
    printf( fmt, \
        "seq",      "name",     "ether",    "ip",           "mask",     \
        "bcast",    "mtu",      "state",    "addr6",        "scope6",    \
        "qdisc",     "group",   "qlen" )
}

function output_tsv(){
    printf( fmt, \
        seq, name, ether,   addr,   mask, \
        bcast, mtu, state,  addr6,  scope6,  \
        qdisc, group, qlen )
}

BEGIN{
    for (i=1; i<=12; ++i) {
        fmt = fmt "%s\t"
    }
    fmt = fmt "%s\n"

    output_tsv_header()
}


END{
    output_tsv()
}

$0~/^[^ \t\v\r]/{
    if (first)  {
        output_tsv()

        addr = bcast = mask = ""
        addr6 = scope6 = ""
        metric = mtu = state = flag = group = master = qlen = ""
        collision = txqueuelen = ""
    }
    first = 1

    seq = $1
    name = $2;          gsub(":", "", name)
    flag = state = $3;  gsub("flags=", "", flag)
    gsub("(^[^<]+<)|(>)", "", state)

    i = 4
    while (i<=NF) {
        if ($i == "mtu") {
            mtu = $(i+1)
        } else if ($i == "qdisc") {
            qdisc = $(i+1)
        } else if ($i == "state") {
            state = $(i+1)
        } else if ($i == "group") {
            group = $(i+1)
        } else if ($i == "master") {
            master = $(i+1)
        } else if ($i == "qlen") {
            qlen = $(i+1)
        }
        i += 2
    }
    next
}

$1=="inet"{
    addr = mask = $2
    gsub("/.+$", "", addr)
    gsub(".+/", "", mask);  mask = "/" mask
    i=3
    while (i<=NF) {
        if ($i == "brd") {
            bcast = $(i+1)
        } else if ($i == "scope") {
            scope = $(i+1)
        } else if ($i == "master") {
            master = $(i+1)
        } else if ($i == "state") {
            state = $(i+1)
        }
        i += 2
    }

    getline
    valid_lft = $2
    preferred_lft = $4
    next
}

$1=="inet6"{
    addr6 = $2
    scope6 = $4

    getline
    valid_lft6 = $2
    preferred_lft6 = $4
    next
}

$1=="link/loopback" {
    ether = "lo"
    next
}

$1=="link/ether"{
    ether = $2
    next
}
