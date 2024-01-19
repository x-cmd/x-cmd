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
    _text_req = chat_history_get_req_text(history_obj,  Q2_1, i)
    _text_res = chat_history_get_res_text(history_obj,  Q2_1, i)
    _text_finishReason = chat_history_get_finishReason(history_obj,  Q2_1, i)
    if( (_text_finishReason !~ "(STOP|stop)") || (_text_req =="") ||(_text_res == "")) return
    return  openai_gen_unit_str( "user", _text_req )", " openai_gen_unit_str( "assistant", _text_res )
}

function openai_gen_minion_content_str(minion_obj, minion_kp,      context, example, content){
    context = minion_prompt_context(minion_obj, minion_kp)
    context = ( context != "" ) ? context JOINSEP : ""

    example = minion_example_tostr(minion_obj, minion_kp)
    content = minion_prompt_content(minion_obj, minion_kp)

    return openai_gen_unit_str( "user", context example content )
}

function openai_req_from_creq(history_obj, minion_obj, minion_kp,          i, l, str, \
    _system_str, _history_str, _content_str, _messages_str, _mode, _jsonmode, _maxtoken, _seed, _temperature, _data_str){
    l = chat_history_get_maxnum(history_obj, Q2_1)
    for (i=1; i<=l; ++i){
        str = openai_gen_history_str(history_obj, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    _system_str = minion_system_tostr(minion_obj, minion_kp)
    if (_system_str != "") _system_str = openai_gen_unit_str( "system", _system_str ) " ,"

    _filelist_str   = minion_filelist_attach( minion_obj, minion_kp )
    if (_filelist_str != "") _filelist_str = openai_gen_unit_str( "user", _filelist_str) " ,"

    _content_str    = openai_gen_minion_content_str(minion_obj, minion_kp)
    _messages_str   = _history_str _system_str _filelist_str _content_str

    _mode           = jqu(minion_model( minion_obj, minion_kp ))
    _maxtoken       = minion_maxtoken( minion_obj, minion_kp )
    _seed           = minion_seed( minion_obj, minion_kp )
    _temperature    = minion_temperature( minion_obj, minion_kp )
    _jsonmode       = minion_is_jsonmode( minion_obj, minion_kp )

    # TODO: in some case, _maxtoken is 0, but it is not a valid value for openai. Find out why that happened in line 72
    _maxtoken       = (_maxtoken > 0) ? "\"max_tokens\": " _maxtoken "," : ""
    _seed           = (_seed != "") ? "\"seed\": " int(_seed) "," : ""
    _temperature    = (_temperature != "") ? "\"temperature\": " _temperature "," : ""
    _jsonmode       = (_jsonmode) ? "\"response_format\": { \"type\": \"json_object\" }," : ""

    _data_str = sprintf( "{ \"model\": %s, \"messages\": [ %s ], %s \"stream\": true }", \
                    _mode, _messages_str, _jsonmode _maxtoken _seed _temperature )

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
