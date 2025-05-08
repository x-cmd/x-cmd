{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )
    CUR_PLATFORM = ENVIRON[ "CUR_PLATFORM" ]

    shortcut_parse_toarr( o, ARR, CUR_PLATFORM )

    shortcut_set(o, ARR, ENVIRON[ "field_word" ], ENVIRON[ "field_cmd" ], ENVIRON[ "field_xcmd" ], ENVIRON[ "field_advise" ], ENVIRON[ "field_category" ], ENVIRON[ "field_platform" ], ENVIRON[ "field_status" ])

    l = o[L]
    for (i=1; i<=l; ++i) yml_parse_trim_value(o, SUBSEP "\""i"\"")
    ystr(o)
}

