
BEGIN{
    printf( "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n", "mac", "ip", "suspicious", "if", "scope", "type" )
    all = (all == "yes") ? 1 : ""

    FMT =   "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s" "\n"
}

BEGIN {

}

function cal_suspicious(ip, mac){
    if ( mac == "-") return
    if ( dup[ip] != "" ) {
        return suspicious = dup[ip]
    } else {
        dup[ip] = mac
        return ""
    }
}


