BEGIN{
    JOINSEP = "\n\n"
}

function minion_name( o, prefix,        v ){
    v = o[ prefix S "\"name\"" ]
    return ((v ~ "^\"") ? juq(v) : v)
}


# option > minion > cfg
function minion_history_num( o, prefix,         v ){
    v = ENVIRON[ "history_num" ]
    if ( ! chat_str_is_null(v) )    return int(v)

    v = o[ prefix S "\"history\"" ]
    if ( ! chat_str_is_null(v) )    return int((v ~ "^\"") ? juq(v) : v)

    return int(ENVIRON[ "cfg_history_num" ])
}

function minion_model( o, prefix,           v ){
    v = ENVIRON[ "model" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"model\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    return ENVIRON[ "cfg_model" ]
}

function minion_seed( o, prefix,            v ){
    v = ENVIRON[ "seed" ]
    if ( ! chat_str_is_null(v) )    return int(v)

    v = o[ prefix S "\"seed\"" ]
    if ( ! chat_str_is_null(v) )    return int(((v ~ "^\"") ? juq(v) : v))

    return int(ENVIRON[ "cfg_seed" ])
}

function minion_session( o, prefix,         v ){
    v = ENVIRON[ "session" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"session\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    v = ENVIRON[ "cfg_session" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    return "X"
}

function minion_type( o, prefix,         v ){
    v = ENVIRON[ "type" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"type\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    return "chat"
}

function minion_output( o, prefix,         v ){
    v = ENVIRON[ "output" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"output\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    # return ENVIRON[ "cfg_output" ]
}

function minion_maxtoken( o, prefix,            v ){
    v = ENVIRON[ "maxtoken" ]
    if ( ! chat_str_is_null(v) )    return int(v)

    v = o[ prefix S "\"maxtoken\"" ]
    if ( ! chat_str_is_null(v) )    return int((v ~ "^\"") ? juq(v) : v)

    return int(ENVIRON[ "cfg_maxtoken" ])
}

function minion_temperature( o, prefix,         v ){
    v = ENVIRON[ "temperature" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"temperature\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)
    return ENVIRON[ "cfg_temperature" ]
}

function minion_is_jsonmode( o, prefix,         v ){
    v = o[ prefix S "\"json\"" ]
    if ( ! chat_str_is_null(v) )    v = ((v ~ "^\"") ? juq(v) : v)
    return (v == "true")
}

function minion_prompt_context( o, prefix,          v ){
    v = o[ prefix S  "\"prompt\"" S "\"context\"" ]
    if ( chat_str_is_null(v) )  return
    return ((v ~ "^\"") ? juq(v) : v)
}

function minion_prompt_content( o, prefix,           v ){
    v = o[ prefix S  "\"prompt\"" S "\"content\"" ]
    if ( chat_str_is_null(v) )  return
    return ((v ~ "^\"") ? juq(v) : v)
}

function minion_example( o, prefix,      v ){
    v = ENVIRON[ "example" ]
    if ( ! chat_str_is_null(v) )    return v

    return o[ prefix S "\"prompt\"" S "\"example\"" ]
}

function minion_example_len( o, prefix ){
    return o[ prefix S "\"prompt\"" S "\"example\"" L ]
}

function minion_example_tostr( o, prefix,      v, _kp, i, l, _str, _res, u, a ){
    v = minion_example( o, prefix )
    if ( ! chat_str_is_null(v) && (v != "[") ) return v
    _kp = prefix S "\"prompt\"" S "\"example\""
    l = minion_example_len( o, prefix )
    for (i=1; i<=l; ++i){
        u = o[ _kp S "\""i"\"" S "\"u\"" ]
        a = o[ _kp S "\""i"\"" S "\"a\"" ]
        _res = _res "User: "        ((u ~ "^\"") ? juq(u) : u) ";\n"
        _res = _res "Assistant: "   ((a ~ "^\"") ? juq(a) : a) "\n"
    }
    _res = ( _res != "" ) ? "example:\n" _res JOINSEP : ""
    return _res
}

function minion_system( o, prefix,      v ){
    v = ENVIRON[ "system" ]
    if ( ! chat_str_is_null(v) )    return v

    return o[ prefix S "\"prompt\"" S "\"system\"" ]
}

function minion_system_tostr( o, prefix,       v, _kp, i, l, _str, _res ){
    v = minion_system( o, prefix )
    if ( ! chat_str_is_null(v) && (v != "[") ) return v

    _kp = prefix S "\"prompt\"" S "\"system\""
    l = minion_system_len(o, prefix )
    for (i=1; i<=l; ++i) {
        _str = o[ _kp S "\""i"\"" ]
        if ( chat_str_is_null( _str ) ) continue
        _str = ((_str ~ "^\"") ? juq(_str) : _str)
        _res = _res _str JOINSEP
    }
    return _res
}

function minion_system_len( o, prefix ){
    return o[ prefix S "\"prompt\"" S "\"system\"" L ]
}

function minion_filelist_attach( o, prefix,     v, i, l, arr, fp, _str, _res ){
    v = ENVIRON[ "filelist_attach" ]
    if ( chat_str_is_null(v) ) return
    l = split( v, arr, ":" )
    for (i=1; i<=l; ++i){
        fp = arr[i]
        if (fp == "") continue
        _str =  "FILENAME: " fp "\n"    \
                "------BEGIN------\n"   \
                cat(fp)                 \
                "\n------ENG------\n\n"
        _res = _res _str
    }
    return _res
}

function minion_load_from_jsonfile( o, prefix, jsonfilepath, provider ){
    jiparse2leaf_fromfile( o, prefix, jsonfilepath )

    if ( provider !~ "^\"" )            provider = jqu(provider)
    if ( chat_str_is_null( provider ))  provider = o[ prefix S "\"provider\"" S "\"default\"" ]

    cp_cover(o, prefix, o, prefix S "\"provider\"" S provider)
    jdict_rm(o, prefix, "\"provider\"")
}



# END{
#     # minion name
#     # language
#     # provider.default
#     # openai

#     # prompt

#     # example:

#     # history
# }

