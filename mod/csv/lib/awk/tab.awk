
BEGIN {
    MAX_INT = 4294967295
    STREAM_MODE = 1
    SEP1=","
    SEP2="\n"
    ROW = ENVIRON[ "ROW" ]
    COL = ENVIRON[ "COL" ]
}

function tab_set_sep( obj, idx, start, end, sep ){
    obj[ idx "S" ] = start = ( start != "") ? start : 1
    obj[ idx "E" ] = end = ( end != "" ) ? end : MAX_INT
    obj[ idx "P" ] = ( sep != "" ) ? sep : ( ((start > end) && ( end > 0 )) ? -1 : 1 )
}

function handle( astr, obj, idx,    arr, arrl ){
    arrl = split(astr, arr, ":")
    if (arrl == 1)          tab_set_sep( obj, idx, arr[1], arr[1], 1 )
    else if (arrl == 2)     tab_set_sep( obj, idx, arr[1], arr[2] )
    else if (arrl == 3)     tab_set_sep( obj, idx, arr[1], arr[3], arr[2] )
}

BEGIN{
    if ( ROW ~ "^-?$" ){
        rowl = 1
        tab_set_sep( row, rowl )
    } else {
        rowl = split(ROW, row, ",")
        for (i=1; i<=rowl; ++i){
            handle( row[i], row, i )
            if ( (row[i "S"] > 0 ) && (row[i "S"] < row[i-1 "E"]) ) STREAM_MODE = 0
            else if ( (row[i "E"] != "") && (row[i "E"] < 0) )  STREAM_MODE = 0
            else if ( (row[i "P"] != "") && (row[i "P"] < 0) )  STREAM_MODE = 0
        }
    }
}

BEGIN {
    if ( COL ~ "^-?$" ){
        coll = 0
        tab_set_sep( col, coll )
    } else {
        coll = split(COL, col, ",")
        for (i=1; i<=coll; ++i)     handle( col[i], col, i )
    }

}

function handle_column_by_rule( lineno,        c, i, j, _first, _start, _end, _sep ){
    _add_comma = 0
    c = data[ L L ]
    for (i=1; i<=coll; ++i){
        _start   = col[ i "S" ]
        _end     = col[ i "E" ]
        _sep     = col[ i "P" ]
        if (_end < 0 ) _end = c + _end + 1
        if (_start < 0 ) _start = c + _start + 1
        for (j=_start; (((_sep < 0) && (_start > _end)) ? j>=_end : j<=_end ) && j<=c; j+=_sep){
            if (_add_comma == 0){
                _add_comma=1;       printf("%s", csv_quote_ifmust(data[ S lineno, j ]))
            } else                  printf("%s%s", SEP1, csv_quote_ifmust(data[ S lineno, j ]))
        }
    }
    printf( SEP2 )
}

function handle_row_by_rule( lineno,      tmp ){
    for (i=1; i<=rowl; ++i){               # Iterate row rule
        row_start   = row[ i "S" ]
        row_end     = row[ i "E" ]
        row_sep     = row[ i "P" ]
        if (row_start > row_end){
            tmp = row_start
            row_start = row_end
            row_end = tmp
        }
        if ( (lineno < row_start) || (lineno > row_end) )  continue
        if ( (row_sep != 1) &&  ( (lineno - row_start) % row_sep != 0 ) )   continue

        if (coll == 0)      print csv_dump_row( data, "", lineno )
        else                handle_column_by_rule( lineno )
    }
}

BEGIN{
    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0 ) {
        data[ L L ] = c
        data[ L ] = CSV_IRECORD_CURSOR
        if (STREAM_MODE == 0)   continue
        else                    handle_row_by_rule( CSV_IRECORD_CURSOR )
    }
    csv_irecord_fini()
}

END{
    if (STREAM_MODE == 1) exit(0)

    l = data[ L ]
    for (i=1; i<=rowl; ++i){
        row_start   = row[ i "S" ]
        row_end     = row[ i "E" ]
        row_sep     = row[ i "P" ]
        if (row_end < 0 ) row_end = l + row_end + 1
        for (j=row_start; (((row_sep < 0) && (row_start > row_end)) ? j>=row_end : j<=row_end ) && j<=l; j+=row_sep){
            if (coll == 0)      print csv_dump_row( data, "", j )
            else                handle_column_by_rule( j )
        }
    }
}

