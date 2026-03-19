function handle( qpat,  _arr, _arrl, i, _pat ){
    _arrl = split(qpat, _arr, /\./)
    for (i=1; i<=_arrl; ++i) {
        _pat = (_pat == "") ? jqu(_arr[i]) : ( _pat SUBSEP jqu(_arr[i]))
    }

    return _pat
}

END {
    prefix = jqu(PKG_NAME) SUBSEP handle( EXPR )

    if( ( k = table[ prefix ] ) != "{") {
        if( k != "" ) print juq(k)
    }

    if( table[ prefix ] == "[") {
        l = table[ prefix L ]
        for (i=1; i<=l; ++i) {
            k = table[ prefix, "\""i"\"" ]
            if( table[ prefix, "\""i"\"" ] != "" ) print juq(k)
        }
    }
}
