INPUT==1{
    if ($0 == "") next
    _item_arrl = json_split2tokenarr( _item_arr, $0 )
    for (_i=1; _i<=_item_arrl; ++_i) {
        if ( jiter_eqarr_parse( obj, _item_arr[_i], patarrl, patarr ) == false )    continue
        for (i=1; i<=argvl; ++i) {
            val = ""
            if ( obj[ argv[i] ] != "" ) {
                if ( ___X_CMD_JO_QUERY_JSTR=="q0" ) val = jstr0(obj, argv[i])
                else val = jstr1(obj, argv[i])
            }
            handle_output( val, i, argvl )
        }
        exit(0)
    }
}
