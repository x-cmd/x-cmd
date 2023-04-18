BEGIN{
    NUM = 1
    Q2_1 = S "\"1\""
    Q2_MSG = S "\"current_message\""
    history = ENVIRON[ "history" ]
}
($0 != 0){ parse(o, $0) }
function parse(o, text,        _arr, _arrl, i){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if ( JITER_LEVEL != 0 ) continue
        if ( JITER_CURLEN == history) exit
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
        answer_v = o[ kp S "\"answer\"" ]
        if (answer_v != "") printf("{ \"role\": \"assistant\", \"content\": %s }\n", answer_v)
    }
}


# BEGIN{
#     Q2_1 = S "\"1\""
#     Q2_MSG = Q2_1 S "\"current_message\""
#     history = ENVIRON[ "history" ]
# }
# ($0 != 0){ parse_file($0) }
# function parse_file(fp,         o, i, l){
#     if (++NUM > history) exit 0
#     jiparse2leaf_fromfile(o, "", fp)
#     if ( o[ Q2_MSG ] != "[" ) print jstr1(o, Q2_MSG)
#     else {
#         l = o[ Q2_MSG L ]
#         for (i=1; i<=l; ++i) print jstr1(o, Q2_MSG S "\""i"\"")
#     }
#     printf("{ role: user, content: %s }\n", o[ Q2_1 S "\"answer\"" ])
# }

