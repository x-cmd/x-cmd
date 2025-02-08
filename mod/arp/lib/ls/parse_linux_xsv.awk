

{
    ip = $2
    gsub("[(]|[)]", "", ip)
    mac = $4
    if (mac == "<incomplete>") {
        if (! all)  next
        else        mac = "-"
    }

    ifname = $NF

    printf( FMT,    mac, ip, cal_suspicious( ip, mac ),    ifname, scope, "" )
}

