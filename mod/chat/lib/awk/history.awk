

# o is [ { ... } ]

# req.json
# res.json
function chat_history_load( o, session_dir, history_num, chatid,      _cmd, t, i, j, l, kp, kp_i, _ ){
    _cmd = "command ls " session_dir " | command sort -r"

    i = 0
    if (history_num > 0) {
        while( ( _cmd | getline t ) > 0 ){
            if ( t == chatid) continue
            _[ ++i ] = t
            if (i >= history_num) break
        }
    }
    close( _cmd )
    for (j=1; j<=i; ++j){
        kp = SUBSEP "\"1\""
        kp_i = kp SUBSEP "\""j"\""
        o[ kp ] = "["
        jlist_put(o, kp, "{")
        jdict_put(o, kp_i, "\"creq\"", "{" )
        jdict_put(o, kp_i, "\"cres\"", "{" )

        t = _[ j ]
        creq_loadfromjsonfile( o, kp_i SUBSEP "\"creq\"",  session_dir "/" t "/chat.request.yml" )
        cres_loadfromjsonfile( o, kp_i SUBSEP "\"cres\"",  session_dir "/" t "/chat.response.yml" )
    }

    # print  jstr( o )

}

# [
#     {
#         "creq": {},
#         "cres": {}
#     }
# ]
