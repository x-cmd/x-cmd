

BEGIN{
    printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", "suspicious", "ip", "mac", "if", "type" )
    all = (all == "yes") ? 1 : ""
}

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

    if ((mac != "-") && ( dup[ip] != "" )) {
        printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", dup[ip], ip, mac, ifname, type )
    } else {
        printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", "", ip, mac, ifname, type )
    }

}

