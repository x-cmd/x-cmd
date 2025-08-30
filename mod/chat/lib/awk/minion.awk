BEGIN{
    JOINSEP = "\n\n"
}

function minion_name( o, prefix,        v ){
    # v = o[ prefix S "\"name\"" ]
    v = ENVIRON[ "minion" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    v = o[ prefix S "\"name\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    v = ENVIRON[ "cfg_minion" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    return "default"
}

# option > minion > cfg
function minion_history_num( o, prefix,         v ){
    v = ENVIRON[ "history_num" ]
    if ( ! chat_str_is_null(v) )    return int(v)

    v = o[ prefix S "\"history\"" ]
    if ( ! chat_str_is_null(v) )    return int((v ~ "^\"") ? juq(v) : v)

    return int(ENVIRON[ "cfg_history_num" ])
}

function minion_model( o, prefix, def_model,           v ){
    v = ENVIRON[ "model" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"model\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

    v = ENVIRON[ "cfg_model" ]
    if ( (v == "") && (def_model !="" ) ) v = def_model
    return v
}

function minion_is_stream( o, prefix, model,            v, v1 ){
    v1 = ENVIRON[ "is_stream" ] ""
    if (v1 == "") v1 = o[ prefix S "\"stream\"" ] ""
    if (v1 == "") v1 = ENVIRON[ "cfg_stream" ] ""
    if ( ! chat_str_is_null(v1) ) v = ((v1 ~ "^\"") ? juq(v1) : v1)

    if (( v == "true" ) || ( v == true ))           return true
    else if (( v == "false" ) || ( v == false ))    return false

    if ( model ~ "^(gpt-5|gpt-5-mini)$" ) return false
    return true
}

function minion_is_reasoning( o, prefix,            v, v1 ){
    v1 = ENVIRON[ "is_reasoning" ] ""
    if (v1 == "") v1 = o[ prefix S "\"reasoning\"" ] ""
    if (v1 == "") v1 = ENVIRON[ "cfg_reasoning" ] ""
    if ( ! chat_str_is_null(v1) ) v = ((v1 ~ "^\"") ? juq(v1) : v1)

    if (( v == "true" ) || ( v == true ))           return true
    else if (( v == "false" ) || ( v == false ))    return false

    return false # true
}

function minion_seed( o, prefix,            v ){
    v = ENVIRON[ "seed" ]
    if ( ! chat_str_is_null(v) )    return int(v)

    v = o[ prefix S "\"seed\"" ]
    if ( ! chat_str_is_null(v) )    return int(((v ~ "^\"") ? juq(v) : v))

    v = ENVIRON[ "cfg_seed" ]
    if ( ! chat_str_is_null(v) )    return int(v)
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

function minion_maxtoken( o, prefix,            v, v1 ){
    v1 = ENVIRON[ "maxtoken" ]
    if ( ! chat_str_is_null(v1) )    v = ((v1 ~ "^\"") ? juq(v1) : v1)

    v1 = o[ prefix S "\"maxtoken\"" ]
    if ( ! chat_str_is_null(v1) )    v = ((v1 ~ "^\"") ? juq(v1) : v1)

    v1 = ENVIRON[ "cfg_maxtoken" ]
    if ( ! chat_str_is_null(v1) )    v = ((v1 ~ "^\"") ? juq(v1) : v1)

    v = str_trim(v)
    v = tolower(v)
    if ( match( v, "(k|kb)$" ) ) {
        v = substr(v, 1, RSTART-1)
        v = int(v) * 1024
    } else if ( match( v, "(m|mb)$" ) ) {
        v = substr(v, 1, RSTART-1)
        v = int(v) * 1024 * 1024
    } else if ( match( v, "(g|gb)$" ) ) {
        v = substr(v, 1, RSTART-1)
        v = int(v) * 1024 * 1024 * 1024
    } else {
        v = int(v)
    }

    return v
}

function minion_temperature( o, prefix,         v ){
    v = ENVIRON[ "temperature" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"temperature\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)
    return ENVIRON[ "cfg_temperature" ]
}

function minion_ctx( o, prefix,         v ){
    v = ENVIRON[ "ctx" ]
    if ( ! chat_str_is_null(v) )    return v

    v = o[ prefix S "\"ctx\"" ]
    if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)
    return ENVIRON[ "cfg_ctx" ]
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

function minion_load_from_jsonfile( o, prefix, jsonfilepath, provider,      str ){
    if ( jsonfilepath == "" ) return
    str = cat( jsonfilepath )
    if ( cat_is_filenotfound() ) return
    str = chat_str_replaceall( str )
    jiparse2leaf_fromstr( o, prefix, str )

    if ( provider !~ "^\"" )            provider = jqu(provider)
    if ( chat_str_is_null( provider ))  provider = o[ prefix S "\"provider\"" S "\"default\"" ]

    if ( ! chat_str_is_null( o[ prefix S "\"provider\"" S provider ] ) ) {
        jmerge_soft___value(o, prefix, o, prefix S "\"provider\"" S provider)
        jdict_rm(o, prefix, "\"provider\"")
    }
}

function minion_tool_jstr(o, prefix,            v){
    v = ENVIRON[ "tool_jstr" ]
    if ( ! chat_str_is_null(v) )    return v
}

# function minion_tool_function( o, prefix, obj, obj_kp,        v ){
#     v = ENVIRON[ "tool_function" ]
#     if ( ! chat_str_is_null(v) ) {
#         jiparse2leaf_fromstr( obj, obj_kp, v )
#         return
#     }

#     v = o[ prefix S "\"tool\"" S "\"function\"" ]
#     if ( (v == "[")  || (v == "{") ) {
#         jmerge_soft___value( obj, obj_kp, o, prefix S "\"tool\"" S "\"function\"" )
#     }
# }

# function minion_tool_choice( o, prefix         v ){
#     v = ENVIRON[ "tool_choice" ]
#     if ( ! chat_str_is_null(v) )    return v

#     v = o[ prefix S "\"tool\"" S "\"choice\"" ]
#     if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

#     v = ENVIRON[ "cfg_tool_choice" ]
#     if ( ! chat_str_is_null(v) )    return ((v ~ "^\"") ? juq(v) : v)

#     return "auto"
# }

# END{
#     # minion name
#     # language
#     # provider.default
#     # openai

#     # prompt

#     # example:

#     # history
# }

