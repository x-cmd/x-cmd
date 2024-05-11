BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"
}

function gemini_gen_unit_str(str){
    if( ! chat_str_is_null(str)) {
        if (str !~ "^\"")  str = jqu(str)
        return sprintf("{\"text\": %s} ," , str)
    }
}
function gemini_gen_generationConfig(temperature,         _temperature){
    _temperature    =  "\"temperature\": " temperature
    return ", \"generationConfig\": { " _temperature " }"
}

function gemini_gen_history_str( history_obj, i,      _text_res, _text_req, _text_finishReason) {
    _text_req = chat_history_get_req_text(history_obj,  Q2_1, i)
    _text_res = chat_history_get_res_text(history_obj,  Q2_1, i)
    _text_finishReason = chat_history_get_finishReason(history_obj,  Q2_1, i)
    if( (_text_finishReason !~ "(STOP|stop)") || (_text_req =="") ||(_text_res == "")) return
    return "{  \"parts\": [ {\"text\":" _text_req "}],  \"role\": \"user\" }, {  \"parts\": [ {\"text\":" _text_res "}],  \"role\": \"model\" }"
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
    gsub(/BLOCK_ONLY_HIGH/, "BLOCK_NONE", _safe_setting) # BLOCK_ONLY_HIGH, BLOCK_ONLY_HIGH
    return _safe_setting
}

function gemini_req_from_creq(history_obj, minion_obj, question,         str, i, l, _history_str, promote_content, \
    promote_system_json, _filelist_str, _safe_setting, _temperature, config ){
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
    if (_temperature != "") config = gemini_gen_generationConfig(_temperature)

    if ( ! chat_str_is_null(promote_content))  USER_LATEST_QUESTION = promote_content
    else USER_LATEST_QUESTION = question

    _safe_setting = gemini_gen_safe_setting_str()

    return sprintf("{ %s \"contents\":[ %s {\"parts\":[ %s %s {\"text\": %s}],\"role\":\"user\"}] %s }\n", \
        _safe_setting, _history_str, promote_system_json, _filelist_str, jqu(USER_LATEST_QUESTION), config)
}

# extract ...
function gemini_res_to_cres(gemini_resp_o, cres_o, kp,      v, resp_kp ){
    kp = ((kp != "") ? kp : Q2_1)
    cres_o[ kp ] = "{"

    resp_kp = Q2_1 SUBSEP "\"candidates\"" SUBSEP "\"1\""

    jdict_put( cres_o, kp, "\"reply\"", "\"\"" )
    cp_cover( cres_o, kp SUBSEP "\"reply\"", gemini_resp_o,  resp_kp SUBSEP "\"content\""  )

    v = gemini_resp_o[ resp_kp SUBSEP "\"finishReason\""  ]
    jdict_put( cres_o, kp, "\"finishReason\"", ( (v == "" )   ? "\"\"" : v) )

    v = gemini_resp_o[ resp_kp SUBSEP "\"index\""  ]
    jdict_put( cres_o, kp, "\"index\"",        ( (v == "" )   ? "\"\"" : v) )
}

function gemini_parse_response(gemini_resp_o, ret_o,        _kp, str, code){
    _kp = Q2_1 S "\"candidates\"" S "\"1\"" S "\"content\""

    str =  juq(gemini_resp_o[ _kp  S "\"parts\"" S "\"1\"" S "\"text\""])
    code = gemini_resp_o[ Q2_1 S "\"error\"" S "\"code\"" ]
    ret_o[ "text" ] = str
    ret_o[ "code" ] = code
}
