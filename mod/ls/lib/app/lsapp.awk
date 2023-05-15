function user_request_data( o, kp, rootkp ){
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    tapp_request( "data:request:" rootkp)
}

# Section: user model
function tapp_init(){
    LS_APP_BASEPATH = ENVIRON[ "___X_CMD_LS_APP_BASEPATH" ]
    LS_KP = "ls_kp"
    comp_navi_current_position_var(o, LS_KP, ___X_CMD_TUI_CURRENT_NAVI_POSITION)
    navi_init(o, LS_KP)

    navi_statusline_init( o, LS_KP )
    CUSTOM_FILEINFO_KP = LS_KP SUBSEP "fileinfo_kp"
    comp_textbox_init(o, CUSTOM_FILEINFO_KP, "scrollable")
}

# EndSection

# Section: user ctrl
# use user_paint and user_request_data
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, LS_KP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type ){
    navi_handle_wchar( o, LS_KP, value, name, type )
}

function tapp_handle_response(fp,       _content, _rootkp, _log, l, i, arr){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else if ( match( _content, "^data:item:" ) ){
        lock_release( o, LS_KP )
        l = split(_content, arr, "\n")
        _rootkp = arr[1];   gsub( "^data:item:", "", _rootkp )
        _log = arr[2];      gsub( "^data:log:", "", _log )
        if ((l == 3) && (_log == "")) _log = "Directory is empty"
        o[ LS_KP, _rootkp, "log" ] = _log
        comp_navi_data_init( o, LS_KP, _rootkp )
        for (i=4; i<=l; ++i) user_data_add( o, LS_KP, _rootkp, arr[i] )
        comp_navi_data_end( o, LS_KP, _rootkp )
    }
}

function user_data_add( o, kp, rootkp, str,          _, name, l, i, _kp ){
    l = split(str, _, " ")
    if (_[1] !~ "^([bcp])") i = 9
    else i = 10
    for (name=_[i++]; i<=l; ++i) name = name " " _[i]

    _kp = rootkp "/" name
    if (_[1] ~ "^d") comp_navi_data_add_kv( o, kp, rootkp, TH_THEME_COLOR name, "{", _kp )
    else {
        comp_navi_data_add_kv( o, kp, rootkp, name, "info", _kp )
        o[ kp, _kp, "name" ]    = name
        o[ kp, _kp, "mode" ]    = _[1]
        o[ kp, _kp, "owner" ]   = _[3]
        o[ kp, _kp, "group" ]   = _[4]
        o[ kp, _kp, "size" ]    = _[5]
        o[ kp, _kp, "update" ]  = _[6] " " _[7] " " _[8]
    }
}

function tapp_handle_exit( exit_code,       p, v ){
    if (exit_is_with_cmd()){
        p = comp_navi_get_cur_rootkp(o, LS_KP)
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_NAVI_CUR_FILE", LS_APP_BASEPATH p ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_NAVI_FINAL_COMMAND", FINALCMD ) )
        if (FINALCMD == "ENTER") v = comp_navi_current_position_get(o, LS_KP)
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_CURRENT_NAVI_POSITION", v) )
    }
}

# EndSection

# Section: user view
function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        s, _name ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")

    _name = o[ kp, rootkp, "name" ]
    if (_name == "") return
    s =        th( TH_THEME_MINOR_COLOR, "name: " )   _name
    s = s "\n" th( TH_THEME_MINOR_COLOR, "mode: " )   o[ kp, rootkp, "mode" ]
    s = s "\n" th( TH_THEME_MINOR_COLOR, "size: " )   o[ kp, rootkp, "size" ]
    s = s "\n" th( TH_THEME_MINOR_COLOR, "owner: " )  o[ kp, rootkp, "owner" ]
    s = s "\n" th( TH_THEME_MINOR_COLOR, "group: " )  o[ kp, rootkp, "group" ]
    s = s "\n" th( TH_THEME_MINOR_COLOR, "update: " ) o[ kp, rootkp, "update" ]
    comp_textbox_put(o, CUSTOM_FILEINFO_KP, s)
    return comp_textbox_paint(o, CUSTOM_FILEINFO_KP, x1, x2, y1, y2)
}

function user_paint_status( o, kp, x1, x2, y1, y2,      s, _log, _path ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    _log = o[ kp, s, "log" ]
    _path = LS_APP_BASEPATH s

    s = th( UI_TEXT_BOLD TH_THEME_COLOR, "Path: " ) _path
    if ( _log != "" ) s = s "\n" th( UI_FG_YELLOW, "Log: " ) _log

    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

# use user_paint_custom_component and user_paint_status
function user_paint( x1, x2, y1, y2 ){
    navi_paint( o, LS_KP, x1, x2, y1, y2 )
}

# EndSection
