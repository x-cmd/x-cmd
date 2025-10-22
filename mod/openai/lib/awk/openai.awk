BEGIN{
    Q2_1 = SUBSEP "\"1\""
}

function openai_gen_unit_str_text(str){
    if( chat_str_is_null(str) ) return
    if (str !~ "^\"")  str = jqu(str)
    return "{ \"type\": \"text\", \"text\": " str " }"
}
function openai_gen_unit_str_image(base64, mime_type,       _msg){
    if( chat_str_is_null(base64) ) return
    _msg = "data:" mime_type ";base64,{" base64 "}"
    return "{ \"type\": \"image_url\", \"image_url\": { \"url\": " jqu(_msg) " } }"
}

function openai_gen_unit_str_rolecont( role, content ){
    if ( role !~ "^\"" )    role = jqu( role )
    if (( content !~ "^\\[.*\\]$" ) && ( content !~ "^\"" )) content = jqu( content )
    return "{ \"role\": " role ", \"content\": " content " }"
}

function openai_gen_history_str( history_obj, chatid, i,        req_text, res_text, j, tool_l, tool_req, tool_res, _res ){
    req_text = chat_history_get_req_text(history_obj, chatid, i)
    res_text = chat_history_get_res_text(history_obj, chatid, i)
    if (req_text =="") return

    _res = openai_gen_unit_str_rolecont( "user", req_text )
    if ( ! chat_str_is_null( res_text ) ) {
        _res = _res ", " openai_gen_unit_str_rolecont( "assistant", res_text )
    }

    tool_l = chat_history_get_tool_l(history_obj, chatid, i)
    if ( tool_l > 0 ) _res = _res ", " openai_gen_unit_str_rolecont("user", jqu("[INTERNAL NOTE: The following content is function execution metadata, shown in pseudo-XML markers.\nThis format is ONLY for recording results.\nWhen you need to make a function call, always use the official JSON function-call format, never this pseudo-XML.]"))
    for (j=1; j<=tool_l; ++j){
        tool_req = chat_history_get_tool_req(history_obj, chatid, i, j)
        tool_res = chat_history_get_tool_res(history_obj, chatid, i, j)
        _res = _res "," openai_gen_unit_str_rolecont("assistant", tool_req)
        _res = _res "," openai_gen_unit_str_rolecont("user", tool_res)
    }
    return _res
}

function openai_gen_filelist_str(filelist_str,       arr, _fp, _type, _str, i, l){
    if ( chat_str_is_null(filelist_str) ) return
    chat_filelist_load_to_array( filelist_str, arr )
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        _fp = arr[ i ]
        _type = arr[ _fp, "type" ]
        if ( _type == "text" ) {
            _str = _str openai_gen_unit_str_text( arr[ _fp, "text" ] )
        } else if ( _type == "image" ) {
            _str = _str openai_gen_unit_str_text( arr[ _fp, "text" ] ) ", "
            _str = _str openai_gen_unit_str_image( arr[ _fp, "base64" ], arr[ _fp, "mime_type" ] )
        }
        _str = _str ((i!=l) ? ", " : "")
    }

    if ( _str != "" ) {
        _str = openai_gen_unit_str_text( "Please note that the following content is provided in XML format. Focus only on the file content part and ignore the tags." ) "," _str
        _str = openai_gen_unit_str_rolecont( "user", "[ " _str " ]" )
    }
    return _str
}

function openai_gen_tool_str( creq_dir,            _function_str ) {
    _str = openai_gen_tool_function_str( creq_dir )
    return _str
}

