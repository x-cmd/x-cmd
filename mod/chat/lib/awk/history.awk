

# o is [ { ... } ]

# req.json
# res.json
function chat_history_load( o, chatid, hist_session_dir, history_num,       _cmd, l, i, t, _, lt, rt, kp, kp_i, content_dir,
tool_l, j, func_dir, func_desc, func_name, func_code, func_status, func_stdout, func_stderr, func_req, func_res ) {
    kp = chatid
    if ( o[ kp ] == "[" ) return

    _cmd = "{ command find " qu1(hist_session_dir) " -type f -name \"histsum.txt\" -o -path \"*/chat.response/content\" | command sort -r; } 2>/dev/null"
    l = 0
    if (history_num > 0) {
        while( ( _cmd | getline t ) > 0 ){
            t = substr(t, length(hist_session_dir)+2)
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
        kp_i = kp SUBSEP o[ kp L ]

        t = _[ l - i + 1 ]
        content_dir = hist_session_dir "/" t
        if ( _[ t, "use_histsum" ] == true ) {
            o[ kp_i SUBSEP "req" SUBSEP "text" ] = "Here is the context summary of our conversation. Please base your future responses on this without repeating the summary."
            o[ kp_i SUBSEP "res" SUBSEP "text" ] = cat( content_dir "/histsum.txt" )
            continue
        }

        o[ kp_i SUBSEP "req" SUBSEP "text" ] = cat( content_dir "/chat.request/content" )
        o[ kp_i SUBSEP "res" SUBSEP "text" ] = cat( content_dir "/chat.response/content" )

        tool_l = cat( content_dir "/chat.response/tool_call_l" )
        o[ kp_i SUBSEP "res" SUBSEP "tool_l" ] = tool_l
        if ( tool_l > 0 ) {
            for (j=1; j<=tool_l; ++j){
                func_dir    = content_dir "/function-call/" j
                func_desc   = cat( func_dir "/desc" )
                func_name   = cat( func_dir "/name" )
                func_arg    = cat( func_dir "/arg" )
                func_code   = cat( func_dir "/errcode" )
                func_status = cat( func_dir "/status" )
                func_stdout = cat( func_dir "/stdout" )
                func_stderr = cat( func_dir "/stderr" )

                func_req = chat_wrap_tag( "index", j )
                func_req = func_req "\n" chat_wrap_tag( "name", func_name )
                func_req = func_req "\n" chat_wrap_tag( "desc", func_desc )
                func_req = func_req "\n" chat_wrap_tag( "args", func_arg, " lang=\"json\"" )

                func_res = chat_wrap_tag( "index", j )
                func_res = func_res "\n" chat_wrap_tag( "name", func_name )
                func_res = func_res "\n" chat_wrap_tag( "status", func_status )
                func_res = func_res "\n" chat_wrap_tag( "errcode", func_code )
                func_res = func_res "\n" chat_wrap_tag( "stderr", func_stderr )
                func_res = func_res "\n" chat_wrap_tag( "stdout", func_stdout )

                func_req = chat_wrap_tag( "funcmeta-request", func_req )
                func_res = chat_wrap_tag( "funcmeta-result", func_res )
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "req" ] = func_req
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "res" ] = func_res
            }
        }
    }
}

function chat_history_get_req_text(o, prefix, i){
    return o[ prefix SUBSEP i SUBSEP "req" SUBSEP "text" ]
}

function chat_history_get_res_text(o, prefix, i){
    return o[ prefix SUBSEP i SUBSEP "res" SUBSEP "text" ]
}

function chat_history_get_tool_l( o, prefix, i ){
    return o[ prefix SUBSEP i SUBSEP "res" SUBSEP "tool_l" ]
}
function chat_history_get_tool_req(o, prefix, i, j){
    return o[ prefix SUBSEP i SUBSEP "tool" SUBSEP j SUBSEP "req" ]
}
function chat_history_get_tool_res(o, prefix, i, j){
    return o[ prefix SUBSEP i SUBSEP "tool" SUBSEP j SUBSEP "res" ]
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
