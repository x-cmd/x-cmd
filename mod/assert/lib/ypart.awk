END{
    gsub("^[\n]+", "", ENVIRON["data"])
    gsub("^[\n]+", "", ENVIRON["part"])
    yml_parse( ENVIRON["data"], data )
    yml_parse( ENVIRON["part"], part )
    if (ypart_value(data, part, SUBSEP "\"1\"") == false) exit(1)
}


function ypart_dict(data, part, kp,      _key1, l2,i){
    l2 = part[ kp L ]
    for(i=1; i<=l2; ++i) {
        _key1 = part[ kp , i ]
        if (ypart_value(data, part, kp SUBSEP _key1) == false) return false
    }
    return true
}

function ypart_list(data, part, kp,         i,  l2 ){
    l2 = part[ kp L ]
    for(i=1; i<=l2; ++i) {
        if (ypart_value(data, part, kp SUBSEP "\""i"\"") == false) return false
    }
    return true
}

function ypart_value(data, part, kp,            _key1, _key2){
    _key1 = data[ kp ]
    _key2 = part[ kp ]
    if ( _key1 != _key2 ) return false
    if (_key1 == "{") { if (ypart_dict(data, part, kp) == false ) return false; }
    else if (_key1 == "[") { if (ypart_list(data, part, kp) == false ) return false; }
    return true
}