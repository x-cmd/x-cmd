BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"
}

function openai_gen_unit_str_text(str){
    if( chat_str_is_null(str) ) return
    if (str !~ "^\"")  str = jqu(str)
    return "{ \"type\": \"text\", \"text\": " str " }"
}

function openai_gen_unit_str_rolecont( role, content ){
    if ( role !~ "^\"" )    role = jqu( role )
    if (( content !~ "^\\[.*\\]$" ) && ( content !~ "^\"" )) content = jqu( content )
    return "{ \"role\": " role ", \"content\": " content " }"
}

function openai_gen_history_str( history_obj, chatid, i,        _text_req, _text_res, _text_tool, _res ){
    _text_req = chat_history_get_req_text(history_obj, chatid, i)
    _text_res = chat_history_get_res_text(history_obj, chatid, i)
    _text_tool = chat_history_get_res_tool_call(history_obj, chatid, i)
    if (_text_req =="") return

    _res = openai_gen_unit_str_rolecont( "user", _text_req )
    if ( ! chat_str_is_null( _text_res ) ) {
        _res = _res ", " openai_gen_unit_str_rolecont( "assistant", _text_res )
    }

    if ( ! chat_str_is_null( _text_tool ) ) {
        _res = _res ", " openai_gen_unit_str_rolecont( "assistant", _text_tool )
    }
    return _res
}

function openai_gen_filelist_str(filelist_str,       arr, _str, i, l){
    if ( chat_str_is_null(filelist_str) ) return
    chat_filelist_load_to_array( filelist_str, arr )
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        _str = _str openai_gen_unit_str_text( arr[i] ) ((i!=l) ? ", " : "")
    }

    if ( _str != "" ) {
        _str = openai_gen_unit_str_text( "Please note that the following content is provided in XML format. Focus only on the file content part and ignore the tags." ) "," _str
        _str = openai_gen_unit_str_rolecont( "user", "[ " _str " ]" )
    }
    return _str
}

function openai_gen_minion_content_str(minion_obj, minion_kp, media_str,      context, example, content, str){
    context = minion_prompt_context(minion_obj, minion_kp)
    context = ( context != "" ) ? context JOINSEP : ""

    example = minion_example_tostr(minion_obj, minion_kp)
    content = minion_prompt_content(minion_obj, minion_kp)
    str = context example content
    str = str_trim(str)
    if ( str == "" ) str = "null"

    if( media_str != "" ){
        str = openai_gen_unit_str_text( str )
        return openai_gen_unit_str_rolecont( "[ " str media_str " ]" )
    }
    return openai_gen_unit_str_rolecont( "user", str )
}

function openai_gen_media_str(creq_obj, creq_kp,        _kp_media, i, l, _kp_key, _type, _url, _mime_type, _base64, _msg, _str){
    _kp_media = creq_kp SUBSEP "\"media\""
    l = creq_obj[ _kp_media L ]
    if (l <= 0) return
    for (i=1; i<=l; ++i){
        _kp_key = _kp_media SUBSEP "\""i"\""
        _type   = creq_obj[ _kp_key, "\"type\"" ]
        _url    = creq_obj[ _kp_key, "\"url\"" ]
        if ( _type == "\"image\"" ) {
            _type = "\"image_url\""
        }

        if ( _url != "" ) {
            _str    = _str ",{ \"type\": " _type ", \"image_url\": { \"url\": " jqu(_url) " } }"
        } else {
            _base64 = juq(creq_obj[ _kp_key, "\"base64\"" ])
            _mime_type = juq(creq_obj[ _kp_key, "\"mime_type\"" ])
            _msg    = "data:" _mime_type ";base64,{" _base64 "}"
            _str    = _str ",{ \"type\": " _type ", \"image_url\": { \"url\": " jqu( _msg ) " } }"
        }

    }
    return _str
}


function openai_gen_tool_str( creq_obj, creq_kp,            _function_str ) {
    _function_str = openai_gen_tool_function_str( creq_obj, creq_kp )
    return _function_str
}

