
function parse_second_json( o, arr,         i, l, _second_release_id ){
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        print data_qu1(arr[ i, "release_name" ])
        print data_qu1(arr[ i, "name" ])
        print arr[ i, "ret" ]

        _second_release_id = parse_second_json_has_kv( o, jqu(CHECK_PARAM), arr[ i, "name" ] )
        print ( _second_release_id > 0 ) ? "true" : "false"
        print _second_release_id
    }
}
