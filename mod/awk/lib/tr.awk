

# RFC4648
function get_base32( s ){
    if ( (l = BASE32[ L ]) != 0 ) {
        return BASE32
    }

    s = "ABCDEFGHIJHKLMNOPQRSTUVWXYZ234567"
    BASE32[ L ] = split(s, BASE32)
}

function get_base32hex( s ){
    if ( (l = BASE32[ L ]) != 0 ) {
        return BASE32
    }

    s = "0123456789ABCDEFGHIJKLMNOPQRSTUV"
    BASE32[ L ] = split(s, BASE32)
}


function tr( table, src ){
    return 0
}

function tr_func( table ){
    return 0
}
