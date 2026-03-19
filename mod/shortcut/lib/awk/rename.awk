{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )

    shortcut_rename(o, ENVIRON[ "CUR_PLATFORM" ], ENVIRON[ "field_platform" ], ENVIRON[ "field_oldword" ], ENVIRON[ "field_newword" ])

    l = o[L]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, SUBSEP "\""i"\"")
    ystr(o)
}

function shortcut_rename(o, cur_platform, field_platform, field_oldword, field_newword,           kp, q2_oldword, q2_newword, key, field, i, l, j, jl){
    kp = Q2_1

    if (( field_platform != "" ) && ( field_platform != "all" )) kp = kp SUBSEP jqu("<"field_platform">")

    q2_oldword = jqu(field_oldword)
    q2_newword = jqu(field_newword)
    if (!jdict_has(o, kp, q2_oldword)) {
        log_error("shortcut", "Not found shortcut word '"field_oldword"'")
        exit(1)
    } else if ((jdict_has(o, kp, q2_newword)) || (jdict_has(o, kp SUBSEP jqu("<"cur_platform">"), q2_newword))) {
        log_error("shortcut", "Already exists shortcut word '"field_newword"'")
        exit(1)
    } else if ( ! shortcut_check_wordname(field_newword) ) {
        log_error("shortcut", "The shortcut word '"field_newword"' is invalid")
        exit(1)
    }


    l = o[ kp L ]
    for (i=1; i<=l; ++i){
        key = o[ kp, i ]
        if (( key ~ "^\"<" ) || ( key != q2_oldword )) continue

        o[ kp, i ] = q2_newword
        o[ kp, q2_newword ] = o[ kp, q2_oldword ]
        o[ kp, q2_newword L ] = (jl = o[ kp, q2_oldword L ])
        for (j=1; j<=jl; ++j){
            field = o[ kp, q2_oldword, j ]
            o[ kp, q2_newword, j ] = field
            o[ kp, q2_newword, field ] = o[ kp, q2_oldword, field ]
        }
    }
}
