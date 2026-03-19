


{
    if ( $0 == "")              next
    if ( $0 ~ /^[^:]+:/) {
        ifname = $2
        next
    }
    if ( $0 ~ /Internet/)       next
    ip = $1
    mac = $2
    type = $3

    printf( FMT,    mac, ip, cal_suspicious( ip, mac ),    ifname, "", type )
}
