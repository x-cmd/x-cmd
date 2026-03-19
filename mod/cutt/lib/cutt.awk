
BEGIN {
    MAX_INT = 4294967295
    STREAM_MODE = 1

    TAB_SEP1 = SEP1 = "    "
    TAB_SEP2 = SEP2 = "\n"
}

# TODO: seq_init_data
function tab_set_sep( obj, idx, start, end, sep ){
    obj[ idx "S" ] = start = ( start != "") ? start : 1
    obj[ idx "E" ] = end = ( end != "" ) ? end : MAX_INT
    obj[ idx "P" ] = ( sep != "" ) ? sep : ( ((start > end) && ( end > 0 )) ? -1 : 1 )
}

# TODO: seq_init
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
            # TODO: There should be no empty for row[ "S" ] and  row[ "P" ]
            # STREAM_MODE = seq_canstream( row[i "S"], row[i "E"], row[i "P"] )
            if ( (row[i "E"] != "") && (row[i "E"] < 0) )  STREAM_MODE = 0
            if ( (row[i "P"] != "") && (row[i "P"] < 0) )  STREAM_MODE = 0
        }
    }
}

function is_empty_string(s ){
    return s ~ /^[ \t\r\n]+$/
}

BEGIN {
    if ( COL ~ "^-?$" ){
        coll = 0
        tab_set_sep( col, coll )
    } else {
        gsub( "^[, \t]+", "", COL )
        gsub( "[, \t]+$", "", COL )
        coll = split(COL, col, ",")
        for (i=1; i<=coll; ++i) {
            handle( col[i], col, i )
        }
    }

}

function handle_column_by_rule(linedata,        i, j, _first, _start, _end, _sep ){
    _add_comma = 0
    $0 = linedata
    for (i=1; i<=coll; ++i){
        _start   = col[ i "S" ]
        _end     = col[ i "E" ]
        _sep     = col[ i "P" ]

        if (_start < 0) _start  = NF + _start + 1
        if (_end < 0 )  _end    = NF + _end + 1

        # TODO:
        # if ((_sep < 0) && (_start > _end))
        for (j=_start; (((_sep < 0) && (_start > _end)) ? j>=_end : j<=_end ) && j<=NF; j+=_sep){
            if (_add_comma == 0){
                _add_comma=1;       printf("%s", $j)
            } else                  printf("%s%s", SEP1, $j)
        }
    }
    printf( SEP2 )
}

function handle_row_by_rule( lineno, linedata,       tmp ){
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

        if (coll == 0)      print linedata
        else                handle_column_by_rule(linedata)
    }
}

BEGIN {
    getline

    if ( (fieldsep == "auto")) {
        if ($0 ~ /\t/)  {
            FS  = OFS = "\t"
        }
    } else if (fieldsep != "") {
        FS =    OFS  = fieldsep
    }

    if (STREAM_MODE == 0)   data[ NR ] = $0
    else                    handle_row_by_rule( NR, $0 )
}

{
    if (STREAM_MODE == 0)   data[ NR ] = $0
    else                    handle_row_by_rule( NR, $0 )
}

END{
    if (STREAM_MODE == 1) exit(0)

    for (i=1; i<=rowl; ++i)  {
        if ( (row_start = row[ i "S" ]) < 0 )    row[ i "S" ] = row_start   + NR + 1
        if ( (row_end   = row[ i "E" ]) < 0 )    row[ i "E" ] = row_end     + NR + 1
    }

    # TODO:
    # if ((_sep < 0) && (_start > _end))

    # for (j=1; j<=NR; ++j) handle_row_by_rule( j, data[ j ] )
    if ( (row[i "P"] > 0) || (row_end < 0) ) for (j=1; j<=NR; ++j) handle_row_by_rule( j, data[ j ] )
    else                  for (j=NR; j>=1; --j) handle_row_by_rule( j, data[ j ] )
}
