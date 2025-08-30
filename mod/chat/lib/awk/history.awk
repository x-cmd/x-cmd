

# o is [ { ... } ]

# req.json
# res.json
function chat_history_load( o, chatid, hist_session_dir, history_num,     _cmd, t, lt, rt, i, l, kp, kp_i, _ ){
    kp = chatid
    if ( o[ kp ] == "[" ) return

    _cmd = "{ command find " qu1(hist_session_dir) " -type f -name \"histsum.txt\" -o -name \"chat.response.yml\" | command sort -r; } 2>/dev/null"
    l = 0
    if (history_num > 0) {
        while( ( _cmd | getline t ) > 0 ){
            if (match(t, "/[^/]+/[^/]+$"))
            t = substr(t, RSTART+1)
            i = index( t, "/" )
            lt = substr(t, 1, i-1)
            rt = substr(t, i+1)
            if ( lt < chatid ) {

                if ( _[ lt, "recorded" ] != true ) {
                    _[ ++l ] = lt
                    _[ lt, "recorded" ] = true
                }

                if (rt == "histsum.txt") {
                    _[ lt, "use_histsum" ] = true
                    break
                }
                if (l >= history_num) break
            }
        }
    }
    close( _cmd )
    o[ kp ] = "["
    for (i=1; i<=l; ++i){
        jlist_put(o, kp, "{")
        kp_i = kp SUBSEP "\"" o[ kp L ] "\""

        t = _[ l - i + 1 ]
        if ( _[ t, "use_histsum" ] == true ) {
            o[ kp_i SUBSEP "\"creq\"" SUBSEP "\"question\""] = "\"Here is the context summary of our conversation. Please base your future responses on this without repeating the summary.\""
            o[ kp_i SUBSEP "\"cres\"" SUBSEP "\"reply\"" SUBSEP "\"content\""] = jqu( cat( hist_session_dir "/" t "/histsum.txt" ) )
            o[ kp_i SUBSEP "\"cres\"" SUBSEP "\"finishReason\""] = "\"stop\""
            continue
        }

        jdict_put(o, kp_i, "\"creq\"", "{" )
        jdict_put(o, kp_i, "\"cres\"", "{" )
        creq_loadfromjsonfile( o, kp_i SUBSEP "\"creq\"",  hist_session_dir "/" t "/chat.request.yml" )
        cres_loadfromjsonfile( o, kp_i SUBSEP "\"cres\"",  hist_session_dir "/" t "/chat.response.yml" )
    }
}

function chat_history_get_req_text(o, prefix, i){
    return o[ prefix SUBSEP "\""i"\"" SUBSEP "\"creq\"" SUBSEP "\"question\""]
}

function chat_history_get_res_text(o, prefix, i){
    return o[ prefix SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"reply\"" SUBSEP "\"content\"" ]
}

function chat_history_get_res_tool_call(o, prefix, i){
    if ( o[ prefix SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"reply\"" SUBSEP "\"tool_calls\"" L ] <= 0 ) return
    return jstr0( o, prefix SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"reply\"" SUBSEP "\"tool_calls\"", " " )
}

function chat_history_get_finishReason(o, prefix, i){
    return o[ prefix SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"finishReason\"" ]
}

function chat_history_get_maxnum(o, prefix){
    return o[ prefix L ]
}

# provider: openai, gemini, chat
function chat_history_get_last_chatid(hist_session_dir, provider, cur_chatid,            _cmd, t, last_chatid){
    _cmd = "{ command find " qu1(hist_session_dir) " -name \""provider".response.yml\"" " | command sort -r; } 2>/dev/null"
    while( ( _cmd | getline t ) > 0 ){
        match(t, "/[^/]+/" provider ".response.yml")
        t = substr(t, RSTART+1)
        gsub("/.*$", "", t)
        if ( t == cur_chatid) continue
        last_chatid = t
        break
    }
    close( _cmd )
    if ( last_chatid  == "" ) return
    return last_chatid
}

function chat_history_get_last_creq(o, prefix, hist_session_dir, provider, cur_chatid, last_chatid){
    if ( last_chatid == "" ) last_chatid = chat_history_get_last_chatid(hist_session_dir, provider, cur_chatid)
    if ( last_chatid == "" ) return
    creq_loadfromjsonfile( o, prefix, hist_session_dir "/" last_chatid "/chat.request.yml" )
}
