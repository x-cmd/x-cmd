
BEGIN{
    kp = SUBSEP "\"1\""
    jlist_put(o, "", "[")
    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0 ) {
        row = data[ L L ] = c
        col = data[ L ] = CSV_IRECORD_CURSOR
        csv_tojson( o, kp, row, col )
    }
    csv_irecord_fini()
}

END{
    print jstr(o)
}

function csv_tojson(o, kp, row, col,     _kp, i){
    if (col == 1) {
        for (i=1; i<=row; ++i){
            key[i] = data[ SUBSEP col SUBSEP i ]
        }
    } else {
        jlist_put(o, kp, "{")
        _kp = kp SUBSEP "\""col-1"\""
        for (i=1; i<=row; ++i){
            jdict_put(o, _kp, jqu(key[i]), jqu(data[ SUBSEP col SUBSEP i ]) )
        }
    }
}
