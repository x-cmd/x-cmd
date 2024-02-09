END{
    printf("%s %s  %s \n", \
                "City/Country","Latlon", "Answer")

    len = O[ SUBSEP "\"1\"" L ]
    for(i=1; i<=len; ++i){
        keypath = SUBSEP "\"1\"" SUBSEP "\"" i "\""
        city     = trim(juq(O[ keypath S "\"from_loc\"" S "\"city\"" ]))
        country  = juq(O[ keypath S "\"from_loc\"" S "\"country\"" ])
        latlon   = juq(O[ keypath S "\"from_loc\"" S "\"latlon\"" ])

        site = city"/"country
        if (city != "") printf("%s %s\t", site, latlon)
        else panic("-E|shodan: Not found data")

        answers_len = O[ keypath S "\"answers\"" L ]
        for(j=1; j<=answers_len; ++j){
            type = juq(O[ keypath S "\"answers\"" S "\""j "\"" S "\"type\"" ])
            value = juq(O[ keypath S "\"answers\""  S "\""j "\"" S "\"value\"" ])
            content = content type"/"value "\t"
        }

        printf("%s\n", content)
        content = ""
    }
}

function trim( s ){
    gsub(/[ \t\n]/, "_", s); return s
}

function panic( s ){
    printf ("\033[31m%s\033[0m\n", s  ) > "/dev/stderr"
    exit(1)
}