function openai_gen_tool_function_str( creq_obj, creq_kp,           i, l, _kp_tool_function, _, _res ){
    _kp_tool_function = creq_kp SUBSEP "\"tool\"" SUBSEP "\"function\""
    l = creq_obj[ _kp_tool_function L ]
    if (l <= 0) return ""

    _res = ""
    for (i=1; i<=l; ++i){
        jlist_put( _, "", "{")
        jdict_put( _, SUBSEP "\""i"\"", "\"type\"", "\"function\"")
        jdict_put( _, SUBSEP "\""i"\"", "\"function\"", "{")
        jmerge_force___value(_, SUBSEP "\""i"\"" SUBSEP "\"function\"", creq_obj, _kp_tool_function SUBSEP "\""i"\"")

        jdict_put( _, SUBSEP "\""i"\"" SUBSEP "\"function\"", "\"strict\"", "true")
        jdict_put( _, SUBSEP "\""i"\"" SUBSEP "\"function\"" SUBSEP "\"parameters\"" ,"\"additionalProperties\"", "false")

        _res = _res jstr0(_, SUBSEP "\""i"\"", " ") ((i!=l)  ? "," : "")
    }

    return _res
}
function openai_gen_last_msgtool_from_creq( current_msgtool_obj, msgtool_obj, chatid, hist_session_dir,             provider, last_chatid, last_creq_obj, last_creq_kp ){
    last_chatid = chat_history_get_last_chatid(hist_session_dir, juq(current_msgtool_obj[ "provider" ]), chatid)
    if ( last_chatid == "" ) return
    last_creq_kp = SUBSEP "last-creq"
    chat_history_get_last_creq( last_creq_obj, last_creq_kp, hist_session_dir, provider, chatid, last_chatid )
    if ( (current_msgtool_obj[ "provider" ] != last_creq_obj[ last_creq_kp, "\"provider\"" ]) || (current_msgtool_obj[ "model" ] != last_creq_obj[ last_creq_kp, "\"model\"" ]) ) return
    return openai_gen_msgtool_from_creq( msgtool_obj, last_creq_obj, last_creq_kp, last_chatid, hist_session_dir )
}

