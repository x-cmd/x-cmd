

BEGIN{
    args = ENVIRON[ "args" ]
    parse_header_mod_args( args, arr )

    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0) {
        for (i=1; i<=c; ++i){
            v = csv_quote_ifmust(data[ S 1, i ])
            if ( arr[ v, "mod" ] == true ) v = arr[ v, "n_name" ]
            _res = ((_res == "") ? "" : _res "," ) v
        }
        print _res
        break
    }
    csv_irecord_fini()
}

{
    print $0
}

function parse_header_mod_args( str, arr,        a, i, l, v, _id, o_name, _r ){
    l = split(str, a, "\001")
    _r = sprintf( "^((%s)|(%s))=", ___CSV_CELL_PAT_STR_QUOTE, ___CSV_CELL_PAT_ATOM )
    for (i=1; i<=l; ++i){
        v = a[i]
        match( v, _r )
        _id = RLENGTH
        if (_id < 0) continue
        o_name = substr( v, 1, _id-1 )
        arr[ o_name, "mod" ] = true
        arr[ o_name, "n_name"] = substr( v, _id+1 )
    }
}
