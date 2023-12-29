# this is json pipe

# {
#     jpqrse( $0 )
# }

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

function minion_prompt_context( o, prefix,          v ){
    v = o[ prefix S  "\"prompt\"" S "\"context\"" ]
    if ( chat_str_is_null(v) )  return
    return ((v ~ "^\"") ? juq(v) : v)
}

function minion_prompt_promptline( o, prefix,           v ){
    v = o[ prefix S  "\"prompt\"" S "\"promptline\"" ]
    if ( chat_str_is_null(v) )  return
    return ((v ~ "^\"") ? juq(v) : v)
}

function minion_example_len( o, prefix ){
    return o[ prefix S "\"prompt\"" S "\"example\"" L ]
}

function minion_system_len( o, prefix ){
    return o[ prefix S "\"prompt\"" S "\"system\"" L ]
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

