
function handle( qpat,      varname, _arr, _arrl, i, _pat, prefix, name ){
    _arrl = split(qpat, _arr, /\./)

    for (i=1; i<=_arrl; ++i) {
        if (i == 1) name = _arr[i]
        else name = name "_"  _arr[i]
        _pat = (_pat == "") ? jqu(_arr[i]) : ( _pat SUBSEP jqu(_arr[i]))
    }
    varname = name
    gsub("\\.|\\-", "_", varname)
    prefix = jqu(PKG_NAME) SUBSEP _pat

    if ( "{" != table[ prefix ] ) print varname "=" table_eval(table, PKG_NAME, table[ prefix ])

}

END {
    if (PANIC_EXIT != 0) exit( PANIC_EXIT )
    query_arrl = split(QUERY, query_arr, ",")
    for (i=1; i<=query_arrl; ++i) {
        handle( query_arr[ i ] )
    }
}
