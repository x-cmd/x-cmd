

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
    type = $NF;  gsub( /[\[\]]/, "", type )

    # TODO: Need to handle permanant -> type ? or scope ?

    printf( FMT,    mac, ip, cal_suspicious( ip, mac ),    ifname, scope, type )
}

