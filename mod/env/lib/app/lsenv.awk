function user_request_data( o, kp, rootkp ){
    navi_request_data(o, kp, rootkp)
}

# Section: user model
function tapp_init(){
    LSENV_KP = "ls_kp"
    navi_init(o, LSENV_KP)
    navi_statusline_init( o, LSENV_KP )
    comp_textbox_init(o, "CUSTOM_FILEINFO_KP")
}

# EndSection

# Section: user ctrl
# use user_paint and user_request_data
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, LSENV_KP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type,           kp, d ){
    return navi_handle_wchar( o, LSENV_KP, value, name, type )
}

function tapp_handle_response(fp,       _content, _rootkp, l, i, arr){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else if ( match( _content, "^data:item:" ) ){
        lock_release( o, LSENV_KP )
        l = split(_content, arr, "\n")
        _rootkp = substr( arr[1], RLENGTH+1 )
        comp_navi_data_init( o, LSENV_KP, _rootkp )
        for (i=2; i<=l; ++i) {
            if(arr[i] ~ "^homepage|^license|^desc") continue
            user_data_add( o, LSENV_KP, _rootkp, arr[i] )
        }
        comp_navi_data_end( o, LSENV_KP, _rootkp )
    }
}

function user_data_add( o, kp, rootkp, str,         preview, _, v) {
    split( str, _, "\003\004")
    v = _[1]
    if (_[2] == "") preview = "{"
    else {
        jqparse_dict0(_[2], o, kp SUBSEP rootkp " " v SUBSEP "info")
        jdict_put(o, kp SUBSEP rootkp " " v SUBSEP "info", "\"version\"", v)
        preview = "preview"
    }
    comp_navi_data_add_kv( o, kp, rootkp, v, preview, rootkp " " v )
}

function tapp_handle_exit( exit_code,       s, v, _, len ){
    if (exit_is_with_cmd()){
        s = comp_navi_get_cur_rootkp(o, LSENV_KP)
        v = o[ LSENV_KP, s, "info", "\"version\"" ]
        if (v == "") return
        len = split( s, _, " " )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_ENV_LSENV_FINAL_COMMAND", FINALCMD ) )
        if (len == 3) tapp_send_finalcmd( sh_varset_val( "___X_CMD_ENV_LSENV_APP_CANDIDATE", _[2] "=" v ) )
        else tapp_send_finalcmd( sh_varset_val( "___X_CMD_ENV_LSENV_APP_CANDIDATE", substr( _[1], index( _[1], "/") +1 ) "=" v ) )
    }
}

# EndSection

# Section: user view
function user_paint_status( o, kp, x1, x2, y1, y2,      s, l, i, _ ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    l = split( s, _, " ")
    s = th( TH_THEME_MINOR_COLOR, "CANDIDATE: " ) _[2]
    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        _kp, key, value, l, i, v ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")
    _kp = kp S rootkp S "info"
    if ((l = o[ _kp L ]) == 0) return
    for(i=1; i<=l; i++) {
        key = o[ _kp, i ]
        value = o[ _kp, key ]
        if (value ~ "^\"") value = juq(value)
        v = v th(TH_THEME_MINOR_COLOR, juq(key)) ": " value "\n"
    }
    comp_textbox_put(o, "CUSTOM_FILEINFO_KP", v)
    return comp_textbox_paint(o, "CUSTOM_FILEINFO_KP", x1, x2, y1, y2)
}

# use user_paint_custom_component and user_paint_status
function user_paint( x1, x2, y1, y2 ){
    navi_paint( o, LSENV_KP, x1, x2, y1, y2 )
}

# EndSection
