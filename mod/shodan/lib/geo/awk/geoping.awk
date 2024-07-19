BEGIN{
    printf("%s,%s,%s,%s,%s,%s \n", \
            "Ip","Is_alive","City/Country","min_rtt/avg_rtt/max_rtt","rtts", "latlon")
}

END{
    len = O[ SUBSEP "\"1\"" L ]
    for(i=1; i<=len; ++i){
        keypath = SUBSEP "\"1\"" SUBSEP "\"" i "\""
        ip       = juq(O[ keypath S "\"ip\"" ])
        alive    = juq(O[ keypath S "\"is_alive\"" ])
        min      = juq(O[ keypath S "\"min_rtt\"" ])
        avg      = juq(O[ keypath S "\"avg_rtt\"" ])
        max      = juq(O[ keypath S "\"max_rtt\"" ])
        latlon   = juq(O[ keypath S "\"from_loc\"" S "\"latlon\"" ])
        city     = trim(juq(O[ keypath S "\"from_loc\"" S "\"city\"" ]))
        country  = juq(O[ keypath S "\"from_loc\"" S "\"country\"" ])
        rtts     = get_geoping_value(O, keypath, i)

        printf("%s,%s,%s/%s,%s/%s/%s,%s,%s\n", \
                ip, alive, city, country , min, avg, max, "\""rtts"\"", "\""latlon"\"" )
    }

    if (ip == "") panic("Not found data [hostname or ip="hostname"]")
}

function get_geoping_value(O, geokp, num,      rtts, rtts_len, j, value ){
    rtts_len = O[ geokp S "\"rtts\"" L ]
    for(j=1; j<=rtts_len; ++j){
        rtts  = O[ geokp S "\"rtts\"" S "\"" j "\""]
        value = value substr(rtts, 1, 4)
        if (j != rtts_len ) value = value ","
    }
    return value
}

function panic( s ){
    printf ("\033[31m%s\033[0m\n", s  ) > "/dev/stderr"
    exit(1)
}

function trim( s ){
    gsub(/[ \t\n]/, "_", s); return s
}

