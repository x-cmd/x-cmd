{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )

    OSNAME = ENVIRON[ "OSNAME" ]
    shortcut_parse_toarr( o, ARR, OSNAME )
    shortcut_parse_tocsv( ARR )
}

function shortcut_parse_tocsv( arr,         i, l, word, cmd, status, category, platform ){
    l = arr[ L ]
    if ( l > 0 ) {
        print "word,cmd,category,status,platform"
    } else {
        log_error("shortcut", "Not found shortcut data")
        exit(1)
    }

    for (i=1; i<=l; ++i){
        word = arr[ i, "\"word\"" ]
        cmd = arr[ word, "\"cmd\"" ]
        category = arr[ word, "\"category\"" ]
        status = arr[ word, "\"status\"" ]
        platform = arr[ word, "\"platform\"" ]
        print csv_quote_ifmust(word) "," csv_quote_ifmust(cmd) "," csv_quote_ifmust(category) "," csv_quote_ifmust(status) "," csv_quote_ifmust(platform)
    }
}
