BEGIN{
    Q2_1 = SUBSEP "\"1\""
    JOINSEP = "\n\n"
}

function ollama_gen_unit_str( content ){
    if ( content !~ "^\"" ) content = jqu( content )
    return "{ \"role\": \"user\" , \"content\": " content " }"
}

function ollama_gen_history_str(history_obj, i,        _text_req, _text_res){
    _text_req = chat_history_get_req_text(history_obj,  Q2_1, i)
    _text_res = chat_history_get_res_text(history_obj,  Q2_1, i)
    if((_text_req =="") ||(_text_res == "")) return
    return "{\"role\": \"user\" , \"content\":" _text_req "}, {\"role\": \"assistant\" , \"content\":" _text_res "}"
}

function ollama_gen_options_str(seed, temperature, num_ctx,    _str){
    if( (seed == "") && (temperature == "") && (num_ctx == "")) return
    if( seed != "") _str = "\"seed\":"  seed
    if( temperature != "") _str = _str ", \"temperature\": " temperature
    if( num_ctx != "") _str = _str ", \"num_ctx\": " num_ctx

    return ", \"options\" : {" _str "}"

}

function ollama_gen_minion_content_str(minion_obj, minion_kp,      context, example, content){
    context = minion_prompt_context(minion_obj, minion_kp)
    context = ( context != "" ) ? context JOINSEP : ""

    example = minion_example_tostr(minion_obj, minion_kp)
    content = minion_prompt_content(minion_obj, minion_kp)

    return ollama_gen_unit_str( context example content )
}

function ollama_req_from_creq(history_obj, minion_obj, minion_kp,          i, l, str, _history_str, _system_str, \
_filelist_str, _content_str, _messages_str, _mode, _seed, _temperature, _option_str, _data_str, _num_ctx){
    l = chat_history_get_maxnum(history_obj, Q2_1)
    for (i=1; i<=l; ++i){
        str = ollama_gen_history_str(history_obj, i)
        if(str != "") _history_str = _history_str str " ,"
    }

    _system_str = minion_system_tostr(minion_obj, minion_kp)
    if (_system_str != "") _system_str = ollama_gen_unit_str( _system_str ) " ,"

    _filelist_str   = minion_filelist_attach( minion_obj, minion_kp )
    if (_filelist_str != "") _filelist_str = ollama_gen_unit_str( _filelist_str) " ,"

    _content_str = ollama_gen_minion_content_str(minion_obj, minion_kp)
    _messages_str   = _history_str _system_str _filelist_str _content_str

    _mode           = jqu(minion_model( minion_obj, minion_kp ))
    _seed           = minion_seed( minion_obj, minion_kp )
    _temperature    = minion_temperature( minion_obj, minion_kp )

    _seed           = (_seed != "") ?  int(_seed)  : ""

    _option_str     = ollama_gen_options_str( _seed, _temperature, CFG_CTX )

    _data_str = "{ \"model\": " _mode ", \"messages\": [ " _messages_str " ] " _option_str " }"

    return _data_str
}

function ollama_res_to_cres(ollama_resp_o, cres_o, kp,          resp_kp){
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