function openai_gen_tool_function_str( creq_dir,            tool_str, tool_obj, tool_kp, tool_function_kp, i, l, _res, _ ){
    tool_str = creq_fragfile_unit___get( creq_dir, "tool" )
    if ( chat_str_is_null(tool_str) ) return

    tool_kp = SUBSEP "tool"
    jiparse2leaf_fromstr( tool_obj, SUBSEP "tool", tool_str )

    tool_function_kp = tool_kp SUBSEP "\"function\""
    l = tool_obj[ tool_function_kp L ]
    if (l <= 0) return ""

    _res = ""
    for (i=1; i<=l; ++i){
        jlist_put( _, "", "{")
        jdict_put( _, SUBSEP "\""i"\"", "\"type\"", "\"function\"")
        jdict_put( _, SUBSEP "\""i"\"", "\"function\"", "{")
        jmerge_force___value(_, SUBSEP "\""i"\"" SUBSEP "\"function\"", tool_obj, tool_function_kp SUBSEP "\""i"\"")

        jdict_put( _, SUBSEP "\""i"\"" SUBSEP "\"function\"", "\"strict\"", "true")
        jdict_put( _, SUBSEP "\""i"\"" SUBSEP "\"function\"" SUBSEP "\"parameters\"" ,"\"additionalProperties\"", "false")

        _res = _res jstr0(_, SUBSEP "\""i"\"", " ") ((i!=l)  ? "," : "")
    }

    return _res
}
function openai_gen_last_msgtool_from_creq( current_msgtool_obj, msgtool_obj, chatid, hist_session_dir,             last_chatid, last_creq_dir){
    last_chatid = chat_history_get_last_chatid(hist_session_dir, current_msgtool_obj[ "provider" ], chatid)
    if ( last_chatid == "" ) return
    last_creq_dir = ( hist_session_dir "/" last_chatid "/chat.request" )
    if ( (current_msgtool_obj[ "provider" ] != creq_fragfile_unit___get(last_creq_dir, "provider")) || (current_msgtool_obj[ "model" ] != creq_fragfile_unit___get(last_creq_dir, "model")) ) return
    return openai_gen_msgtool_from_creq( msgtool_obj, last_creq_dir, last_chatid, hist_session_dir )
}

