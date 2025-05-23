
function parse_second_json( o, arr,         i, l ){
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        if (parse_second_json_has_kv( o, jqu(CHECK_PARAM), arr[ i, "name" ] ) > 0) continue
        print data_qu1(arr[ i, "name" ])
        print data_qu1(arr[ i, "ret" ])
    }
}
