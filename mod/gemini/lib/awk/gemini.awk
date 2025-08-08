BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"

    GEMINI_USE_GOOGLE_SEARCH = ENVIRON[ "use_google_search" ]
}

function gemini_gen_unit_str(str){
    if( ! chat_str_is_null(str)) {
        if (str !~ "^\"")  str = jqu(str)
        return "{\"text\":" str "} ,"
    }
}
function gemini_gen_generationConfig(temperature,         _temperature){
    _temperature    =  "\"temperature\": " temperature
    return ", \"generationConfig\": { " _temperature " }"
}

function gemini_gen_history_str( history_obj, i,      _text_res, _text_req, _text_tool, _text_finishReason) {
    _text_req = chat_history_get_req_text(history_obj,  Q2_1, i)
    _text_res = chat_history_get_res_text(history_obj,  Q2_1, i)
    _text_tool = chat_history_get_res_tool_call(history_obj, Q2_1, i)
    _text_finishReason = chat_history_get_finishReason(history_obj,  Q2_1, i)
    if( (_text_finishReason !~ "(STOP|stop|tool_calls)") || (_text_req =="") ||(_text_res == "")) return
    if ( _text_tool != "" ) {
        _text_res = (_text_res ~ "^\"" ) ? juq(_text_res) : _text_res
        _text_res = jqu( _text_res "\nfunctionCall:" _text_tool )
    }

    return "{  \"parts\": [ {\"text\":" _text_req "} ],  \"role\": \"user\" }, {  \"parts\": [ {\"text\":" _text_res "} ],  \"role\": \"model\" }"
}

function gemini_gen_minion_content_str(minion_obj,      context, example, content){
    context = minion_prompt_context(minion_obj, MINION_KP)
    context = (context != "") ? context JOINSEP : ""

    example = minion_example_tostr(minion_obj, MINION_KP)
    content = minion_prompt_content(minion_obj, MINION_KP)

    return context example content
}

function gemini_gen_safe_setting_str(             _safe_setting){
    _safe_setting = "\"safetySettings\": [     {       \"category\": \"HARM_CATEGORY_SEXUALLY_EXPLICIT\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     },     {       \"category\": \"HARM_CATEGORY_HATE_SPEECH\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     },     {       \"category\": \"HARM_CATEGORY_HARASSMENT\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     },     {       \"category\": \"HARM_CATEGORY_DANGEROUS_CONTENT\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     }    ],"
    gsub(/BLOCK_ONLY_HIGH/, "BLOCK_NONE", _safe_setting) # BLOCK_ONLY_HIGH
    return _safe_setting
}

