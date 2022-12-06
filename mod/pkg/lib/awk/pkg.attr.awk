
function handle( qpat,      varname, _arr, _arrl, i, _pat ){
    varname = qpat

    _arrl = split(qpat, _arr, /\./)
    for (i=1; i<=_arrl; ++i) {
        _pat = (_pat == "") ? jqu(_arr[i]) : ( _pat SUBSEP jqu(_arr[i]))
    }

    gsub("\\.", "_", varname)
    print varname "=" shqu1( juq( table_attr( table, PKG_NAME, _pat )  ) )
}

END {
    query_arrl = split(QUERY, query_arr, ",")
    for (i=1; i<=query_arrl; ++i) {
        handle( query_arr[ i ] )
    }
}
