{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    yml_parse( yml_text, o )
    envy_parse_namelist(NAMELIST, ENVIRON[ "namelist" ])

    if ( (NAMELIST[L] > 0) && (o[L] == 0) ) jlist_put(o, "", "{")

    l = NAMELIST[L]
    for (i=1; i<=l; ++i){
        envy_put(o, NAMELIST[ i, "kp"], NAMELIST[ i, "value" ])
    }

    l = o[L]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, SUBSEP "\""i"\"")
    ystr(o)
}
