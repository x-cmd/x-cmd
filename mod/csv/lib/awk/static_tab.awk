BEGIN{
    PROPORTION = ENVIRON[ "PROPORTION" ]
    COLUMNS = ENVIRON[ "COLUMNS" ]
    if (PROPORTION != "") l = parse_width_proportion(PROPORTION, COLUMNS, arr)
    SEP = "   "
    csv_irecord_init()
    while ( (c = csv_irecord( o )) > 0 ) {
        o[ L L ] = c
        o[ L ] = CSV_IRECORD_CURSOR

        if (PROPORTION == "") continue
        for (i=1; i<=l; ++i){
            v = o[ S CSV_IRECORD_CURSOR, i ]
            w = arr[ i, "width" ]
            item = wcstruncate(v, w)
            if (v == item) printf("%s%s", wcstruncate(item arr[ i, "space" ], w), SEP )
            else printf("%s%s%s", wcstruncate(item, w-1), "…", SEP)
        }
        printf("\n")
    }
    csv_irecord_fini()
}

END{
    if (PROPORTION != "") exit 0

    l = o[ L ]
    c = o[ L L ]
    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j){
            w = wcswidth( o[ S i, j ] )
            if (arr[ j, "width" ] < w) arr[ j, "width" ] = w
        }
    }

    for (j=1; j<=c; ++j)
        arr[ j, "space" ] = str_rep( " ", arr[ j, "width" ] )


    for (i=1; i<=l; ++i){
        for (j=1; j<=c; ++j)
            printf("%s%s", wcstruncate(o[ S i, j ] arr[ j, "space" ], arr[ j, "width" ]), SEP )
        printf("\n")
    }
}

function parse_width_proportion(str, cols, arr,         i, l){
    l = split(str, arr, ",")
    cols = cols - (l * 3)
    for (i=1; i<=l; ++i){
        w = int(cols * arr[i] / 100)
        arr[ i, "space" ] = str_rep( " ", w )
        arr[ i, "width" ] = w
    }
    return l
}
