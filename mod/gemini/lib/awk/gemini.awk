BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"

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

function gemini_gen_history_str( history_obj, chatid, i,      _text_res, _text_req, _text_tool, _res) {
    _text_req = chat_history_get_req_text(history_obj, chatid, i)
    _text_res = chat_history_get_res_text(history_obj, chatid, i)
    _text_tool = chat_history_get_res_tool_call(history_obj, chatid, i)
    if( _text_req == "" ) return
    if ( _text_tool != "" ) {
        _text_res = (_text_res ~ "^\"" ) ? juq(_text_res) : _text_res
        _text_res = jqu( _text_res "\nfunctionCall:" _text_tool )
    }

    _text_req = gemini_gen_unit_str_rolepart("user",  gemini_gen_unit_str_text(_text_req))
    _res = _text_req
    if ( ! chat_str_is_null( _text_res ) ) {
        _res = _res "," gemini_gen_unit_str_rolepart("model", gemini_gen_unit_str_text(_text_res))
    }

    return _res
}

function gemini_gen_minion_content_str(minion_obj, minion_kp, media_str,     context, example, content){
    context = minion_prompt_context(minion_obj, minion_kp)
    context = (context != "") ? context JOINSEP : ""

    example = minion_example_tostr(minion_obj, minion_kp)
    content = minion_prompt_content(minion_obj, minion_kp)
    str = context example content
    str = str_trim(str)

    return gemini_gen_unit_str_text( jqu( str ) ) media_str
}

function gemini_gen_safe_setting_str(             _safe_setting){
    _safe_setting = "\"safetySettings\": [{\"category\": \"HARM_CATEGORY_SEXUALLY_EXPLICIT\",\"threshold\": \"BLOCK_ONLY_HIGH\"},{\"category\": \"HARM_CATEGORY_HATE_SPEECH\",\"threshold\": \"BLOCK_ONLY_HIGH\"},{\"category\": \"HARM_CATEGORY_HARASSMENT\",\"threshold\": \"BLOCK_ONLY_HIGH\"},{\"category\": \"HARM_CATEGORY_DANGEROUS_CONTENT\",\"threshold\": \"BLOCK_ONLY_HIGH\"}],"
    gsub(/BLOCK_ONLY_HIGH/, "BLOCK_NONE", _safe_setting) # BLOCK_ONLY_HIGH
    return _safe_setting
}

function gemini_gen_last_msgtool_from_creq( current_msgtool_obj, msgtool_obj, chatid, hist_session_dir,            last_chatid, last_creq_obj, last_creq_kp ){
    last_chatid = chat_history_get_last_chatid(hist_session_dir, juq(current_msgtool_obj[ "provider" ]), chatid)
    if ( last_chatid == "" ) return
    last_creq_kp = SUBSEP "last-creq"
    chat_history_get_last_creq( last_creq_obj, last_creq_kp, hist_session_dir, provider, chatid, last_chatid )

    if ( (current_msgtool_obj[ "provider" ] != last_creq_obj[ last_creq_kp, "\"provider\"" ]) || (current_msgtool_obj[ "model" ] != last_creq_obj[ last_creq_kp, "\"model\"" ]) ) return
    return gemini_gen_msgtool_from_creq( msgtool_obj, last_creq_obj, last_creq_kp, last_chatid, hist_session_dir )
}

function gemini_gen_msgtool_from_creq( msgtool_obj, creq_obj, creq_kp, chatid, hist_session_dir,                history_obj, history_num, i, l, str, \
    _history_str, _creq_minion_kp, _system_str, _content_str, _media_str, _messages_str, _use_gg_search, _tool_str ){
    history_num = creq_obj[ creq_kp S "\"history_num\"" ]
    chat_history_load( history_obj, chatid, hist_session_dir, history_num)
    l = chat_history_get_maxnum(history_obj, chatid)
    for (i=1; i<=l; ++i){
        str = gemini_gen_history_str(history_obj, chatid, i)
        if (str != "") _history_str = _history_str str ","
    }

    _creq_minion_kp = creq_kp SUBSEP "\"minion\""
    _system_str = minion_system_tostr(creq_obj, _creq_minion_kp)
    if (_system_str != "") _system_str = gemini_gen_unit_str_rolepart("user", gemini_gen_unit_str_text(_system_str)) ","

    _media_str      = gemini_gen_media_str(creq_obj, creq_kp)
    _content_str    = gemini_gen_minion_content_str( creq_obj, _creq_minion_kp, _media_str )
    _content_str    = gemini_gen_unit_str_rolepart("user", _content_str)

    _messages_str   = "\"contents\":[" _history_str _system_str _content_str "]"
    _use_gg_search  = GEMINI_USE_GOOGLE_SEARCH
    _tool_str       = gemini_gen_tool_str(creq_obj, creq_kp, _use_gg_search)
    creq_append_usage_input_ratio_SHO( creq_obj, creq_kp, _system_str, _history_str, _content_str _tool_str )
    msgtool_obj[ "msg_str" ]  = _messages_str
    msgtool_obj[ "tool_str" ] = _tool_str
    msgtool_obj[ "provider" ] = creq_obj[ creq_kp, "\"provider\"" ]
    msgtool_obj[ "model" ]    = creq_obj[ creq_kp, "\"model\"" ]
}

