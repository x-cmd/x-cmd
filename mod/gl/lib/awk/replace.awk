function parse_replace_info(text){
    if ( text ~ "^replace:" ) {
        parse_replace_info_from_list( substr(text, length("replace:")+1) )
    } else {
        jiparse_after_tokenize( _, text); JITER_CURLEN = 0
        parse_replace_info_from_obj(_);          delete _
    }
}

function parse_replace_info_from_list(str,        l, i, a, _id){
    l = split(str, a, ",")
    for (i=1; i<=l; ++i){
        _id = index(a[i], "=")
        REPLACE[ jqu(substr(a[i], 1, _id-1)) ] = jqu(substr(a[i], _id+1 ))
    }
}

function parse_replace_info_from_obj(obj,         kp, l, i, k){
    kp = SUBSEP jqu(1)
    l = obj[kp L]
    for (i=1; i<=l; ++i) {
        k = obj[ kp, i ]
        REPLACE[ k ] = obj[ kp, k ]
    }
}

function replace(s,             r){
    r = REPLACE[s]
    return ( r != "" ) ? r : s
}

function jiparse_and_replace_field_after_tokenize(obj, text){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        item = _arr[i]
        if ( item ~ /^"/) { # "
            if ( JITER_LAST_KP != "") item = replace(item)
            else if (( JITER_LAST_KP == "") && ( JITER_STATE != "{")) item = replace(item)
        }
        jiparse( obj, item )
    }
}