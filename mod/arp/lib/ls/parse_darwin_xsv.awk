

BEGIN{
    printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", "suspicious", "ip", "mac", "if", "scope" )
    all = (all == "yes") ? 1 : ""
}

{
    ip = $2
    gsub("[(]|[)]", "", ip)
    mac = $4
    if (mac == "(incomplete)") {
        if (! all)  next
        else        mac = "-"
    }

    ifname = $6
    scope = $7

    if ((mac != "-") && ( dup[ip] != "" )) {
        printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", dup[ip], ip, mac, ifname, scope )
    } else {
        printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", "", ip, mac, ifname, scope )
    }

}

