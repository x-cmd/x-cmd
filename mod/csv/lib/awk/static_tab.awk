function static_tab_parse_item(v, w, sep,       item, s, _res){
    if (match( v, "\n" )) v = substr(v, 1, RSTART-1) "…"
    item = wcstruncate(v, w)
    s = static_tab___space_str(w)
    if (v == item)  return wcstruncate(item s, w) sep
    else{
        _res = wcstruncate(item, w-1)
        sub("^" _res, "", item)
        _res = _res "…"
        if (wcswidth(item) == 2) _res = _res " "
        return _res sep
    }
}

function static_tab___output(s){
    printf UI_LINEWRAP_DISABLE > "/dev/stderr"
    print CSV_THEME_UI_COLOR s CSV_THEME_UI_END
    printf UI_LINEWRAP_ENABLE > "/dev/stderr"
}

function static_tab___space_str(w,       s){
    if ( (s = SPACE_STR[ w ]) != "" ) return s
    return SPACE_STR[ w ] = str_rep( " ", w )
}

BEGIN{
    PROPORTION = ENVIRON[ "PROPORTION" ]
    COLUMNS = ENVIRON[ "COLUMNS" ]
    IS_SHOW_COLOR = ENVIRON[ "IS_SHOW_COLOR" ]
    NO_COLOR = ENVIRON[ "NO_COLOR" ]

    if (( IS_SHOW_COLOR != "" ) && ( NO_COLOR != 1 )){
        CSV_THEME_UI_COLOR = CSV_THEME_UI_END = ""
        if ( IS_SHOW_COLOR == "auto" ) {
            CSV_THEME_UI_COLOR = ENVIRON[ "___X_CMD_THEME_COLOR_CODE" ]
            CSV_THEME_UI_COLOR = (CSV_THEME_UI_COLOR) ? "\033[" CSV_THEME_UI_COLOR "m" : "\033[36m"
            CSV_THEME_UI_END = "\033[0m"
        }
    }

    SEP = "   "

    if (PROPORTION != "") IS_STREAM = csv_parse_width(arr, PROPORTION, COLUMNS, ",")
    CUSTOM_LEN = arr[L]
    csv_irecord_init()
    while ( (c = csv_irecord( o )) > 0 ) {
        o[ L L ] = c
        o[ L ] = CSV_IRECORD_CURSOR
        if ( CSV_IRECORD_CURSOR == 1 )  CSV_TOTAL = c
        if ( o[ L L ] != CSV_TOTAL ) {
            CSV_ERROR_ROW = CSV_IRECORD_CURSOR
            exit(1)
        }
        if (IS_STREAM == false) continue
        _return_text = ""
        for (i=1; i<CUSTOM_LEN; ++i)
            _return_text = _return_text static_tab_parse_item( o[ S CSV_IRECORD_CURSOR, i ], arr[ i, "width" ], SEP)
        if (i==CUSTOM_LEN) _return_text = _return_text static_tab_parse_item( o[ S CSV_IRECORD_CURSOR, i ], arr[ i, "width" ])
        static_tab___output( _return_text )
    }
    csv_irecord_fini()
}

END{
    if (IS_STREAM == true) exit(0)

    l = o[ L ]
    c = ( CUSTOM_LEN != "" ) ? CUSTOM_LEN : CSV_TOTAL
    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j){
            if (arr[ j, "CUSTOM_WIDTH" ]) continue
            w = wcswidth( o[ S i, j ] )
            if (arr[ j, "width" ] < w) arr[ j, "width" ] = w
        }
    }

    for (i=1; i<=l; ++i){
        if ( i == CSV_ERROR_ROW ) exit(1)
        _return_text = ""
        for (j=1; j<c; ++j)
            _return_text = _return_text static_tab_parse_item(o[ S i, j ], arr[ j, "width" ], SEP)
        if (j==c) _return_text = _return_text static_tab_parse_item(o[ S i, j ], arr[ j, "width" ])
        static_tab___output( _return_text )
    }
}