function gemini_req_from_creq(history_obj, minion_obj, question, creq_obj, creq_kp,         str, i, l, _history_str, promote_content, \
    promote_system_json, _filelist_str, _safe_setting, _temperature, _config, _media_str, _tool_str, _use_google_search ){
    l = chat_history_get_maxnum(history_obj, Q2_1)
    for (i=1; i<=l; ++i){
        str = gemini_gen_history_str(history_obj, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    promote_content = gemini_gen_minion_content_str( minion_obj )

    promote_system_json = minion_system_tostr(minion_obj, MINION_KP)
    if (promote_system_json != "") promote_system_json = gemini_gen_unit_str(promote_system_json)

    _filelist_str = minion_filelist_attach( minion_obj, MINION_KP)
    if (_filelist_str != "") _filelist_str = gemini_gen_unit_str(_filelist_str)

    _temperature    = minion_temperature( minion_obj, MINION_KP )
    if (_temperature != "") _config = gemini_gen_generationConfig(_temperature)


    if ( ! chat_str_is_null(promote_content))  USER_LATEST_QUESTION = promote_content
    else USER_LATEST_QUESTION = question

    _safe_setting   = gemini_gen_safe_setting_str()

    _use_google_search = GEMINI_USE_GOOGLE_SEARCH
    _tool_str       = gemini_gen_tool_str(creq_obj, creq_kp, _use_google_search)

    _media_str      = gemini_gen_media_str(creq_obj, creq_kp)

    return "{" _safe_setting " \"contents\":[ " _history_str " {\"parts\":[ " promote_system_json " " _filelist_str " {\"text\": " jqu(USER_LATEST_QUESTION) "} " _media_str " ],\"role\":\"user\"}] " _config  _tool_str " }\n"
}

# extract ...
function gemini_res_to_cres(gemini_resp_o, cres_o, kp, o_tool, tool_kp,             v, resp_kp, resp_content_kp, usage_kp, usage_prompt_kp, usage_cand_kp, usage_total_kp){
    kp = ((kp != "") ? kp : Q2_1)
    cres_o[ kp ] = "{"

    resp_kp = Q2_1 SUBSEP "\"candidates\"" SUBSEP "\"1\""
    resp_content_kp = resp_kp SUBSEP "\"content\""
    usage_kp = Q2_1 SUBSEP "\"usageMetadata\""
    usage_prompt_kp = usage_kp SUBSEP "\"promptTokenCount\""
    usage_cand_kp   = usage_kp SUBSEP "\"candidatesTokenCount\""
    usage_total_kp  = usage_kp SUBSEP "\"totalTokenCount\""
    usage_thought_kp  = usage_kp SUBSEP "\"thoughtsTokenCount\""

    jdict_put( cres_o, kp, "\"reply\"", "{" )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"role\"", gemini_resp_o[ resp_content_kp SUBSEP "\"role\"" ] )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"content\"", gemini_resp_o[ resp_content_kp SUBSEP "\"parts\"" SUBSEP "\"1\"" SUBSEP "\"text\"" ] )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"tool_calls\"", "[" )
    jmerge_force___value( cres_o, kp SUBSEP "\"reply\"" SUBSEP "\"tool_calls\"", o_tool, tool_kp )

    if ( (v = gemini_resp_o[ resp_kp SUBSEP "\"finishReason\"" ]) != "" )
        jdict_put( cres_o, kp, "\"finishReason\"", v )
    if ( (v = gemini_resp_o[ resp_kp SUBSEP "\"index\""  ])  != "" )
        jdict_put( cres_o, kp, "\"index\"", v )

    jdict_put( cres_o, kp, "\"usage\"", "{" )
    if ( (v = gemini_resp_o[ usage_prompt_kp ]) != "" )
        jdict_put( cres_o, kp SUBSEP "\"usage\"", "\"prompt_tokens\"", v )
    if ( (v = gemini_resp_o[ usage_cand_kp ]) != "" )
        jdict_put( cres_o, kp SUBSEP "\"usage\"", "\"completion_tokens\"", v )
    if ( (v = gemini_resp_o[ usage_total_kp ]) != "" )
        jdict_put( cres_o, kp SUBSEP "\"usage\"", "\"total_tokens\"", v )
    if ( (v = gemini_resp_o[ usage_thought_kp ]) != "" )
        jdict_put( cres_o, kp SUBSEP "\"usage\"", "\"thought_tokens\"", v )

    if ( (v = gemini_resp_o[ Q2_1 SUBSEP "\"modelVersion\"" ]) != "" )
        jdict_put( cres_o, kp, "\"model\"", v )
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
            _type_msg = "image/" msg
        }

        if ( _url != "" ) {
            _str    = _str ",{ \"inline_data\": { \"mime_type\": "_type", \"data\" : "jqu(_url)" } }"
        } else {
            _msg    = _type_msg juq(creq_obj[ _kp_key, "\"msg\"" ])
            _base64 = juq(creq_obj[ _kp_key, "\"base64\"" ])
            _str    = _str ",{ \"inline_data\": { \"mime_type\": "jqu(_type_msg)", \"data\" : "jqu(_base64)" } }"
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
