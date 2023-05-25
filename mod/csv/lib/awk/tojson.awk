
BEGIN{
    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0 ) {
        data[ L L ] = c
        row = data[ L ] = CSV_IRECORD_CURSOR
        if (row == 1) continue
        printf "{"
        _ret = ""
        for (i=1; i<=c; ++i){
            _value = (data[ S row, i ] ~ /^(true|false|[0-9]+)$/) ? data[ S row, i ] : jqu(data[ S row, i ])
            _kv = jqu( data[ S 1, i ] ) ": " _value
            _ret = (_ret == "") ? _kv : _ret "," _kv
        }
        print _ret "}"
    }
    csv_irecord_fini()
}

# END{
#     csv_tojson(data, json_o)
#     print jstr(json_o)
# }

function csv_tojson(csv_o, json_o,      _kp, j, i, _key, _value){
    jlist_put(json_o, "", "[")
    row = csv_o[ L ]
    col = csv_o[ L L ]
    for (i=2; i<=row; ++i){
        jlist_put(json_o, S "\"1\"", "{")
        _kp = S "\"1\"" S "\""i-1"\""
        for (j=1; j<=col; ++j){
            _key = jqu(csv_o[ S 1, j ])
            _value = (csv_o[ S i, j ] ~ /^(true|false|[0-9]+)$/) ? csv_o[ S i, j ] : jqu(csv_o[ S i, j ])
            jdict_put(json_o, _kp, _key, _value)
        }
    }
}
