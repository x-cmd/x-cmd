BEGIN{
    print "["
    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0 ) {
        data[ L L ] = c
        row = data[ L ] = CSV_IRECORD_CURSOR
        if (row == 1) continue
        printf ( (row != 2) ? ",\n{" : "{" )
        _ret = ""
        for (i=1; i<=c; ++i){
            _value = (data[ S row, i ] ~ "^" RE_NUM "$|^(true|false|null)$") ? data[ S row, i ] : jqu(data[ S row, i ])
            _kv = jqu( data[ S 1, i ] ) ": " _value
            _ret = (_ret == "") ? _kv : _ret ", " _kv
        }
        printf ( "%s", _ret "}" )
    }
    csv_irecord_fini()
    printf("\n%s\n", "]")
}
