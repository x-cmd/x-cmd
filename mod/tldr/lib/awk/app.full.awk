function user_request_data( o, kp, rootkp ){
    if ( TLDR_APP_DATA_REQUEST[ kp, rootkp ] ) return
    TLDR_APP_DATA_REQUEST[ kp, rootkp ] = true
    tapp_request( rootkp )
}

function user_tldr_parse_data_lang( o, kp, list,             i, l, _, lang ){
    list = str_trim(list)
    l = split(list, _, "\n")
    comp_navi_data_init( o, kp )
    for (i=1; i<=l; ++i){
        lang = _[i]
        comp_navi_data_add_kv( o, kp, "", lang, "{", lang, 13)
    }
    comp_navi_data_end( o, kp )
}

function user_tldr_parse_data_os( o, kp, list,               lang, i, l, _, os_arr, os ){
    list = str_trim(list)
    l = split(list, _, "\n")
    lang = _[1]
    for (i=2; i<=l; ++i) os_arr[_[i]] = true

    comp_navi_data_init( o, kp, lang )
    l = TLDR_APP_OS_LIST[L]
    for (i=1; i<=l; ++i){
        os = TLDR_APP_OS_LIST[i]
        if (! os_arr[ os ] ) continue
        comp_navi_data_add_kv( o, kp, lang, os, "{", lang "/" os, 10)
    }
    comp_navi_data_end( o, kp, lang )
}

function user_tldr_parse_data_cmd( o, kp, list,              lang_os, i, l, _, cmd ){
    list = str_trim(list)
    l = split(list, _, "\n")
    lang_os = _[1]
    comp_navi_data_init( o, kp, lang_os )
    for (i=2; i<=l; ++i) {
        cmd = _[i]
        comp_navi_data_add_kv( o, kp, lang_os, cmd, "preview", lang_os "/" cmd)
    }
    comp_navi_data_end( o, kp, lang_os )
}

## Section: user model
BEGIN{
    TLDR_NAVI_POSITION = ENVIRON[ "___X_CMD_TLDR_NAVI_POSITION" ]
}
function tapp_init(){
    user_tldr_init()
    user_request_data(o, TLDR_KP)
    comp_navi_current_position_var(o, TLDR_KP, TLDR_NAVI_POSITION)
}

# EndSection

function tapp_handle_response(fp,       _content){
    _content = cat(fp)
    if( _content == "" )                        panic("list data is empty")
    else if( match( _content, "^errexit:"))     panic(substr(_content, RSTART+RLENGTH))
    else if( match( _content, "^data:lang"))    user_tldr_parse_data_lang( o, TLDR_KP, substr( _content, RLENGTH+1))
    else if( match( _content, "^data:os:"))     user_tldr_parse_data_os(   o, TLDR_KP, substr( _content, RLENGTH+1))
    else if( match( _content, "^data:cmd:"))    user_tldr_parse_data_cmd(  o, TLDR_KP, substr( _content, RLENGTH+1))

    draw_navi_change_set_all( o, TLDR_KP )
}
