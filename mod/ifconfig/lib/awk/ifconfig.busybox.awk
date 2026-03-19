
function output_tsv_header(){
    printf( fmt, \
        "name",     "ether",    "ip",           "mask",         "bcast",    \
        "encap",    "mtu",      "txqueuelen",   "collision",    "state",    \
        "ipv6",     "scope6",   "metric",       "flag"   )
}

function output_tsv(){
    printf( fmt, \
        name, ether, addr, mask, bcast, \
        encap, mtu, txquenlen,  collision, state, \
        addr6, scope6, metric,  flag )
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

($0~/^[^ \t\v\r]/){
    if (first)  {
        output_tsv()

        addr = bcast = mask = ""
        addr6 = scope6 = ""
        metric = mtu = state = flag = ""
        collision = txquelen = ""
    }
    first = 1

    name = $1

    encap = $3;     gsub("encap:", "", encap)

    if ($4 == "Loopback") {
        ether = "lo"
    } else {
        ether = $5
    }

    next
}

($1=="inet"){
    addr = $2;      gsub("addr:", "", addr)
    if ($3 ~ "Bcast:") {
        bcast = $3; gsub("Bcast:", "", bcast)
    }
    mask = $NF;     gsub("Mask:", "", mask)
}

($1=="inet6"){
    addr6 = $3;
    scope6 = $4;    gsub("^[^:]+:", "", scope6)
    next
}

($0 ~ /MTU:/){
    metric = $NF;   gsub("^[^:]+:", "", metric)
    mtu = $(NF-1);  gsub("MTU:", "", mtu)
    $NF = ""
    $(NF-1) = ""
    state = $0;     gsub(/(^[ ]+)|([ ]+)$/, "", state)
    next
}

( $0 ~ /collision/) {
    collision = $1; gsub("^[^: ]+:", "", collision)
    txquenlen = $2; gsub("^[^: ]+:", "", txquenlen)
    next
}

# TODO: handle more ...
