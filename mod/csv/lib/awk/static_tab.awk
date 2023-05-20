function printf_item(v, w, sep,       item, s){
    item = wcstruncate(v, w)
    s = return_space_str(w)
    if (v == item) printf("%s%s", wcstruncate(item s, w), sep)
    else printf("%s%s%s", wcstruncate(item, w-1), "…", sep)
}

function return_space_str(w,       s){
    if ( (s = SPACE_STR[ w ]) != "" ) return s
    return SPACE_STR[ w ] = str_rep( " ", w )
}

BEGIN{
    printf UI_LINEWRAP_DISABLE "\r" > "/dev/stderr"
    PROPORTION = ENVIRON[ "PROPORTION" ]
    COLUMNS = ENVIRON[ "COLUMNS" ]
    SEP = "   "

    if (PROPORTION != "") IS_STREAM = csv_parse_width(arr, PROPORTION, COLUMNS, ",")
    CUSTOM_LEN = arr[L]

    csv_irecord_init()
    while ( (c = csv_irecord( o )) > 0 ) {
        o[ L L ] = c
        o[ L ] = CSV_IRECORD_CURSOR

        if (IS_STREAM == false) continue
        for (i=1; i<=CUSTOM_LEN; ++i)
            printf_item( o[ S CSV_IRECORD_CURSOR, i ], arr[ i, "width" ], SEP)
        printf("\n")
    }
    csv_irecord_fini()
}

END{
    if (IS_STREAM == true) {
        printf UI_LINEWRAP_ENABLE "\r" > "/dev/stderr"
        exit 0
    }

    l = o[ L ]
    c = ( CUSTOM_LEN != "" ) ? CUSTOM_LEN : o[ L L ]
    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j){
            if (arr[ j, "CUSTOM_WIDTH" ]) continue
            w = wcswidth( o[ S i, j ] )
            if (arr[ j, "width" ] < w) arr[ j, "width" ] = w
        }
    }

    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j)
            printf_item(o[ S i, j ], arr[ j, "width" ], SEP)
        printf("\n")
    }

    printf UI_LINEWRAP_ENABLE "\r" > "/dev/stderr"
}
