

function cres_finishReason( o, prefix ){
    return o[ prefix S "\"finishReason\"" ]
}


function cres_index( o, prefix ){
    return o[ prefix S "\"index\"" ]
}

function cres_role( o, prefix ){
    return o[ prefix S "\"reply\"" S "\"role\"" ]
}

function cres_text( o, prefix ){
    return o[ prefix S "\"reply\"" S "\"parts\"" S "\"1\"" S "\"text\"" ]
}

function cres_dump( o, _kp ){
    return jstr(o, _kp )
}


function cres_load( o,  jsonstr,      _arrl, _arr, i ){
    _arrl = json_split2tokenarr( _arr, jsonstr )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if ( JITER_LEVEL != 0 ) continue
        if ( JITER_CURLEN == HISTORY_SIZE) exit
    }
}



function cres_loadfromjsonfile( o, kp, fp ){
    jiparse2leaf_fromfile( o, kp,  fp )
}


# gemini_response => cres_object
# openai_response => cres_object
