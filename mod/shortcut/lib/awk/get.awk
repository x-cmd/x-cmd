{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )

    shortcut_parse_toarr( o, ARR, ENVIRON[ "GET_CURPLATFORM" ] )
    shortcut_parse_toget( ARR, ENVIRON[ "GET_VAL" ], ENVIRON[ "GET_BYTYPE" ], ENVIRON[ "GET_FORMAT" ] )
}

function shortcut_parse_toget( arr, val, bytype, format,           i, l, word, category, cmd, x_cmd, hasget) {
    if (val == "") exit(1)
    l = arr[ L ]
    hasget = 0
    for (i=1; i<=l; ++i){
        word = arr[ i, "\"word\"" ]
        if (! arr[ word, "\"check\"" ]) continue
        category = arr[ word, "\"category\"" ]
        cmd = arr[ word, "\"cmd\"" ]
        x_cmd = arr[ word, "\"x-cmd\"" ]


        if (( bytype == "word" ) && ( word == val )) {
            shortcut_parse_toget___stdout( arr, word, format )
            hasget = 1
        } else if (( bytype == "category" ) && ( category == val )) {
            shortcut_parse_toget___stdout( arr, word, format )
            hasget = 1
        } else if ( ( bytype == "cmd" ) && ( cmd == val ) ) {
            shortcut_parse_toget___stdout( arr, word, format )
            hasget = 1
        } else if ( ( bytype == "x-cmd" ) && ( x_cmd == val ) ) {
            shortcut_parse_toget___stdout( arr, word, format )
            hasget = 1
        }
    }

    if ( hasget == 0 ) exit(1)
}

function shortcut_parse_toget___stdout( arr, word, format,         cmd, advise, status, category, platform ) {
    cmd = arr[ word, "\"cmd\"" ]
    advise = arr[ word, "\"advise\"" ]
    status = arr[ word, "\"status\"" ]
    category = arr[ word, "\"category\"" ]
    platform = arr[ word, "\"platform\"" ]

    if ( format == "human" ) {
        printf( "word: %s\ncmd: %s\nstatus: %s\ncategory: %s\nplatform: %s\nadvise: %s\n", word, cmd, status, category, platform, advise )
    } else if ( format == "simple" ) {
        printf( "%s\n%s\n%s\n%s\n%s\n%s\n", word, cmd, status, category, platform, advise )
    }
}