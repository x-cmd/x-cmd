BEGIN{
    Q2_1 = SUBSEP "\"1\""

    GEMINI_USE_GOOGLE_SEARCH = ENVIRON[ "use_google_search" ]
}

function gemini_gen_unit_str_text(str){
    str = str_trim(str)
    if( ! chat_str_is_null(str)) {
        if (str !~ "^\"")  str = jqu(str)
        return "{\"text\":" str "}"
    }
}

function gemini_gen_unit_str_rolepart(role, str){
   return "{\"role\": \"" role "\",\"parts\": [" str "]}"
}

function gemini_gen_generationConfig(temperature, is_reasoning,                 str){
    if ( temperature != "" ) str = "\"temperature\": " temperature
    if ( is_reasoning == "true" ) {
        str = str (( str != "" ) ?  ", " : "")
        str = str "\"thinkingConfig\": { \"include_thoughts\": true }"
    }
    return ", \"generationConfig\": { " str " }"
}

function gemini_gen_history_str( history_obj, chatid, i,      res_text, req_text, _res, tool_l, j, tool_req, tool_res ) {
    req_text = chat_history_get_req_text(history_obj, chatid, i)
    res_text = chat_history_get_res_text(history_obj, chatid, i)
    if( req_text == "" ) return

    req_text = gemini_gen_unit_str_rolepart("user",  gemini_gen_unit_str_text(req_text))
    _res = req_text
    if ( ! chat_str_is_null( res_text ) ) {
        _res = _res "," gemini_gen_unit_str_rolepart("model", gemini_gen_unit_str_text(res_text))
    }


    tool_l = chat_history_get_tool_l(history_obj, chatid, i)
    for (j=1; j<=tool_l; ++j){
        tool_req = chat_history_get_tool_req(history_obj, chatid, i, j)
        tool_res = chat_history_get_tool_res(history_obj, chatid, i, j)
        _res = _res "," gemini_gen_unit_str_rolepart("model", gemini_gen_unit_str_text( tool_req ))
        _res = _res "," gemini_gen_unit_str_rolepart("user", gemini_gen_unit_str_text( tool_res ))
    }

    return _res
}

function gemini_gen_filelist_str(filelist_str,       arr, _str, i, l){
    if ( chat_str_is_null(filelist_str) ) return
    chat_filelist_load_to_array( filelist_str, arr )
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        _str = _str gemini_gen_unit_str_text( arr[i] ) ((i!=l) ? ", " : "")
    }

    if ( _str != "" ) {
        _str = gemini_gen_unit_str_text( "Please note that the following content is provided in XML format. Focus only on the file content part and ignore the tags." ) "," _str
        _str = gemini_gen_unit_str_rolepart( "user", _str )
    }
    return _str
}

function gemini_gen_safe_setting_str(             _safe_setting){
    _safe_setting = "\"safetySettings\": [{\"category\": \"HARM_CATEGORY_SEXUALLY_EXPLICIT\",\"threshold\": \"BLOCK_ONLY_HIGH\"},{\"category\": \"HARM_CATEGORY_HATE_SPEECH\",\"threshold\": \"BLOCK_ONLY_HIGH\"},{\"category\": \"HARM_CATEGORY_HARASSMENT\",\"threshold\": \"BLOCK_ONLY_HIGH\"},{\"category\": \"HARM_CATEGORY_DANGEROUS_CONTENT\",\"threshold\": \"BLOCK_ONLY_HIGH\"}],"
    gsub(/BLOCK_ONLY_HIGH/, "BLOCK_NONE", _safe_setting) # BLOCK_ONLY_HIGH
    return _safe_setting
}

function gemini_gen_last_msgtool_from_creq( current_msgtool_obj, msgtool_obj, chatid, hist_session_dir,            last_chatid, last_creq_dir ){
    last_chatid = chat_history_get_last_chatid(hist_session_dir, current_msgtool_obj[ "provider" ], chatid)
    if ( last_chatid == "" ) return
    last_creq_dir = ( hist_session_dir "/" last_chatid "/chat.request" )
    if ( (current_msgtool_obj[ "provider" ] != creq_fragfile_unit___get(last_creq_dir, "provider")) || (current_msgtool_obj[ "model" ] != creq_fragfile_unit___get(last_creq_dir, "model")) ) return
    return gemini_gen_msgtool_from_creq( msgtool_obj, last_creq_dir, last_chatid, hist_session_dir )
}