function gemini_req_from_creq(creq_obj, creq_kp, chatid, hist_session_dir,       msgtool_obj, last_msgtool_obj, cache_msg, cache_tool, _msgtool, _creq_minion_kp, _safe_setting, _config, _temperature){

    gemini_gen_msgtool_from_creq(msgtool_obj, creq_obj, creq_kp, chatid, hist_session_dir)
    gemini_gen_last_msgtool_from_creq(msgtool_obj, last_msgtool_obj, chatid, hist_session_dir)
    _msgtool    = msgtool_obj[ "msg_str" ] msgtool_obj[ "tool_str" ]

    cache_msg   = chat_cal_cached( msgtool_obj[ "msg_str" ], last_msgtool_obj[ "msg_str" ] )
    cache_tool  = chat_cal_cached( msgtool_obj[ "tool_str" ], last_msgtool_obj[ "tool_str" ] )
    creq_append_usage_input_ratio_cache( creq_obj, creq_kp, int(cache_msg + cache_tool), length( _msgtool ))

    _creq_minion_kp = creq_kp SUBSEP "\"minion\""
    _temperature    = minion_temperature( creq_obj, _creq_minion_kp )
    _config         = gemini_gen_generationConfig(_temperature, creq_obj[ creq_kp, "\"is_reasoning\"" ] )
    _safe_setting   = gemini_gen_safe_setting_str()
    return "{" _safe_setting _msgtool _config " }"
}

# extract ...
function gemini_res_to_cres(gemini_resp_o, cres_obj, cres_kp, creq_obj, creq_kp, o_tool, tool_kp,
    v, resp_kp, resp_content_kp, usage_kp, usage_prompt_kp, usage_cand_kp, usage_total_kp, usage_thought_kp, usage_cache_kp, cres_usage_kp, cres_input_kp, cres_output_kp, cres_total_kp ){
    cres_kp = ((cres_kp != "") ? cres_kp : Q2_1)
    cres_obj[ cres_kp ] = "{"

    resp_kp             = Q2_1 SUBSEP "\"candidates\"" SUBSEP "\"1\""
    resp_content_kp     = resp_kp SUBSEP "\"content\""
    usage_kp            = Q2_1 SUBSEP "\"usageMetadata\""
    usage_prompt_kp     = usage_kp SUBSEP "\"promptTokenCount\""
    usage_cand_kp       = usage_kp SUBSEP "\"candidatesTokenCount\""
    usage_total_kp      = usage_kp SUBSEP "\"totalTokenCount\""
    usage_thought_kp    = usage_kp SUBSEP "\"thoughtsTokenCount\""
    usage_cache_kp    = usage_kp SUBSEP "\"cachedContentTokenCount\""

    jdict_put( cres_obj, cres_kp, "\"reply\"", "{" )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"role\"", gemini_resp_o[ resp_content_kp SUBSEP "\"role\"" ] )
    jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"content\"", gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"1\"" SUBSEP "\"text\"" ] )
    if ( o_tool[ tool_kp L ] > 0 ) {
        jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"tool_calls\"", "[" )
        jmerge_force___value( cres_obj, cres_kp SUBSEP "\"reply\"" SUBSEP "\"tool_calls\"", o_tool, tool_kp )
    }

    if ( gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"2\"" SUBSEP "\"thought\"" ] == "true" ) {
        jdict_put( cres_obj, cres_kp SUBSEP "\"reply\"", "\"reasoning_content\"", gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"2\"" SUBSEP "\"text\"" ] )
    }

    if ( (v = gemini_resp_o[ resp_kp SUBSEP "\"finishReason\"" ]) != "" )
        jdict_put( cres_obj, cres_kp, "\"finishReason\"", v )
    if ( (v = gemini_resp_o[ resp_kp SUBSEP "\"index\""  ])  != "" )
        jdict_put( cres_obj, cres_kp, "\"index\"", v )

    if ( (v = gemini_resp_o[ Q2_1 SUBSEP "\"modelVersion\"" ]) != "" )
        jdict_put( cres_obj, cres_kp, "\"model\"", v )

    # input output total
    jdict_put( cres_obj, cres_kp, "\"raw_usage\"", "{" )
    jmerge_force___value( cres_obj, cres_kp SUBSEP "\"raw_usage\"", gemini_resp_o, usage_kp )
    jdict_put( cres_obj, cres_kp, "\"usage\"", "{" )
    cres_usage_kp   = cres_kp SUBSEP "\"usage\""

    jdict_put( cres_obj, cres_usage_kp, "\"input\"",    "{" )
    cres_input_kp   = cres_usage_kp SUBSEP "\"input\""
    jdict_put( cres_obj, cres_input_kp, "\"tokens\"",           int(gemini_resp_o[ usage_prompt_kp ] + gemini_resp_o[ usage_cache_kp ]) )
    jdict_put( cres_obj, cres_input_kp, "\"cache_token\"",      int(gemini_resp_o[ usage_cache_kp ] ) )

    jdict_put( cres_obj, cres_usage_kp, "\"output\"",   "{" )
    cres_output_kp  = cres_usage_kp SUBSEP "\"output\""
    jdict_put( cres_obj, cres_output_kp, "\"tokens\"",          int(gemini_resp_o[ usage_cand_kp ] + gemini_resp_o[ usage_thought_kp ]) )
    jdict_put( cres_obj, cres_output_kp, "\"thought_tokens\"",  int(gemini_resp_o[ usage_thought_kp ]) )

    jdict_put( cres_obj, cres_usage_kp, "\"total\"",    "{" )
    cres_total_kp   = cres_usage_kp SUBSEP "\"total\""
    jdict_put( cres_obj, cres_total_kp, "\"tokens\"",           int(gemini_resp_o[ usage_total_kp ]) )

    # creq token ratio
    usage_kp = creq_kp SUBSEP "\"usage\""
    if ( creq_obj[ usage_kp ] == "{" ) jmerge_force___value( cres_obj, cres_kp SUBSEP "\"usage\"", creq_obj, usage_kp )

    jdict_put( cres_obj, cres_kp, "\"provider\"", creq_obj[ creq_kp, "\"provider\"" ]  )

}

