BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"
}
# req_json = creq
function gemini_gen_history_str( history_obj, minion_obj, i,      _text_res, _text_req) {

    _text_req = history_obj[  Q2_1 SUBSEP "\""i"\"" SUBSEP "\"creq\"" SUBSEP "\"question\""]
    _text_res = history_obj[  Q2_1 SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"reply\"" SUBSEP "\"parts\"" SUBSEP "\"1\"" SUBSEP "\"text\"" ]
    # TODO: finishReason
    if(( _text_req =="") ||(_text_res == "")) return

    return "{  \"parts\": [ {\"text\":" _text_req "}],  \"role\": \"user\" }, {  \"parts\": [ {\"text\":" _text_res "}],  \"role\": \"model\" }"
}

function gemini_gen_promote_part_str(minion_obj,       _kp, i, l, str){
    v = minion_part( minion_obj, MINION_KP )
    if ( ! chat_str_is_null(v) && (v != "[") ) str = v
    else {
        _kp = MINION_KP SUBSEP "\"prompt\"" S "\"part\""
        l = minion_part_len(minion_obj, MINION_KP )
        for (i=1; i<=l; ++i){
            str = str minion_obj[ _kp S "\""i"\"" ] JOINSEP
        }
    }

    if( ! chat_str_is_null(str)) {
        if ( str !~ "^\"" )  str = jqu(str)
        return sprintf("{\"text\": %s} ," , str)
    }
}

function gemini_gen_promote_system_str(minion_obj,       _kp, i, l, str){
    v = minion_system( minion_obj, MINION_KP )
    if ( ! chat_str_is_null(v) && (v != "[") ) str = v
    else {
        _kp = MINION_KP SUBSEP "\"prompt\"" S "\"system\""
        l = minion_system_len(minion_obj, MINION_KP )
        for (i=1; i<=l; ++i){
            str minion_obj[ _kp S "\""i"\"" ] JOINSEP
        }
    }

    if( ! chat_str_is_null(str)) {
        if ( str !~ "^\"" )  str = jqu(str)
        return sprintf("{\"text\": %s} ," , str)
    }
}

function gemini_gen_promote_context_example_str(minion_obj,     _kp, i, l, user, assistant, promote_content, example, promptline){
    promote_content =  minion_prompt_context( minion_obj, Q2_1 )
     if ( ! chat_str_is_null(promote_content)) promote_content = promote_content " ;"
    l = minion_example_len(minion_obj, Q2_1 )

    _kp = Q2_1 SUBSEP "\"prompt\"" S "\"example\""
    for (i=1; i<=l; ++i){
        user = minion_obj[ _kp S "\""i"\"" S  "\"a\""]
        assistant = minion_obj[ _kp S "\""i"\"" S  "\"u\""]
        if (( chat_str_is_null(user)) &&  ( chat_str_is_null(assistant) )) continue
        example = example "User: " user ";" "Assistant: " assistant JOINSEP
    }
    if ( ! chat_str_is_null(example)) example = "Example: " example ";"

    _kp = Q2_1 SUBSEP "\"prompt\"" S "\"promptline\""
    promptline = minion_prompt_promptline(minion_obj, Q2_1)
    if ( ! chat_str_is_null(promptline)) promote_content = promptline " ;"
    return sprintf("%s%s%s", promote_content, example, promptline)
}


function gemini_req_from_creq(history_obj, minion_obj, question,         str, i, l, _history_str, promote_content, promote_system_json, promote_part_json){
    l = history_obj[ Q2_1 L ]
    for (i=1; i<=l; ++i){
        str = gemini_gen_history_str(history_obj, minion_obj, i)
        if(str != "") _history_str = _history_str str " ,"
    }
    promote_system_json = gemini_gen_promote_system_str( minion_obj )
    promote_part_json = gemini_gen_promote_part_str( minion_obj )

    promote_content = gemini_gen_promote_context_example_str( minion_obj )

    if ( ! chat_str_is_null(promote_content))  USER_LATEST_QUESTION = promote_content JOINSEP  question
    else USER_LATEST_QUESTION = question

    _safe_setting = "\"safetySettings\": [     {       \"category\": \"HARM_CATEGORY_SEXUALLY_EXPLICIT\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     },     {       \"category\": \"HARM_CATEGORY_HATE_SPEECH\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     },     {       \"category\": \"HARM_CATEGORY_HARASSMENT\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     },     {       \"category\": \"HARM_CATEGORY_DANGEROUS_CONTENT\",       \"threshold\": \"BLOCK_ONLY_HIGH\"     }    ]"
    gsub(/BLOCK_ONLY_HIGH/, "BLOCK_NONE", _safe_setting) # BLOCK_ONLY_HIGH, BLOCK_ONLY_HIGH

    return sprintf("{ %s, \"contents\":[ %s {\"parts\":[ %s %s {\"text\": %s}],\"role\":\"user\"}]}\n", _safe_setting, _history_str, promote_system_json, promote_part_json, jqu(USER_LATEST_QUESTION))
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