function gemini_gen_msgtool_from_creq( msgtool_obj, creq_dir, chatid, hist_session_dir,                history_obj, history_num, i, l, str, \
    _history_str, _system_str, _content_str, _context_str, _example_str, _filelist_str, _messages_str, _use_gg_search, _tool_str ){
    history_num = creq_fragfile_unit___get( creq_dir, "history_num" )

    chat_history_load( history_obj, chatid, hist_session_dir, history_num)
    l = chat_history_get_maxnum(history_obj, chatid)
    for (i=1; i<=l; ++i){
        str = gemini_gen_history_str(history_obj, chatid, i)
        if (str != "") _history_str = _history_str str ","
    }

    _system_str = creq_fragfile_unit___get( creq_dir, "system" )
    if (_system_str != "") {
        _system_str = chat_wrap_tag("system", _system_str)
        _system_str = gemini_gen_unit_str_rolepart("user", gemini_gen_unit_str_text(_system_str)) ","
    }

    _filelist_str = creq_fragfile_unit___get( creq_dir, "filelist_attach" )
    if (_filelist_str != "") _filelist_str = gemini_gen_filelist_str(_filelist_str)" ,"


    _context_str = creq_fragfile_unit___get( creq_dir, "context" )
    _context_str = (_context_str != "") ? chat_wrap_tag("context", _context_str) "\n" : ""
    _example_str = creq_fragfile_unit___get( creq_dir, "example" )
    _content_str = creq_fragfile_unit___get( creq_dir, "content" )

    _content_str = _context_str _example_str _content_str
    _content_str = str_trim(_content_str)
    _content_str = gemini_gen_unit_str_text( jqu( _content_str ) )
    _content_str = gemini_gen_unit_str_rolepart("user", _content_str)

    _messages_str   = "\"contents\":[" _system_str _history_str _filelist_str _content_str "]"
    _use_gg_search  = GEMINI_USE_GOOGLE_SEARCH
    _tool_str       = gemini_gen_tool_str(creq_dir, _use_gg_search)

    creq_fragfile_set___usage_input_ratio_SHO( creq_dir, _system_str, _history_str, _filelist_str _content_str _tool_str )

    msgtool_obj[ "msg_str" ]  = _messages_str
    msgtool_obj[ "tool_str" ] = _tool_str
    msgtool_obj[ "provider" ] = creq_fragfile_unit___get( creq_dir, "provider" )
    msgtool_obj[ "model" ]    = creq_fragfile_unit___get( creq_dir, "model" )
}

function gemini_req_from_creq(creq_dir, chatid, hist_session_dir,       msgtool_obj, last_msgtool_obj, _msgtool, cache_msg, cache_tool, _temperature, _config, _safe_setting){

    gemini_gen_msgtool_from_creq(msgtool_obj, creq_dir, chatid, hist_session_dir)
    gemini_gen_last_msgtool_from_creq(msgtool_obj, last_msgtool_obj, chatid, hist_session_dir)
    _msgtool    = msgtool_obj[ "msg_str" ] msgtool_obj[ "tool_str" ]

    cache_msg   = chat_cal_cached( msgtool_obj[ "msg_str" ], last_msgtool_obj[ "msg_str" ] )
    cache_tool  = chat_cal_cached( msgtool_obj[ "tool_str" ], last_msgtool_obj[ "tool_str" ] )
    creq_fragfile_set___usage_input_ratio_cache( creq_dir, int(cache_msg + cache_tool), length( _msgtool ))

    _temperature    = creq_fragfile_unit___get( creq_dir, "temperature" )
    _config         = gemini_gen_generationConfig(_temperature, creq_fragfile_unit___get( creq_dir, "is_reasoning" ) )
    _safe_setting   = gemini_gen_safe_setting_str()
    return "{" _safe_setting _msgtool _config " }"
}

