BEGIN{
    split( attr, attr_arr, "," )
    for (a in attr_arr) {
        a = attr_arr[ a ]
        if (split(a, aa, "=") == 2){
            attr_kv[ aa[1] ] = aa[2]
        } else {
            attr_kv[ a ] = a
        }
    }
}

function getval( name ){
    str = $0
    if ( match(str, name "[ ]*:[ ]*[0-9]+") ) {
        str = substr(str, RSTART, RLENGTH)
        match(str, /[0-9]+/)
        return substr(str, RSTART, RLENGTH)
    }
    return "NOT_FOUND"
}

{
    for (k in attr_kv) {
        v = attr_kv[ k ]
        if ( (v = getval( v )) != "NOT_FOUND") {
            print k ": " v
            next
        }
    }
}