function gemini_parse_response(gemini_resp_o, ret_o,        _kp, str, code){
    _kp = Q2_1 S "\"candidates\"" S "\"1\"" S "\"content\""

    str =  juq(gemini_resp_o[ _kp  S "\"parts\"" S "\"1\"" S "\"text\""])
    code = gemini_resp_o[ Q2_1 S "\"error\"" S "\"code\"" ]
    ret_o[ "text" ] = str
    ret_o[ "code" ] = code
}


function gemini_gen_media_str(creq_obj, creq_kp,      _kp_media, i, l, _type, _url, _kp_key, _type_msg, _str, _msg, _base64){
    _kp_media = creq_kp SUBSEP "\"media\""
    l = creq_obj[ _kp_media L ]
    if (l <= 0) return
    for (i=1; i<=l; ++i){
        _kp_key = _kp_media SUBSEP "\""i"\""
        _type   = creq_obj[ _kp_key, "\"type\"" ]
        _url    = creq_obj[ _kp_key, "\"url\"" ]
        if ( _type == "\"image\"" ) {
            _type = "\"image_url\""
            _type_msg = "image/"
        }

        if ( _url != "" ) {
            _str    = _str ",{ \"inline_data\": { \"mime_type\": "_type", \"data\" : "jqu(_url)" } }"
        } else {
            _base64 = juq(creq_obj[ _kp_key, "\"base64\"" ])
            _msg    = juq(creq_obj[ _kp_key, "\"msg\"" ])
            _msg    = _type_msg _msg
            _str    = _str ",{ \"inline_data\": { \"mime_type\": "jqu(_msg)", \"data\" : "jqu(_base64)" } }"
        }

    }
    return _str
}

function gemini_gen_tool_str(creq_obj, creq_kp, use_google_search,          _function_str, _gg_str, _tool_str){
    _gg_str         = gemini_gen_tool_gg_str( use_google_search )
    _function_str   = gemini_gen_tool_function_str( creq_obj, creq_kp )

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

function gemini_gen_tool_function_str( creq_obj, creq_kp,       _kp_tool_function, l, _res){
    _kp_tool_function = creq_kp SUBSEP "\"tool\"" SUBSEP "\"function\""
    l = creq_obj[ _kp_tool_function L ]
    if (l <= 0) return ""

    jlist_put( _, "", "{")
    jdict_put( _, SUBSEP "\"1\"", "\"function_declarations\"", "[")
    jmerge_force___value(_, SUBSEP "\"1\"" SUBSEP "\"function_declarations\"", creq_obj, _kp_tool_function)
    _res = jstr0(_, SUBSEP "\"1\"", " ")

    return _res
}