# extract ...
function gemini_res_to_cres(gemini_resp_o, cres_dir, creq_dir, o_tool, tool_kp,
    v, resp_kp, resp_content_kp, usage_kp, usage_prompt_kp, usage_cand_kp, usage_total_kp, usage_thought_kp, usage_cache_kp, cres_usage_kp, cres_input_kp, cres_output_kp, cres_total_kp ){

    resp_kp             = Q2_1 SUBSEP "\"candidates\"" SUBSEP "\"1\""
    resp_content_kp     = resp_kp SUBSEP "\"content\""
    usage_kp            = Q2_1 SUBSEP "\"usageMetadata\""
    usage_prompt_kp     = usage_kp SUBSEP "\"promptTokenCount\""
    usage_cand_kp       = usage_kp SUBSEP "\"candidatesTokenCount\""
    usage_total_kp      = usage_kp SUBSEP "\"totalTokenCount\""
    usage_thought_kp    = usage_kp SUBSEP "\"thoughtsTokenCount\""
    usage_cache_kp      = usage_kp SUBSEP "\"cachedContentTokenCount\""

    mkdirp( cres_dir )
    cres_fragfile_unit___set( cres_dir, "model",    juq( gemini_resp_o[ resp_content_kp SUBSEP "\"role\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "role",     juq( gemini_resp_o[ resp_content_kp SUBSEP "\"role\"" ] ) )
    cres_fragfile_unit___set( cres_dir, "content",  juq( gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"1\"" SUBSEP "\"text\"" ] ) )

    if ( o_tool[ tool_kp L ] > 0 ) {
        cres_fragfile_unit___set( cres_dir, "tool_call",            jstr( o_tool, tool_kp))
        cres_fragfile_unit___set( cres_dir, "tool_call_l",          o_tool[ tool_kp L ])
    }

    if ( gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"2\"" SUBSEP "\"thought\"" ] == "true" ) {
        cres_fragfile_unit___set( cres_dir, "reasoning_content",    juq( gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"2\"" SUBSEP "\"text\"" ] ) )
    }

    cres_fragfile_unit___set( cres_dir, "raw_usage",            jstr( gemini_resp_o, usage_kp ) )

    cres_fragfile_unit___set( cres_dir, "usage_input_token",            int(gemini_resp_o[ usage_prompt_kp ] + gemini_resp_o[ usage_cache_kp ]) )
    cres_fragfile_unit___set( cres_dir, "usage_input_cache_token",      int(gemini_resp_o[ usage_cache_kp ] ) )

    cres_fragfile_unit___set( cres_dir, "usage_output_token",           int(gemini_resp_o[ usage_cand_kp ] + gemini_resp_o[ usage_thought_kp ]) )
    cres_fragfile_unit___set( cres_dir, "usage_output_thought_token",   int(gemini_resp_o[ usage_thought_kp ]) )

    cres_fragfile_unit___set( cres_dir, "usage_total_token",            int(gemini_resp_o[ usage_total_kp ]) )
}

function gemini_gen_tool_str(creq_dir, use_google_search,          _function_str, _gg_str, _tool_str){
    _gg_str         = gemini_gen_tool_gg_str( use_google_search )
    _function_str   = gemini_gen_tool_function_str( creq_dir )

    _tool_str = _gg_str
    _tool_str = _tool_str ((_tool_str != "") ? ", " : "") _function_str
    return (_tool_str != "") ? ", \"tools\": [ " _tool_str " ]" : ""
}

function gemini_gen_tool_gg_str( use_google_search,         _res){
    if ( use_google_search == true ) {
        _res = "{ \"google_search\": {} }"
    }
    return _res
}

function gemini_gen_tool_function_str( creq_dir,            tool_str, tool_obj, tool_kp, _, _res ){
    tool_str = creq_fragfile_unit___get( creq_dir, "tool" )
    if ( chat_str_is_null(tool_str) ) return

    tool_kp = SUBSEP "tool"
    jiparse2leaf_fromstr( tool_obj, SUBSEP "tool", tool_str )

    jlist_put( _, "", "{")
    jdict_put( _, SUBSEP "\"1\"", "\"function_declarations\"", "[")
    jmerge_force___value(_, SUBSEP "\"1\"" SUBSEP "\"function_declarations\"", tool_obj, tool_kp SUBSEP "\"function\"")
    _res = jstr0(_, SUBSEP "\"1\"", " ")

    return _res
}
