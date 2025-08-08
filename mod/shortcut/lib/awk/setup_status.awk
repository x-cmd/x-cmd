{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )

    shortcut_parse_namelist(NAMEARR, ENVIRON[ "STATUS_SETUP_NAMELIST" ])
    shortcut_setup_status( o, Q2_1, NAMEARR, ENVIRON[ "STATUS_VAL" ], ENVIRON[ "STATUS_SETUP_BYTYPE" ], ENVIRON[ "STATUS_SETUP_PLATFORM" ] )

    l = o[L]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, SUBSEP "\""i"\"")
    # ystr(o)

    print sh_varset_val("data", jstr(o))
    print sh_varset_val("change_log", CHANGE_LOG)

}

function shortcut_setup_status( o, kp, namearr, statusval, bytype, platform,          i, l, k ){
    if ((platform != "") && (platform != "all")) kp = kp SUBSEP jqu("<"platform">")
    l = o[ kp L ]
    for (i=1; i<=l; ++i){
        k = o[ kp, i ]
        if (k ~ "^\"<") continue
        if (bytype == "word") {
            if ( ! namearr[ juq( k ) ] )    continue
        } else if (bytype == "x-cmd") {
            if ( ! namearr[ juq( o[ kp, k, "\"x-cmd\"" ] ) ] )  continue
        } else if (bytype == "category") {
            if ( ! namearr[ juq( o[ kp, k, "\"category\"" ] ) ] )  continue
        } else if (bytype == "cmd") {
            if ( ! namearr[ juq( o[ kp, k, "\"cmd\"" ] ) ] )    continue
        }

        shortcut_setup_status_item(o, kp SUBSEP k, statusval)
    }
}

function shortcut_setup_status_item(o, kp, statusval){
    q2_status = "\"status\""

    if ( statusval != "enable" ) statusval = ( statusval ~ "^\"" ) ? statusval : jqu( statusval )
    if ( ! jdict_has(o, kp, q2_status) ) jdict_put(o, kp, q2_status, statusval)
    else o[ kp, q2_status ] = statusval

    shortcut_record_word_change(o, kp)
}

function shortcut_record_word_change(o, kp,         word){
    gsub( ".*" SUBSEP, "", kp)
    word = "`" juq(kp) "`"
    CHANGE_LOG = ( CHANGE_LOG != "" ) ? CHANGE_LOG ", " word : word
}
