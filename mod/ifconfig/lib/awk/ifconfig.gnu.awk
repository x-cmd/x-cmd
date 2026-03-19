

function output_tsv_header(){
    printf( fmt, \
        "name",     "ether",    "ip",           "mask",         "bcast",    \
        "encap",    "mtu",      "txqueuelen",   "collision",    "state",    \
        "ipv6",     "scope6",   "metric",       "flag"   )
}

function output_tsv(){
    printf( fmt, \
        name, ether, addr, mask, bcast, \
        encap, mtu, txqueuelen,  collision, state, \
        addr6, scope6, metric,  flag )
}

BEGIN{
    for (i=1; i<=13; ++i) {
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
        metric = mtu = state = flag = ""
        collision = txqueuelen = ""
    }
    first = 1

    name = $1;          gsub(":", "", name)
    flag = state = $2;  gsub("flags=", "", flag)
    gsub("(^[^<]+<)|(>)", "", state)
    mtu = $4

    next
}

$1=="inet"{
    addr = $2
    mask = $4
    bcast = $6
    next
}

$1=="inet6"{
    addr6 = $2
    prefixlen = $4
    scope6 = $6
    next
}

$1=="ether" {
    ether = $2
    txqueuelen = $4
    encap = $5;       gsub("[)(]", "", encap)
}

$1=="loop"{
    ether = "lo"
    txqueuelen = $3
    encap = "lo"
}

# $1~/^(UP|RX|TX)$/{
#     if ($0 ~ "RX bytes"){
#         gsub(/bytes:/, "", $2)
#         prop[ "rx", "bytes" ] = $2
#         gsub(/bytes:/, "", $6)
#         prop[ "tx", "bytes" ] = $6
#         next
#     }

#     $1 = lower($1)
#     state = ""
#     for (i=1; i<=NF; i++) {
#         if ($i !~ /:/) {
#             state = state $i " "
#             continue
#         }

#         prop[ $1, "state" ] = state

#         for (j=i; j<=NF; j++) {
#             split($j, a, ":")
#             prop[ $1, lower(a[1]) ] = a[2]
#             # mtu, metric
#         }
#         break
#     }
#     next
# }
