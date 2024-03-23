
BEGIN {
    STREAM_MODE = 1
    ROW = ENVIRON[ "ROW" ]
    COL = ENVIRON[ "COL" ]
}

# different from seq_init
function handle( astr, obj, idx,    arr, arrl ){
    arrl = split(astr, arr, ":")
    if (arrl == 1)          seq_init_data( obj, idx, arr[1], 1, arr[1] )
    else if (arrl == 2)     seq_init_data( obj, idx, arr[1], "", arr[2] )
    else if (arrl == 3)     seq_init_data( obj, idx, arr[1], arr[2], arr[3] )
}

BEGIN{
    if ( ROW ~ "^-?$" ){
        rowl = 1
        seq_init_data( row, rowl )
    } else {
        rowl = split(ROW, row, ",")
        for (i=1; i<=rowl; ++i){
            handle( row[i], row, i )
            STREAM_MODE = seq_canstream( row[i "S"], row[i "P"], row[i "E"] )
        }
    }
}

BEGIN {
    if ( COL ~ "^-?$" ){
        coll = 0
        seq_init_data( col, coll )
    } else {
        coll = split(COL, col, ",")
        for (i=1; i<=coll; ++i)     handle( col[i], col, i )
    }

}

function handle_column_by_rule( lineno,        c, i, j, _first, _start, _end, _sep, _res ){
    _add_comma = 0
    c = data[ L L ]
    for (i=1; i<=coll; ++i){
        _start   = col[ i "S" ]
        _end     = col[ i "E" ]
        _sep     = col[ i "P" ]
        if (_start < 0 )    _start = c + _start + 1
        if (_end < 0 )      _end = c + _end + 1
        else if (_end > c)  _end = c
        _res = ((_res == "") ? "" : _res ",") csv_dump_row(data, "", lineno, _start, _sep, _end)
    }
    printf( "%s\n", _res )
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

        if (coll == 0)      print csv_dump_row( data, "", lineno, 1, 1, data[ L L ] )
        else                handle_column_by_rule( lineno )
    }
}

BEGIN{
    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0 ) {
        data[ L L ] = c
        data[ L ] = CSV_IRECORD_CURSOR
        if ( CSV_IRECORD_CURSOR == 1 ) CSV_TOTAL = c
        if ( c != CSV_TOTAL ) {
            ERROR_ROW = CSV_IRECORD_CURSOR
            exit(1)
        }
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
        if (row_start < 0 )     row_start = l + row_start + 1
        if (row_end < 0 )       row_end = l + row_end + 1
        else if (row_end > l)   row_end = l

        if (row_sep < 0) {
            for (j=row_start; j>=row_end; j+=row_sep){
                if (coll == 0)      print csv_dump_row( data, "", j, 1, 1, data[ L L ] )
                else                handle_column_by_rule( j )
            }
        } else {
            for (j=row_start; j<=row_end; j+=row_sep){
                if (coll == 0)      print csv_dump_row( data, "", j, 1, 1, data[ L L ] )
                else                handle_column_by_rule( j )
            }
        }
    }
}

