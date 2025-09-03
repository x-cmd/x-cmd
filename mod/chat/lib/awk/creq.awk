

# req.chat.json
# res.chat.json

# req.gemini.json
# res.gemini.json

# req.openai.json
# res.openai.json

function creq_minion( o, prefix ){
    return o[ prefix S "\"minion\"" ]
}

function creq_question( o, prefix ){
    return o[ prefix S "\"question\"" ]
}

function creq_history_num( o, prefix ){
    return o[ prefix S "\"history_num\"" ]
}

function creq_chatid( o, prefix ){
    return o[ prefix S "\"chatid\"" ]
}
function creq_model( o, prefix ){
    return o[ prefix S "\"model\"" ]
}

function creq_load( o, jsonstr,      _arrl, _arr, i ){
    _arrl = json_split2tokenarr( _arr, jsonstr )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if ( JITER_LEVEL != 0 ) continue
        if ( JITER_CURLEN == HISTORY_SIZE) exit
    }
}

function creq_loadfromjsonfile( o, kp, fp ){
    jiparse2leaf_fromfile( o, kp,  fp )
}

function creq_create( o, kp, minion_obj, minion_kp, provider, model, question, chatid, imagelist, is_stream, is_reasoning,       _kp_media, i, l, _arr, _keyl, tool_jstr, filelist_attach){
    kp = ((kp != "") ? kp : SUBSEP "\"1\"")
    o[ kp ] = "{"
    jdict_put(o, kp, "\"minion\"",          "{")
    jdict_put(o, kp, "\"type\"",            jqu( minion_type( minion_obj, minion_kp ) ))
    jdict_put(o, kp, "\"provider\"",        jqu(provider))
    jdict_put(o, kp, "\"model\"",           jqu(model))
    jdict_put(o, kp, "\"question\"",        jqu(question))
    jdict_put(o, kp, "\"chatid\"",          jqu(chatid))
    jdict_put(o, kp, "\"is_stream\"",       ((is_stream == true) ? "true" : "false"))
    jdict_put(o, kp, "\"is_reasoning\"",    ((is_reasoning == true) ? "true" : "false"))
    jdict_put(o, kp, "\"history_num\"",     minion_history_num( minion_obj, minion_kp ))
    jmerge_soft___value(o, kp SUBSEP "\"minion\"", minion_obj, minion_kp)

    imagelist = str_trim( imagelist )
    if (imagelist != "") {
        jdict_put(o, kp, "\"media\"", "[")
        _kp_media = kp SUBSEP "\"media\""
        l = split(imagelist, _arr, "\n")
        for (i=1; i<=l; ++i){
            jlist_put(o, _kp_media, "{")
            _keyl = o[ _kp_media L ]
            jdict_put(o, _kp_media SUBSEP "\"" _keyl "\"", "\"type\"",      "\"image\"")
            jdict_put(o, _kp_media SUBSEP "\"" _keyl "\"", "\"base64\"",    jqu(_arr[ i ]))
            jdict_put(o, _kp_media SUBSEP "\"" _keyl "\"", "\"msg\"",       jqu(_arr[ ++i ]))
        }
    }

    tool_jstr = minion_tool_jstr( minion_obj, minion_kp )
    if ( ! chat_str_is_null(tool_jstr) ) {
        jdict_put(o, kp, "\"tool\"", "[")
        jiparse2leaf_fromstr(o, kp SUBSEP "\"tool\"", tool_jstr)
    }

    filelist_attach = minion_filelist_attach( minion_obj, minion_kp )
    if ( ! chat_str_is_null(filelist_attach) ) {
        jdict_put(o, kp, "\"filelist_attach\"", jqu(filelist_attach))
    }

    if (minion_obj[ minion_kp, "\"tool\"" L ] > 0 ){
        jdict_put(o, kp, "\"tool\"", "[")
        jmerge_soft___value(o, kp SUBSEP "\"tool\"", minion_obj, minion_kp SUBSEP "\"tool\"")
    }
}

function creq_dump( o, kp ){
    return jstr( o, kp )
}

function creq_append_usage_input_ratio_SHO(o, kp, system_str, history_str, other_str,                 _kp_usage, _kp_input, _kp_ratio, _sl, _hl, _ol, _al, _sr, _hr, _or ){
    kp = ((kp != "") ? kp : SUBSEP "\"1\"")
    _kp_usage = kp SUBSEP "\"usage\""
    _kp_input = _kp_usage SUBSEP "\"input\""
    _kp_ratio = _kp_input SUBSEP "\"ratio\""
    if ( o[ _kp_ratio L ] > 0 ) return

    _sl = length(system_str)
    _hl = length(history_str)
    _ol = length(other_str)
    _al = _sl + _hl + _ol
    if ( _al <= 0 ) return
    _sr = sprintf("%0.4f", _sl / _al)
    _hr = sprintf("%0.4f", _hl / _al)
    _or = 1 - (_sr + _hr)

    jdict_put(o, kp, "\"usage\"", "{")
    jdict_put(o, _kp_usage, "\"input\"", "{")
    jdict_put(o, _kp_input, "\"stringLength\"",  _al)
    jdict_put(o, _kp_input, "\"ratio\"", "{")
    jdict_put(o, _kp_ratio, "\"system\"",  _sr)
    jdict_put(o, _kp_ratio, "\"history\"", _hr)
    jdict_put(o, _kp_ratio, "\"other\"",   _or)
}

function creq_append_usage_input_ratio_cache( o, kp, cache_l, data_l,            _kp_usage ){
    if ( data_l <= 0 ) return
    if ( cache_l <= 0 ) return

    kp = ((kp != "") ? kp : SUBSEP "\"1\"")
    _kp_usage = kp  SUBSEP "\"usage\""
    _kp_input = _kp_usage SUBSEP "\"input\""
    _kp_ratio = _kp_input SUBSEP "\"ratio\""
    if ( ! jdict_has( o, kp, "\"usage\"" ) ) jdict_put(o, kp, "\"usage\"", "{")
    if ( ! jdict_has( o, _kp_usage, "\"input\"" ) ) jdict_put(o, _kp_usage, "\"input\"", "{")
    if ( ! jdict_has( o, _kp_input, "\"ratio\"" ) ) jdict_put(o, _kp_input, "\"ratio\"", "{")
    jdict_put(o, _kp_ratio, "\"cache\"", sprintf("%0.4f", cache_l / data_l))
}

# function creq_json_file_create(obj, fildedir, MINION, model, QUESTION, CHATID, HISTORY_NUM ){
#     creq_create(obj, MINION, model, QUESTION, CHATID, HISTORY_NUM  )
#     print creq_dump(obj) > SESSIONDIR "/" CHATID "/req.json" > fildedir "/req.json"
# }
# req => gemini_request
# req => openai_request

