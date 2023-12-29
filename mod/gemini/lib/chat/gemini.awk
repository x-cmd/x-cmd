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
function gemini_gen_promote_system_or_part_str(minion_obj, prompt_dic_name,       _kp, i, l, str){
    _kp = Q2_1 SUBSEP "\"prompt\"" S "\""prompt_dic_name"\""

    if( prompt_dic_name == "system" ) l = minion_system_len(minion_obj, Q2_1 )
    else if( prompt_dic_name == "part" ) l = minion_system_len(minion_obj, Q2_1 )

    l = minion_obj[ _kp L ]
    if( l == "" ) str = minion_obj[ _kp ]
    else {
        for (i=1; i<=l; ++i){
            if( l == 1 ) str = minion_obj[ _kp S "\"1\"" ]
            else str = str minion_obj[ _kp S "\""i"\"" ] JOINSEP
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
    promote_system_json = gemini_gen_promote_system_or_part_str( minion_obj, "system" )
    promote_part_json = gemini_gen_promote_system_or_part_str( minion_obj, "part" )

    promote_content = gemini_gen_promote_context_example_str( minion_obj )

    if ( ! chat_str_is_null(promote_content))  USER_LATEST_QUESTION = promote_content JOINSEP  question
    else USER_LATEST_QUESTION = question

    return sprintf("{\"contents\":[ %s {\"parts\":[ %s %s {\"text\": %s}],\"role\":\"user\"}]}\n", _history_str, promote_system_json, promote_part_json, jqu(USER_LATEST_QUESTION))
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

function gemini_display_response_text(gemini_resp_o,        _kp, str, code,error_message){
     # more info
    _kp = Q2_1 S "\"candidates\"" S "\"1\"" S "\"content\""

    str =  juq(gemini_resp_o[ _kp  S "\"parts\"" S "\"1\"" S "\"text\""])

    if(str == ""){
        code = gemini_resp_o[ Q2_1 S "\"error\"" S "\"code\"" ]
        error_message = juq(gemini_resp_o[ Q2_1 S "\"error\"" S "\"message\"" ])

        str = "http code: " code "error_message: "error_message

       return sprintf("http code: %s\nerror_message: %s\n", code, error_message )
    }

    return str

}