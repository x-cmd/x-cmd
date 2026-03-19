{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )
    shortcut_unset(o, ENVIRON[ "field_str" ], ENVIRON[ "field_platform" ], ENVIRON[ "field_bytype" ])


    l = o[L]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, SUBSEP "\""i"\"")
    ystr(o)
}

function shortcut_unset(o, field_str, field_platform, field_bytype,          kp){
    kp = Q2_1
    if (( field_platform != "" ) && ( field_platform != "all" )) kp = kp SUBSEP jqu("<"field_platform">")

    if ( field_bytype == "word" ) {
        if (jdict_has(o, kp, jqu(field_str))){
            log_info("shortcut", "Unset shortcut word '"field_str"'")
            jdict_rm(o, kp, jqu(field_str))
        }
    } else if ( field_bytype != "" ){
        shortcut_unset_bytype(o, kp, field_bytype, field_str)
    }
}


function shortcut_unset_bytype(o, kp, bytype, str,           i, l, k, typestr){
    l = o[ kp L ]
    for (i=1; i<=l; ++i){
        k = o[ kp, i ]
        typestr = o[ kp, k, jqu(bytype) ]
        if ( typestr == "" ) continue
        if ( typestr ~ "^\"" ) typestr = juq( typestr)
        if ( typestr == str ) {
            log_info("shortcut", "Unset shortcut word " k)
            jdict_rm(o, kp, k)
        }
    }
}