function openai_gen_msgtool_from_creq( msgtool_obj, creq_obj, creq_kp, chatid, hist_session_dir,                  history_obj, history_num, i, l, str, \
    _history_str, _creq_minion_kp, _system_str, _filelist_str, _media_str, _content_str, _messages_str, _tool_str){

    history_num = creq_obj[ creq_kp S "\"history_num\"" ]

    chat_history_load( history_obj, chatid, hist_session_dir, history_num )
    l = chat_history_get_maxnum(history_obj, chatid)
    for (i=1; i<=l; ++i){
        str = openai_gen_history_str(history_obj, chatid, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    _creq_minion_kp = creq_kp SUBSEP "\"minion\""
    _system_str = minion_system_tostr(creq_obj, _creq_minion_kp)
    if (_system_str != "") _system_str = openai_gen_unit_str_rolecont( "system", _system_str ) " ,"

    _filelist_str = creq_obj[ creq_kp S "\"filelist_attach\"" ]
    if (_filelist_str != "") _filelist_str = openai_gen_filelist_str(juq(_filelist_str)) " ,"

    _media_str      = openai_gen_media_str(creq_obj, creq_kp)
    _content_str    = openai_gen_minion_content_str(creq_obj, _creq_minion_kp, _media_str)
    _messages_str   = _system_str _history_str _filelist_str _content_str
    _messages_str   = "\"messages\": [ " _messages_str " ], "
    _tool_str       = openai_gen_tool_str(creq_obj, creq_kp)
    _tool_str       = (_tool_str) ? "\"tools\": [" _tool_str "]," : ""

    creq_append_usage_input_ratio_SHO( creq_obj, creq_kp, _system_str, _history_str, _filelist_str _content_str _tool_str )

    msgtool_obj[ "msg_str" ]  = _messages_str
    msgtool_obj[ "tool_str" ] = _tool_str
    msgtool_obj[ "provider" ] = creq_obj[ creq_kp, "\"provider\"" ]
    msgtool_obj[ "model" ]    = creq_obj[ creq_kp, "\"model\"" ]
}

function openai_req_from_creq(creq_obj, creq_kp, chatid, hist_session_dir,
    msgtool_obj, last_msgtool_obj, cache_msg, cache_tool, _msgtool, _mode, _maxtoken_keyname, _maxtoken, _seed, _temperature, _jsonmode, _ctx, is_stream, _data_str, _stream_str, _reason_eddort){
    openai_gen_msgtool_from_creq(msgtool_obj, creq_obj, creq_kp, chatid, hist_session_dir)
    openai_gen_last_msgtool_from_creq(msgtool_obj, last_msgtool_obj, chatid, hist_session_dir)
    _msgtool    = msgtool_obj[ "msg_str" ] msgtool_obj[ "tool_str" ]

    cache_msg   = chat_cal_cached( msgtool_obj[ "msg_str" ], last_msgtool_obj[ "msg_str" ] )
    cache_tool  = chat_cal_cached( msgtool_obj[ "tool_str" ], last_msgtool_obj[ "tool_str" ] )
    creq_append_usage_input_ratio_cache( creq_obj, creq_kp, int(cache_msg + cache_tool), length( _msgtool ))

    _creq_minion_kp = creq_kp SUBSEP "\"minion\""
    _mode           = creq_obj[ creq_kp, "\"model\"" ]
    _maxtoken       = minion_maxtoken( creq_obj, _creq_minion_kp )
    _seed           = minion_seed( creq_obj, _creq_minion_kp )
    _temperature    = minion_temperature( creq_obj, _creq_minion_kp )
    _jsonmode       = minion_is_jsonmode( creq_obj, _creq_minion_kp )
    _ctx            = minion_ctx( creq_obj, _creq_minion_kp )
    is_stream       = minion_is_stream( creq_obj, _creq_minion_kp, juq(_mode) )

    # Tip:
    #   in some case, _maxtoken is 0, but it is not a valid value for openai.
    #   in openai, 'max_tokens' is now deprecated in favor of 'max_completion_tokens', and is not compatible with o1 series models.

    if ( PROVIDER_NAME == "openai" ) {
        _maxtoken_keyname = "\"max_completion_tokens\""
        if ( _mode ~ "^\"(gpt-5|o)" ) {
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
        # "^(gpt-5|gpt-5-mini)$"
        _stream_str       = "\"stream\": false"
    }

    _mode           = (_mode != "") ? "\"model\": " _mode "," : ""
    _maxtoken       = (_maxtoken > 0) ? _maxtoken_keyname ": " _maxtoken "," : ""
    _seed           = (_seed != "") ? "\"seed\": " int(_seed) "," : ""
    _temperature    = (_temperature != "") ? "\"temperature\": " _temperature "," : ""
    _ctx            = (_ctx != "") ? "\"num_ctx\": " _ctx "," : ""
    _jsonmode       = (_jsonmode) ? "\"response_format\": { \"type\": \"json_object\" }," : ""
    _reason_eddort  = (_reason_eddort) ? "\"reasoning_effort\": " jqu( _reason_eddort ) "," : ""

    _data_str = "{ " _mode _msgtool _jsonmode _maxtoken _seed _temperature _ctx _reason_eddort _stream_str " }"

    return _data_str
}

function openai_res_to_cres(openai_resp_o, cres_obj, cres_kp, creq_obj, creq_kp, o_tool, tool_kp,
    resp_kp, delta_kp, resp_content_kp, resp_role_kp, resp_reason_kp, usage_kp, cres_usage_kp, cres_input_kp, cres_output_kp, cres_total_kp){
    if ( PROVIDER_NAME == "ollama" ) {
        openai_res_to_cres___ollama_format(openai_resp_o, cres_obj, cres_kp)
        return
    }

    cres_kp = ((cres_kp != "") ? cres_kp : SUBSEP "\"1\"")
    cres_obj[ cres_kp ] = "{"

    resp_kp         = SUBSEP "\"1\"" SUBSEP "\"choices\"" SUBSEP "\"1\""
    delta_kp        = resp_kp SUBSEP "\"delta\""
    resp_content_kp = delta_kp SUBSEP "\"content\""
    resp_role_kp    = delta_kp SUBSEP "\"role\""
    resp_reason_kp  = delta_kp SUBSEP "\"reasoning_content\""

    jmerge_force___value(cres_obj, cres_kp, openai_resp_o, SUBSEP "\"1\"")
    jmerge_force___value(cres_obj, cres_kp, openai_resp_o, resp_kp)
    jdict_put( cres_obj, cres_kp, "\"finishReason\"", cres_obj[ cres_kp, "\"finish_reason\"" ] )
    jdict_put( cres_obj, cres_kp, "\"reply\"", "{" )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"role\"", openai_resp_o[ resp_role_kp ] )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"content\"", openai_resp_o[ resp_content_kp ] )
    if ( o_tool[ tool_kp L ] > 0 ) {
        jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"tool_calls\"", "[" )
        jmerge_force___value( cres_obj, cres_kp SUBSEP "\"reply\"" SUBSEP "\"tool_calls\"", o_tool, tool_kp )
    }

    if ( openai_resp_o[ resp_reason_kp ] != "" ){
        jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"reasoning_content\"", openai_resp_o[ resp_reason_kp ] )
    }

    jdict_rm( cres_obj, cres_kp, "\"finish_reason\"" )
    jdict_rm( cres_obj, cres_kp, "\"choices\"" )
    jdict_rm( cres_obj, cres_kp, "\"delta\"" )
    jdict_rm( cres_obj, cres_kp, "\"usage\"" )
    cres_obj[ cres_kp, "\"usage\"" L ] = 0

    jdict_put( cres_obj, cres_kp, "\"raw_usage\"", "{" )
    usage_kp        = SUBSEP "\"1\"" SUBSEP "\"usage\""
    if ( openai_resp_o[ usage_kp ] == "{" ) jmerge_force___value( cres_obj, cres_kp SUBSEP "\"raw_usage\"", openai_resp_o, usage_kp )

    # for kimi format
    if ( openai_resp_o[ resp_kp SUBSEP "\"usage\"" ] == "{" ) {
        usage_kp    = resp_kp SUBSEP "\"usage\""
        jmerge_force___value( cres_obj, cres_kp SUBSEP "\"raw_usage\"", openai_resp_o, usage_kp )
    }

    # input ouput total
    jdict_put( cres_obj, cres_kp, "\"usage\"", "{" )
    cres_usage_kp   = cres_kp SUBSEP "\"usage\""
    jdict_put( cres_obj, cres_usage_kp, "\"input\"", "{" )
    cres_input_kp   = cres_usage_kp SUBSEP "\"input\""
    jdict_put( cres_obj, cres_input_kp, "\"tokens\"", int(openai_resp_o[ usage_kp SUBSEP "\"prompt_tokens\"" ] ) )
    jdict_put( cres_obj, cres_input_kp, "\"cache_tokens\"", int( openai_resp_o[ usage_kp SUBSEP "\"prompt_tokens_details\"" SUBSEP "\"cached_tokens\"" ] ) )

    jdict_put( cres_obj, cres_usage_kp, "\"output\"", "{" )
    cres_output_kp  = cres_usage_kp SUBSEP "\"output\""
    jdict_put( cres_obj, cres_output_kp, "\"tokens\"", int( openai_resp_o[ usage_kp SUBSEP "\"completion_tokens\"" ] ) )
    jdict_put( cres_obj, cres_output_kp, "\"thought_tokens\"", int( openai_resp_o[ usage_kp SUBSEP "\"completion_tokens_details\"" SUBSEP "\"reasoning_tokens\"" ] ) )

    jdict_put( cres_obj, cres_usage_kp, "\"total\"", "{" )
    cres_total_kp   = cres_usage_kp SUBSEP "\"total\""
    jdict_put( cres_obj, cres_total_kp, "\"tokens\"", int( openai_resp_o[ usage_kp SUBSEP "\"total_tokens\"" ] ) )

    # creq token ratio
    usage_kp        = creq_kp SUBSEP "\"usage\""
    if ( creq_obj[ usage_kp ] == "{" ) jmerge_force___value( cres_obj, cres_kp SUBSEP "\"usage\"", creq_obj, usage_kp )

    jdict_put( cres_obj, cres_kp, "\"provider\"", creq_obj[ creq_kp, "\"provider\"" ]  )
}

function openai_res_to_cres___ollama_format(ollama_resp_o, cres_obj, cres_kp,          resp_kp){
    cres_kp = ((cres_kp != "") ? cres_kp : SUBSEP "\"1\"")
    cres_obj[ cres_kp ] = "{"

    reply_kp = Q2_1 SUBSEP "\"reply\""
    model_kp = Q2_1 SUBSEP "\"model\""
    msg_kp = Q2_1 SUBSEP "\"message\"" SUBSEP "\"content\""

    jmerge_force___value(cres_obj, cres_kp, ollama_resp_o, SUBSEP "\"1\"")

    jdict_put( cres_obj, cres_kp, "\"reply\"", "{" )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"role\"", ollama_resp_o[ model_kp ] )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"parts\"", "[" )
    jlist_put( cres_obj, cres_kp SUBSEP "\"reply\"" SUBSEP "\"parts\"", "{" )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"" SUBSEP "\"parts\"" SUBSEP "\"1\"", "\"text\"", ollama_resp_o[ msg_kp ] )

    jdict_rm( cres_obj, cres_kp, "\"message\"" )
}
