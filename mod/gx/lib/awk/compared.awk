BEGIN{
    Q2_1 = SUBSEP "\"1\""
    IS_SECOND_JSON = false
    RET_FIELD = ENVIRON[ "RET_FIELD" ]
    CHECK_PARAM = ENVIRON[ "CHECK_PARAM" ]
}
{
    parse_data($0, OBJ_STANDARD, OBJ_2)
}
END{
    parse_standard_json( OBJ_STANDARD, ARR )
    parse_second_json( OBJ_2, ARR )
}

function parse_data( item, obj_1, obj_2,            _arr, _arrl, i){
    if (item == "") return
    _arrl = json_split2tokenarr( _arr, item )
    for (i=1; i<=_arrl; ++i) {
        if (IS_SECOND_JSON == true) jiparse( obj_2, _arr[i] )
        else {
            jiparse( obj_1, _arr[i] )
            if ( JITER_LEVEL != 0 ) continue
            IS_SECOND_JSON = true
            JITER_CURLEN = 0
        }
    }
}

function parse_standard_json( o, arr,        kp, i, l, _kp, v ){
    kp = Q2_1
    arr[ L ] = l = o[ kp L ]
    for (i=1; i<=l; ++i){
        _kp = kp SUBSEP "\""i"\""
        arr[ i, "release_name" ] = o[ _kp, jqu("name") ]
        arr[ i, "name" ] = o[ _kp, jqu(CHECK_PARAM) ]
        arr[ i, "ret" ] = o[ _kp, jqu(RET_FIELD) ]
    }
}

function parse_second_json_has_kv( o, key, val,         kp, i, l, _second_release_id ) {
    kp = Q2_1
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        if ( o[ kp, "\""i"\"", key ] == val ) {
            _second_release_id = o[ kp, "\""i"\"", jqu("id") ]
            return ( _second_release_id != "" ) ? _second_release_id : true
        }
    }
    return false
}

function data_qu1( v ){
    if ( v ~ "^\"" ) v = juq(v)
    return v
}
