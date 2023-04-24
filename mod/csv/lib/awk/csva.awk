
BEGIN{
    CSVA_LAST = ""
    CSVA_COMPLETE = true
    CNR = 0
}

function csva_handle( data,     r, b, c, i, _lastcell, _tmp, _tmpl ){
    if (CSVA_COMPLETE == false) data = CSVA_LAST data
    else {
        CNF = 0
        CNR ++
    }

    data = csv_trim(data)
    gsub( CSV_CELL_PAT, "&\n", data )

    _tmpl = split(data, _tmp, ",\n")
    for (i=1; i<_tmpl; ++i) CROW[ ++ CNF ] = _tmp[ i ]

    # Tip: 若最后一个元素是个空值，切分出来只是个空值，不会有\n
    # Tip: 若最后一个元素是完整的（非空值），那必然是加了\n
    # Tip: 若最后一个元素是不完整的，有\n
    # Tip: 所以，需要判断最后一个元素是否是半个quote-string
    _lastcell = _tmp[_tmpl]
    if ( _lastcell !~ "^\"" ___CSV_CELL_PAT_STR_CONTENT "$" ) {
        CROW[ ++ CNF ] = csv_trim(_lastcell)
        return CSVA_COMPLETE = true
    }

    CSVA_LAST = _lastcell
    return CSVA_COMPLETE = false
}

{
    # true means we get complete line
    if ( ! csva_handle( $0 ) ) next
}

function cval( i,   v ){
    v = cget( i )

    if (v ~ "^\"")  return csv_unquote( v )
    else            return v
}

function cget( i ){
    return CROW[ i ]
}