function openai_gen_msgtool_from_creq( msgtool_obj, creq_dir, chatid, hist_session_dir,                  history_obj, history_num, i, l, str, \
    _history_str, _system_str, _filelist_str, _example_str, _content_str, _messages_str, _tool_str, _stats_str ){

    history_num = creq_fragfile_unit___get( creq_dir, "history_num" )

    chat_history_load( history_obj, chatid, hist_session_dir, history_num )
    l = chat_history_get_maxnum(history_obj, chatid)
    for (i=1; i<=l; ++i){
        str = openai_gen_history_str(history_obj, chatid, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    _system_str = creq_fragfile_unit___get( creq_dir, "system" )
    if (_system_str != "") {
        _system_str = chat_wrap_tag("system", _system_str)
        _system_str = openai_gen_unit_str_rolecont( "system", _system_str ) " ,"
    }

    _example_str = creq_fragfile_unit___get( creq_dir, "example" )
    if ( _example_str != "" ) _example_str = openai_gen_unit_str_rolecont( "user", _example_str ) " ,"

    _filelist_str = creq_fragfile_unit___get( creq_dir, "filelist_attach" )
    if (_filelist_str != "") _filelist_str = openai_gen_filelist_str(_filelist_str) " ,"

    _stats_str = chat_statsfile_load( hist_session_dir )
    if ( _stats_str != "" ) _stats_str = openai_gen_unit_str_rolecont( "user", _stats_str ) " ,"

    _content_str = creq_fragfile_unit___get( creq_dir, "content" )
    _content_str = str_trim(_content_str)
    if ( _content_str == "" ) _content_str = "null"
    _content_str = openai_gen_unit_str_rolecont( "user", _content_str )

    _messages_str   = _system_str _example_str _history_str _filelist_str _stats_str _content_str
    _messages_str   = "\"messages\": [ " _messages_str " ], "
    _tool_str       = openai_gen_tool_str( creq_dir )
    _tool_str       = (_tool_str) ? "\"tools\": [" _tool_str "]," : ""

    creq_fragfile_set___usage_input_ratio_SHO( creq_dir, _system_str _example_str, _history_str, _filelist_str _stats_str _content_str _tool_str )

    msgtool_obj[ "msg_str" ]  = _messages_str
    msgtool_obj[ "tool_str" ] = _tool_str
    msgtool_obj[ "provider" ] = creq_fragfile_unit___get( creq_dir, "provider" )
    msgtool_obj[ "model" ]    = creq_fragfile_unit___get( creq_dir, "model" )
}

function openai_req_from_creq(creq_dir, chatid, hist_session_dir,
    msgtool_obj, last_msgtool_obj, cache_msg, cache_tool, _msgtool, _mode, _maxtoken_keyname, _maxtoken, _seed, _temperature, _jsonmode, _ctx, is_stream, _data_str, _stream_str, _reason_eddort){
    openai_gen_msgtool_from_creq(msgtool_obj, creq_dir, chatid, hist_session_dir)
    openai_gen_last_msgtool_from_creq(msgtool_obj, last_msgtool_obj, chatid, hist_session_dir)
    _msgtool    = msgtool_obj[ "msg_str" ] msgtool_obj[ "tool_str" ]

    cache_msg   = chat_cal_cached( msgtool_obj[ "msg_str" ], last_msgtool_obj[ "msg_str" ] )
    cache_tool  = chat_cal_cached( msgtool_obj[ "tool_str" ], last_msgtool_obj[ "tool_str" ] )
    creq_fragfile_set___usage_input_ratio_cache( creq_dir, int(cache_msg + cache_tool), length( _msgtool ))

    _mode           = creq_fragfile_unit___get( creq_dir, "model" )
    _maxtoken       = creq_fragfile_unit___get( creq_dir, "maxtoken" )
    _seed           = creq_fragfile_unit___get( creq_dir, "seed" )
    _temperature    = creq_fragfile_unit___get( creq_dir, "temperature" )
    _jsonmode       = creq_fragfile_unit___get( creq_dir, "jsonmode" )
    _ctx            = creq_fragfile_unit___get( creq_dir, "ctx" )
    is_stream       = creq_fragfile_unit___get( creq_dir, "is_stream" )
    is_stream       = chat_tf_bit( is_stream )
    # Tip:
    #   in some case, _maxtoken is 0, but it is not a valid value for openai.
    #   in openai, 'max_tokens' is now deprecated in favor of 'max_completion_tokens', and is not compatible with o1 series models.

    if ( PROVIDER_NAME == "openai" ) {
        _maxtoken_keyname = "\"max_completion_tokens\""
        if ( _mode ~ "^(gpt-5|o)" ) {
            _reason_eddort  = "low" # medium high
        }
    } else {
        _maxtoken_keyname = "\"max_tokens\""
    }

    if ( is_stream == true ) {
        if ( PROVIDER_NAME == "openai" ) {
            _stream_str       = "\"stream\": true, \"stream_options\": { \"include_usage\": true }"
        } else {
            _stream_str       = "\"stream\": true"
        }
    } else {
        # if "^(gpt-5|gpt-5-mini)$"
        _stream_str       = "\"stream\": false"
    }

    _mode           = (_mode != "") ? "\"model\": " jqu(_mode) "," : ""
    _maxtoken       = (_maxtoken > 0) ? _maxtoken_keyname ": " _maxtoken "," : ""
    _seed           = (_seed != "") ? "\"seed\": " int(_seed) "," : ""
    _temperature    = (_temperature != "") ? "\"temperature\": " _temperature "," : ""
    _ctx            = (_ctx != "") ? "\"num_ctx\": " _ctx "," : ""
    _jsonmode       = (_jsonmode) ? "\"response_format\": { \"type\": \"json_object\" }," : ""
    _reason_eddort  = (_reason_eddort) ? "\"reasoning_effort\": " jqu( _reason_eddort ) "," : ""

    _data_str = "{ " _mode _msgtool _jsonmode _maxtoken _seed _temperature _ctx _reason_eddort _stream_str " }"

    return _data_str
}

function openai_res_to_cres(openai_resp_o, cres_dir, creq_dir, o_tool, tool_kp,
    Q2_1, resp_kp, delta_kp, resp_content_kp, resp_role_kp, resp_reason_kp, resp_finish_kp, usage_kp ){
    mkdirp( cres_dir )
    if ( PROVIDER_NAME == "ollama" ) {
        openai_res_to_cres___ollama_format(openai_resp_o, cres_dir)
        return
    }

    Q2_1            = SUBSEP "\"1\""
    resp_kp         = Q2_1 SUBSEP "\"choices\"" SUBSEP "\"1\""
    delta_kp        = resp_kp SUBSEP "\"delta\""
    resp_content_kp = delta_kp SUBSEP "\"content\""
    resp_role_kp    = delta_kp SUBSEP "\"role\""
    resp_reason_kp  = delta_kp SUBSEP "\"reasoning_content\""
    resp_finish_kp  = resp_kp SUBSEP "\"finish_reason\""

    cres_fragfile_unit___set( cres_dir, "id",           juq( openai_resp_o[ Q2_1, "\"id\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "created",      juq( openai_resp_o[ Q2_1, "\"created\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "model",        juq( openai_resp_o[ Q2_1, "\"model\"" ] ) )

    cres_fragfile_unit___set( cres_dir, "role",         juq( openai_resp_o[ resp_role_kp ] ) )
    cres_fragfile_unit___set( cres_dir, "content",      juq( openai_resp_o[ resp_content_kp ] ) )

    if ( o_tool[ tool_kp L ] > 0 ) {
        cres_fragfile_unit___set( cres_dir, "tool_call",            jstr( o_tool, tool_kp))
        cres_fragfile_unit___set( cres_dir, "tool_call_l",          o_tool[ tool_kp L ])
    }

    if ( openai_resp_o[ resp_reason_kp ] != "" ) {
        cres_fragfile_unit___set( cres_dir, "reasoning_content",    juq( openai_resp_o[ resp_reason_kp ] ) )
    }

    if ( openai_resp_o[ resp_finish_kp ] != "" ) {
        cres_fragfile_unit___set( cres_dir, "finish_reason",        juq( openai_resp_o[ resp_finish_kp ] ) )
    }

    usage_kp        = SUBSEP "\"1\"" SUBSEP "\"usage\""
    if ( openai_resp_o[ usage_kp ] == "{" )  {
        cres_fragfile_unit___set( cres_dir, "raw_usage",            jstr( openai_resp_o, usage_kp ) )
    }

    # for kimi format
    if ( openai_resp_o[ resp_kp SUBSEP "\"usage\"" ] == "{" ) {
        usage_kp    = resp_kp SUBSEP "\"usage\""
        cres_fragfile_unit___set( cres_dir, "raw_usage",            jstr( openai_resp_o, usage_kp ) )
    }

    cres_fragfile_unit___set( cres_dir, "usage_input_token",            int( openai_resp_o[ usage_kp SUBSEP "\"prompt_tokens\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "usage_input_cache_token",      int( openai_resp_o[ usage_kp SUBSEP "\"prompt_tokens_details\"" SUBSEP "\"cached_tokens\"" ] ) )

    cres_fragfile_unit___set( cres_dir, "usage_output_token",           int( openai_resp_o[ usage_kp SUBSEP "\"completion_tokens\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "usage_output_thought_token",   int( openai_resp_o[ usage_kp SUBSEP "\"completion_tokens_details\"" SUBSEP "\"reasoning_tokens\"" ] ) )

    cres_fragfile_unit___set( cres_dir, "usage_total_token",            int( openai_resp_o[ usage_kp SUBSEP "\"total_tokens\"" ] ) )
}

function openai_res_to_cres___ollama_format(ollama_resp_o, cres_dir,         Q2_1 ){
    Q2_1 = SUBSEP "\"1\""
    cres_fragfile_unit___set( cres_dir, "model",    juq( ollama_resp_o[ Q2_1, "\"model\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "created",  juq( ollama_resp_o[ Q2_1, "\"created_at\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "role",     juq( ollama_resp_o[ Q2_1, "\"role\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "content",  juq( ollama_resp_o[ Q2_1 SUBSEP "\"message\"" SUBSEP "\"content\"" ] ) )
}
