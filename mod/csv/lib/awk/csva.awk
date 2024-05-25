
BEGIN{
    CSVA_COMPLETE = true
    CNR = 0
}

function csva_handle( data,         c, i, _lastcell, _tmp, _tmpl ){
    if (data == "") return
    if (CSVA_COMPLETE == true) {
        CNF = 0
        CNR ++
    } else {
        if ( ! match(data, CSV_CELL_NEXT_PAT) ) {
            CROW[ CNF ] = CROW[ CNF ] "\n" data
            return CSVA_COMPLETE = false
        } else {
            c = substr(data, RSTART, RLENGTH)
            gsub(",$", "", c)
            CROW[ CNF ] = CROW[ CNF ] "\n" c
            data = substr(data, RLENGTH+1)
        }
    }

    data = csv_trim(data)
    gsub( CSV_CELL_PAT, "\n&", data )

    _tmpl = split(data, _tmp, "(^|,)\n")
    for (i=2; i<=_tmpl; ++i) CROW[ ++ CNF ] = _tmp[ i ]

    # Tip: 判断最后一个元素是否是半个quote-string
    _lastcell = _tmp[ _tmpl ]
    if ( _lastcell !~ "^" ___CSV_CELL_PAT_STR_LEFT_HALF ) {
        if ( match(_lastcell, ",$" ) ) {
            CROW[ CNF ] = substr( _lastcell, 1, RSTART-1 )
            CROW[ ++ CNF ] = ""
        }
        return CSVA_COMPLETE = true
    }

    return CSVA_COMPLETE = false
}

{
    # true means we get complete line
    if ( ! csva_handle( $0 ) ) next
}

function cval( i,   v ){
    return ( ( v = cget( i ) ) ~ "^\"" ) ? csv_unquote( v ) : v
}

function cget( i ){
    return CROW[ i ]
}

function cget_row(     i, _ret){
    for (i=1; i<=CNF; ++i) _ret = ( _ret == "") ? CROW[ i ] : _ret "," CROW[ i ]
    return _ret
}


