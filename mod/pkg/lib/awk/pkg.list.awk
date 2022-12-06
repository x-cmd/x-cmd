
function handle( qpat,  _arr, _arrl, i, _pat ){
    _arrl = split(qpat, _arr, /\./)
    for (i=1; i<=_arrl; ++i) {
        _pat = (_pat == "") ? jqu(_arr[i]) : ( _pat SUBSEP jqu(_arr[i]))
    }

    return _pat
}

END {
    prefix = jqu(PKG_NAME) SUBSEP handle( EXPR )
    if ( "{" != table[ prefix ] ) {
        print table_eval(table, PKG_NAME, table[ prefix ])
    } else {
        l = table[ prefix L ]
        for (i=1; i<=l; ++i) {
            _k = table[ prefix, i ]
            print table_eval(table, PKG_NAME, table[ prefix, _k ] )
        }
    }
}
