
function creq_fragfile_unit___set( dir, name, str ) {
    str = str_trim_right(str)
    print str > ( dir "/" name )
    fflush()
    creq_obj[ dir, name, "loaded" ] = true
    creq_obj[ dir, name ] = str
}

function creq_fragfile_unit___get( dir, name,               str ) {
    if ( creq_obj[ dir, name, "loaded" ] == true ) return creq_obj[ dir, name ]
    creq_obj[ dir, name, "loaded" ] = true
    fp = ( dir "/" name )
    if ( (fp == "") || (fp == "/") ) return
    str = cat( fp )
    if ( cat_is_filenotfound() ) return
    creq_obj[ dir, name ] = str
    return str
}

function creq_fragfile_create( dir, minion_obj, minion_kp, provider, def_model, question, chatid,      model, filelist_attach){
    if ( dir == "" ) return
    mkdirp( dir )

    creq_fragfile_unit___set( dir, "type",              minion_type( minion_obj, minion_kp ))
    creq_fragfile_unit___set( dir, "provider",          provider )
    creq_fragfile_unit___set( dir, "model",             (model = minion_model( minion_obj, minion_kp, def_model )) )
    creq_fragfile_unit___set( dir, "question",          question )
    creq_fragfile_unit___set( dir, "chatid",            chatid )
    creq_fragfile_unit___set( dir, "is_stream",         ((minion_is_stream( minion_obj, minion_kp, model ) == true) ? "true" : "false"))
    creq_fragfile_unit___set( dir, "is_reasoning",      ((minion_is_reasoning( minion_obj, minion_kp ) == true) ? "true" : "false") )
    creq_fragfile_unit___set( dir, "history_num",       minion_history_num( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "minion",            jstr( minion_obj, minion_kp ) )

    creq_fragfile_unit___set( dir, "system",            minion_system_tostr( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "context",           minion_prompt_context( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "example",           minion_example_tostr( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "content",           minion_prompt_content( minion_obj, minion_kp ) )

    creq_fragfile_unit___set( dir, "maxtoken",          minion_maxtoken( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "seed",              minion_seed( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "temperature",       minion_temperature( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "jsonmode",          minion_is_jsonmode( minion_obj, minion_kp ) )
    creq_fragfile_unit___set( dir, "ctx",               minion_ctx( minion_obj, minion_kp ) )

    # creq_fragfile_unit___set( dir, "imagelist",      imagelist )
    creq_fragfile_unit___set( dir, "tool")

    filelist_attach = minion_filelist_attach( minion_obj, minion_kp )
    if ( ! chat_str_is_null(filelist_attach) ) {
        creq_fragfile_unit___set( dir, "filelist_attach", filelist_attach )
    }

    # minion_tool_jstr
    if (minion_obj[ minion_kp, "\"tool\"" L ] > 0 ){
        creq_fragfile_unit___set( dir, "tool", jstr(minion_obj, minion_kp SUBSEP "\"tool\""))
    }
}

function creq_fragfile_set___usage_input_ratio_SHO( dir, system_str, history_str, other_str,                prefix, charlen_name, _sl, _hl, _ol, _al, _sr, _hr, _or ){
    charlen_name = "usage_input_charlen"
    str  = creq_fragfile_unit___get( dir, charlen_name )
    if ( str != "" ) return

    _sl = length(system_str)
    _hl = length(history_str)
    _ol = length(other_str)
    _al = _sl + _hl + _ol
    if ( _al <= 0 ) return
    _sr = sprintf("%0.4f", _sl / _al)
    _hr = sprintf("%0.4f", _hl / _al)
    _or = 1 - (_sr + _hr)

    prefix = "usage_input_ratio_"
    creq_fragfile_unit___set( dir, charlen_name, _al )
    creq_fragfile_unit___set( dir, prefix "system",  _sr )
    creq_fragfile_unit___set( dir, prefix "history", _hr )
    creq_fragfile_unit___set( dir, prefix "other",   _or )
}

function creq_fragfile_set___usage_input_ratio_cache( dir, cache_l, data_l,            name ){
    if ( data_l <= 0 ) return
    if ( cache_l <= 0 ) return

    name = "usage_input_ratio_cache"
    creq_fragfile_unit___set( dir, name, sprintf("%0.4f", cache_l / data_l))
}
