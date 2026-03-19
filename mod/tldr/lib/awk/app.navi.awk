function user_request_data( o, kp, rootkp ){
    if ( TLDR_APP_DATA_REQUEST[ kp, rootkp ] ) return
    TLDR_APP_DATA_REQUEST[ kp, rootkp ] = true
    tapp_request( rootkp )
}

function user_tldr_parse_data_list( o, kp, list,          cmd, i, l, _ ){
    list = str_trim(list)
    l = split(list, _, "\n")
    comp_navi_data_init( o, kp )
    for (i=1; i<=l; ++i){
        cmd = _[i]
        comp_navi_data_add_kv( o, kp, "", substr(cmd, 7), "preview", cmd, 40)
    }
    comp_navi_data_end( o, kp )
}

## Section: user model
BEGIN{
    TLDR_NAVI_POSITION = ENVIRON[ "___X_CMD_TLDR_NAVI_POSITION" ]
}
function tapp_init(){
    user_tldr_init()
    user_request_data(o, TLDR_KP)
    if (TLDR_NAVI_POSITION != "" ) comp_navi_current_position_var(o, TLDR_KP, TLDR_NAVI_POSITION)
}

# EndSection

function tapp_handle_response(fp,       _content){
    _content = cat(fp)
    if( _content == "" )                        panic("list data is empty")
    else if( match( _content, "^errexit:"))     panic(substr(_content, RSTART+RLENGTH))
    else if( match( _content, "^data:list"))    user_tldr_parse_data_list(  o, TLDR_KP, substr( _content, RLENGTH+1))

    draw_navi_change_set_all( o, TLDR_KP )
}
