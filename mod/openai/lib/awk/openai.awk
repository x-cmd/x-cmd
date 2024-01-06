BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"
}

function openai_gen_unit_str( role, content ){
    if ( role !~ "^\"" )    role = jqu( role )
    if ( content !~ "^\"" ) content = jqu( content )
    return "{ \"role\": " role ", \"content\": " content " }"
}

function openai_gen_history_str( history_obj, i,        _text_req, _text_res, _text_finishReason ){
    _text_req = history_obj[  Q2_1 SUBSEP "\""i"\"" SUBSEP "\"creq\"" SUBSEP "\"question\""]
    _text_res = history_obj[  Q2_1 SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"reply\"" SUBSEP "\"parts\"" SUBSEP "\"1\"" SUBSEP "\"text\"" ]
    _text_finishReason = history_obj[  Q2_1 SUBSEP "\""i"\"" SUBSEP "\"cres\"" SUBSEP "\"finishReason\"" ]
    if( (_text_finishReason !~ "(STOP|stop)") || (_text_req =="") ||(_text_res == "")) return
    return  openai_gen_unit_str( "user", _text_req )", " openai_gen_unit_str( "assistant", _text_res )
}

function openai_gen_minion_content_str(minion_obj,    _kp, i, l, user, assistant, promote_content, example, promptline){
    promote_content = minion_prompt_context(minion_obj, MINION_KP )
    promote_content = ( promote_content != "" ) ? promote_content JOINSEP : ""

    _kp = MINION_KP SUBSEP "\"prompt\"" S "\"example\""
    v = minion_obj[ _kp ]
    if ( ! chat_str_is_null(v) && (v != "[") ) example = v

    l = minion_example_len(minion_obj, MINION_KP )
    for (i=1; i<=l; ++i){
        user = minion_obj[ _kp S "\""i"\"" S  "\"u\""]
        assistant = minion_obj[ _kp S "\""i"\"" S  "\"a\""]
        example = example "User: " juq(user) ";\nAssistant: " juq(assistant) "\n"
    }
    if ( example != "" )    example = "example:\n" example
    example = ( example != "" ) ? example JOINSEP : ""

    promptline = minion_prompt_promptline(minion_obj, MINION_KP)
    promptline = ( promptline != "" ) ? promptline JOINSEP : ""

    return promote_content example promptline
}

function openai_gen_minion_system_str(minion_obj,    _kp, i, l, _str, _res){
    v = minion_system( minion_obj, MINION_KP )
    if ( ! chat_str_is_null(v) && (v != "[") ) return v

    _kp = MINION_KP SUBSEP "\"prompt\"" S "\"system\""
    l = minion_system_len(minion_obj, MINION_KP )
    for (i=1; i<=l; ++i){
        _str = minion_obj[ _kp S "\""i"\""]
        if ( chat_str_is_null( _str ) ) continue
        _res = _res openai_gen_unit_str( "system", _str ) ", "
    }
    return _res
}

function openai_req_from_creq(history_obj, minion_obj, question,          i, l, str, \
    _system_str, _history_str, _minion_str, _question_str, _messages_str, _mode, _maxtoken, _seed, _temperature, _data_str){
    _system_str = openai_gen_minion_system_str(minion_obj)

    l = history_obj[ Q2_1 L ]
    for (i=1; i<=l; ++i){
        str = openai_gen_history_str(history_obj, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    _minion_str     = openai_gen_minion_content_str(minion_obj)
    _question_str   = openai_gen_unit_str( "user", _minion_str question )
    _messages_str   = _system_str _history_str _question_str

    _mode           = jqu(minion_model( minion_obj, MINION_KP ))
    _maxtoken       = minion_maxtoken( minion_obj, MINION_KP )
    _seed           = minion_seed( minion_obj, MINION_KP )
    _temperature    = minion_temperature( minion_obj, MINION_KP )

    # TODO: in some case, _maxtoken is 0, but it is not a valid value for openai. Find out why that happened in line 72
    _maxtoken       = int(_maxtoken)
    _maxtoken       = (_maxtoken > 0) ? "\"max_tokens\": " _maxtoken "," : ""

    _seed           = (_seed != "") ? "\"seed\": " int(_seed) "," : ""
    _temperature    = (_temperature != "") ? "\"temperature\": " _temperature "," : ""

    _data_str = sprintf( "{ \"model\": %s, \"messages\": [ %s ], %s%s%s \"stream\": true }", \
                    _mode, _messages_str, _maxtoken, _seed, _temperature )

    return _data_str
}

function openai_res_to_cres(openai_resp_o, cres_o, kp,          resp_kp, delta_kp, resp_content_kp, resp_role_kp ){
    kp = ((kp != "") ? kp : SUBSEP "\"1\"")
    cres_o[ kp ] = "{"

    resp_kp         = SUBSEP "\"1\"" SUBSEP "\"choices\"" SUBSEP "\"1\""
    delta_kp        = resp_kp SUBSEP "\"delta\""
    resp_content_kp = delta_kp SUBSEP "\"content\""
    resp_role_kp    = delta_kp SUBSEP "\"role\""

    cp_cover(cres_o, kp, openai_resp_o, SUBSEP "\"1\"")
    cp_cover(cres_o, kp, openai_resp_o, resp_kp)
    jdict_put( cres_o, kp, "\"finishReason\"", cres_o[ kp, "\"finish_reason\"" ] )
    jdict_put( cres_o, kp, "\"reply\"", "{" )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"role\"", openai_resp_o[ resp_role_kp ] )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"parts\"", "[" )
    jlist_put( cres_o, kp SUBSEP "\"reply\"" SUBSEP "\"parts\"", "{" )
    jdict_put( cres_o, kp SUBSEP "\"reply\"" SUBSEP "\"parts\"" SUBSEP "\"1\"", "\"text\"", openai_resp_o[ resp_content_kp ] )
    jdict_rm( cres_o, kp, "\"finish_reason\"" )
    jdict_rm( cres_o, kp, "\"choices\"" )
    jdict_rm( cres_o, kp, "\"delta\"" )
}
