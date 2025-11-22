

# o is [ { ... } ]

# req.json
# res.json
function chat_history_load( o, chatid, hist_session_dir, history_num,       _cmd, l, i, t, _, lt, rt, num, req_text, kp, kp_i, content_dir,
tool_l, j, func_dir, func_id, func_desc, func_name, func_code, func_status, func_stdout, func_stderr, func_req, func_res, loutput ) {
    kp = chatid
    if ( o[ kp ] == "[" ) return
    if (history_num <= 0) return

    l = 0
    _cmd = "{ { for i in " qu1(hist_session_dir) "/*; do [ -d \"$i\" ] || continue; for j in \"$i/chat.response/done\" \"$i/histsum.md\"; do [ ! -f \"$j\" ] || printf \"%s\\n\" \"$j\"; done; done; } | command sort -r; } 2>/dev/null"
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

            if (rt == "histsum.md") {
                ++num
                _[ lt, "use_histsum" ] = true
                break
            }

            req_text = cat( hist_session_dir "/" lt "/chat.request/content" )
            _[ lt, "req_text" ] = req_text
            if ( req_text != "" ) ++num
            if (num >= history_num) break
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
            o[ kp_i SUBSEP "res" SUBSEP "text" ] = cat( content_dir "/histsum.md" )
            continue
        }

        o[ kp_i SUBSEP "req" SUBSEP "text" ]            = _[ t, "req_text" ]
        o[ kp_i SUBSEP "req" SUBSEP "attach_text" ]     = cat( content_dir "/chat.request/attach_text" )
        o[ kp_i SUBSEP "req" SUBSEP "attach_filelist" ] = cat( content_dir "/chat.request/attach_filelist" )
        o[ kp_i SUBSEP "res" SUBSEP "text" ]            = cat( content_dir "/chat.response/content" )

        tool_l = cat( content_dir "/chat.response/tool_call_l" )
        o[ kp_i SUBSEP "res" SUBSEP "tool_l" ] = tool_l
        if ( tool_l > 0 ) {
            for (j=1; j<=tool_l; ++j){
                func_dir    = content_dir "/function-call/" j
                func_id     = cat( func_dir "/id" )
                func_name   = cat( func_dir "/name" )
                func_desc   = cat( func_dir "/desc" )
                func_arg    = cat( func_dir "/arg" )
                func_code   = cat( func_dir "/errcode" )
                func_status = cat( func_dir "/status" )

                func_stdout = "----- BEGIN -----\n" \
                    cat( func_dir "/stdout" ) \
                    "\n----- END -----"
                func_stderr = "----- BEGIN -----\n" \
                    cat( func_dir "/stderr" ) \
                    "\n----- END -----"

                func_stdout = chat_str_truncate(func_stdout)
                func_stderr = chat_str_truncate(func_stderr)

                func_stdout = str_remove_esc( func_stdout )
                func_stderr = str_remove_esc( func_stderr )

                func_req = chat_wrap_tag( "index", j )
                func_req = func_req "\n" chat_wrap_tag( "name", func_name )
                func_req = func_req "\n" chat_wrap_tag( "desc", func_desc )
                func_req = func_req "\n" chat_wrap_tag( "args", func_arg )

                func_res = chat_wrap_tag( "name", func_name )
                func_res = func_res "\n" chat_wrap_tag( "status", func_status )
                func_res = func_res "\n" chat_wrap_tag( "errcode", func_code )
                func_res = func_res "\n" chat_wrap_tag( "stderr", func_stderr )
                func_res = func_res "\n" chat_wrap_tag( "stdout", func_stdout )

                func_req = chat_wrap_tag( "funcmeta-request", func_req )
                func_res = chat_wrap_tag( "funcmeta-result", func_res )

                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "id" ] = func_id
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "name" ] = func_name
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "desc" ] = func_desc
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "args" ] = func_arg
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "req" ] = func_req
                o[ kp_i SUBSEP "tool" SUBSEP j SUBSEP "res" ] = func_res
            }
        }
    }
}

function chat_history_get_function_call_log_begin(){
    # "[INTERNAL NOTE: The following block shows past tool execution data for context only.\nDo not reuse or mimic this structure when performing new tool calls.]"
    return "<<< INTERNAL TOOL LOG — DO NOT REPLICATE >>>"
}

function chat_history_get_function_call_log_end(){
    # "[End of tool output — use your environment’s standard function-call format.]"
    return "<<< END OF INTERNAL LOG >>>"
}

function chat_history_get_req_text(o, prefix, i){
    return o[ prefix SUBSEP i SUBSEP "req" SUBSEP "text" ]
}

function chat_history_get_req_attach_text(o, prefix, i){
    return o[ prefix SUBSEP i SUBSEP "req" SUBSEP "attach_text" ]
}

function chat_history_get_req_attach_filelist(o, prefix, i){
    return o[ prefix SUBSEP i SUBSEP "req" SUBSEP "attach_filelist" ]
}

function chat_history_get_res_text(o, prefix, i){
    return o[ prefix SUBSEP i SUBSEP "res" SUBSEP "text" ]
}

function chat_history_get_tool_l( o, prefix, i ){
    return o[ prefix SUBSEP i SUBSEP "res" SUBSEP "tool_l" ]
}
function chat_history_get_tool_id(o, prefix, i, j){
    return o[ prefix SUBSEP i SUBSEP "tool" SUBSEP j SUBSEP "id" ]
}
function chat_history_get_tool_name(o, prefix, i, j){
    return o[ prefix SUBSEP i SUBSEP "tool" SUBSEP j SUBSEP "name" ]
}
function chat_history_get_tool_args(o, prefix, i, j){
    return o[ prefix SUBSEP i SUBSEP "tool" SUBSEP j SUBSEP "args" ]
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
    _cmd = "{ { for i in " qu1(hist_session_dir) "/*; do f=\"$i/"provider".response.yml\"; [ ! -f \"$f\" ] || printf \"%s\\n\" \"$f\"; done; } | command sort -r; } 2>/dev/null"
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
