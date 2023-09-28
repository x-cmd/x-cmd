BEGIN{
    NUM = 1
    Q2_1 = S "\"1\""
    Q2_MSG = S "\"current_message\""
    Q2_CONTENT = S "\"response\"" S "\"choices\"" S "\"1\"" S "\"message\""
    HISTORY_SIZE = ENVIRON[ "history_size" ]
    BASE_PATH = ENVIRON[ "BASE_PATH" ]
}

# TODO: Optimized version
(NR <= HISTORY_SIZE){
    parse(o, cat( BASE_PATH "/" $0))
}

function parse(o, text,        _arr, _arrl, i){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if ( JITER_LEVEL != 0 ) continue
        if ( JITER_CURLEN == HISTORY_SIZE) exit
    }
}
END{
    l = o[L]
    for (i=l; i>=1; --i){
        kp = S "\""i"\""
        if ( o[ kp Q2_MSG ] != "[" ) print jstr1(o, kp Q2_MSG)
        else {
            l = o[ kp Q2_MSG L ]
            for (i=1; i<=l; ++i) print jstr1(o, kp Q2_MSG S "\""i"\"")
        }
        print jstr1( o, kp Q2_CONTENT )
    }
}
