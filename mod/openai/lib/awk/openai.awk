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

function openai_gen_minion_content_str(minion_obj, minion_kp, media_str,      context, example, content){
    context = minion_prompt_context(minion_obj, minion_kp)
    context = ( context != "" ) ? context JOINSEP : ""

    example = minion_example_tostr(minion_obj, minion_kp)
    content = minion_prompt_content(minion_obj, minion_kp)
    content = context example content

    if( media_str != "" ){
        return "{ \"role\": \"user\", \"content\": [ { \"type\": \"text\", \"text\": " jqu(content) " } " media_str " ] }"
    }
    return openai_gen_unit_str( "user", content )

}

function openai_gen_media_str(creq_obj, creq_kp,        _kp_media, i, l, _kp_key, _type, _url, _type_msg, _base64, _msg, _str){
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
            _str    = _str ",{ \"type\": " _type ", \"image_url\": { \"url\": " jqu(_url) " } }"
        } else {
            _base64 = juq(creq_obj[ _kp_key, "\"base64\"" ])
            _msg    = juq(creq_obj[ _kp_key, "\"msg\"" ])
            _msg    = "data:" _type_msg _msg ";base64,{" _base64 "}"
            _str    = _str ",{ \"type\": " _type ", \"image_url\": { \"url\": " jqu( _msg ) " } }"
        }

    }
    return _str
}

function openai_req_from_creq(history_obj, minion_obj, minion_kp, creq_obj, creq_kp, def_model,          i, l, str, \
    _system_str, _history_str, _content_str, _messages_str, _mode, _jsonmode, _maxtoken_keyname, _maxtoken, _seed, _temperature, _ctx, _data_str){
    l = chat_history_get_maxnum(history_obj, Q2_1)
    for (i=1; i<=l; ++i){
        str = openai_gen_history_str(history_obj, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    _system_str = minion_system_tostr(minion_obj, minion_kp)
    if (_system_str != "") _system_str = openai_gen_unit_str( "system", _system_str ) " ,"

    _filelist_str   = minion_filelist_attach( minion_obj, minion_kp )
    if (_filelist_str != "") _filelist_str = openai_gen_unit_str( "user", _filelist_str) " ,"

    _media_str      = openai_gen_media_str(creq_obj, creq_kp)
    _content_str    = openai_gen_minion_content_str(minion_obj, minion_kp, _media_str)
    _messages_str   = _history_str _system_str _filelist_str _content_str

    _mode           = jqu(minion_model( minion_obj, minion_kp, def_model ))
    _maxtoken       = minion_maxtoken( minion_obj, minion_kp )
    _seed           = minion_seed( minion_obj, minion_kp )
    _temperature    = minion_temperature( minion_obj, minion_kp )
    _jsonmode       = minion_is_jsonmode( minion_obj, minion_kp )
    _ctx            = minion_ctx( minion_obj, minion_kp )

    # Tip:
    #   in some case, _maxtoken is 0, but it is not a valid value for openai.
    #   in openai, 'max_tokens' is now deprecated in favor of 'max_completion_tokens', and is not compatible with o1 series models.
    if ( PROVIDER_NAME == "openai" ) {
        _maxtoken_keyname = "\"max_completion_tokens\""
    } else {
        _maxtoken_keyname = "\"max_tokens\""
    }

    _maxtoken       = (_maxtoken > 0) ? _maxtoken_keyname ": " _maxtoken "," : ""
    _seed           = (_seed != "") ? "\"seed\": " int(_seed) "," : ""
    _temperature    = (_temperature != "") ? "\"temperature\": " _temperature "," : ""
    _ctx            = (_ctx != "") ? "\"num_ctx\": " _ctx "," : ""
    _jsonmode       = (_jsonmode) ? "\"response_format\": { \"type\": \"json_object\" }," : ""

    _data_str = "{ \"model\": " _mode " , \"messages\": [ " _messages_str " ], " _jsonmode _maxtoken _seed _temperature _ctx " \"stream\": true }"

    return _data_str
}

function openai_res_to_cres(openai_resp_o, cres_o, kp,          resp_kp, delta_kp, resp_content_kp, resp_role_kp ){
    if ( PROVIDER_NAME == "ollama" ) {
        openai_res_to_cres___ollama_format(openai_resp_o, cres_o, kp)
        return
    }

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

function openai_res_to_cres___ollama_format(ollama_resp_o, cres_o, kp,          resp_kp){
    kp = ((kp != "") ? kp : SUBSEP "\"1\"")
    cres_o[ kp ] = "{"

    reply_kp = Q2_1 SUBSEP "\"reply\""
    model_kp = Q2_1 SUBSEP "\"model\""
    msg_kp = Q2_1 SUBSEP "\"message\"" SUBSEP "\"content\""

    cp_cover(cres_o, kp, ollama_resp_o, SUBSEP "\"1\"")


    jdict_put( cres_o, kp, "\"reply\"", "{" )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"role\"", ollama_resp_o[ model_kp ] )
    jdict_put( cres_o, kp SUBSEP "\"reply\"", "\"parts\"", "[" )
    jlist_put( cres_o, kp SUBSEP "\"reply\"" SUBSEP "\"parts\"", "{" )
    jdict_put( cres_o, kp SUBSEP "\"reply\"" SUBSEP "\"parts\"" SUBSEP "\"1\"", "\"text\"", ollama_resp_o[ msg_kp ] )

    jdict_rm( cres_o, kp, "\"message\"" )
}
