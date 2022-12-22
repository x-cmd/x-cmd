function user_request_ls_data( rootkp ){
    if (! lock_acquire( o, LSENV_KP ) ) panic("lock bug")
    gsub( ROOTKP_SEP, " ", rootkp)
    tapp_request( "data:request:" rootkp)
}

# Section: user model

function tapp_init(){
    LSENV_KP = "ls_kp"
    comp_navi_init(o, LSENV_KP)
    comp_statusline_init( o, LS_STATUSLINE_KP = TABLE_KP SUBSEP "statusline" )
    comp_statusline_data_put( o, LS_STATUSLINE_KP, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, LS_STATUSLINE_KP, "/", "Search", "Press '/' to search items" )
    comp_statusline_data_put( o, LS_STATUSLINE_KP, "Tab", "Open help", "Close help" )
}

# EndSection

# Section: user ctrl

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 7) return false
    return rows - 1    # Assure the screen size
}

function tapp_handle_clocktick( idx, trigger, row, col ){
    user_view()

    if (! lock_unlocked( o, LSENV_KP )) return
    if ( comp_navi_unava_has_set( o, LSENV_KP ) ) user_request_ls_data( comp_navi_unava_get( o, LSENV_KP ) )
}

function tapp_handle_wchar( value, name, type,           kp, d ){
    if (name == U8WC_NAME_END_OF_TEXT)                                  exit(0)
    else if (name == U8WC_NAME_END_OF_TRANSIMISSION)                    exit(0)

    if (comp_statusline_isfullscreen(o, LS_STATUSLINE_KP)){
        comp_statusline_handle( o, LS_STATUSLINE_KP, value, name, type )
        if (! comp_statusline_isfullscreen(o, LS_STATUSLINE_KP)) comp_navi_change_set_all( o, LSENV_KP )
    } else {
        if (value == "q")                                               exit(0)
        else if (value == "/")                                          return comp_navi_sel_sw_toggle( o, LSENV_KP )
        else if (name == U8WC_NAME_CARRIAGE_RETURN)                     exit_with_elegant("ENTER")
        else if (comp_navi_handle( o, LSENV_KP, value, name, type ))    return
        else if (comp_statusline_handle(o, LS_STATUSLINE_KP, value, name, type ))  return
    }
}

function tapp_handle_response(fp,       _content, _rootkp, l, i, arr){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else if ( match( _content, "^data:item:" ) ){
        lock_release( o, LSENV_KP )
        l = split(_content, arr, "\n")
        _rootkp = arr[1];   gsub( "^data:item:", "", _rootkp )
        gsub( " ", ROOTKP_SEP, _rootkp )
        user_data_add( o, LSENV_KP, _rootkp, arr[2] )
        for (i=3; i<=l; ++i) user_data_add( o, LSENV_KP, _rootkp, arr[i] )
    }
}

function user_data_add( o, kp, rootkp, str,         preview, _, v ) {
    split( str, _, " ")
    v = _[1]
    if (v != "" ) preview = "{"
    if (_[2] != "") {
        preview = ""
        o[ kp, rootkp ROOTKP_SEP v, "version" ] = v
        o[ kp, rootkp ROOTKP_SEP v, "info" ] = _[2]
    }
    comp_navi_data_add_kv( o, kp, rootkp, v, preview, v )
}

function tapp_handle_exit( exit_code,       s, v, _ ){
    if (exit_is_with_cmd()){
        s = comp_navi_get_cur_rootkp(o, LSENV_KP)
        v = o[ LSENV_KP, s, "version" ]
        if (v == "") return
        split( s, _, ROOTKP_SEP )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_ENV_LSENV_CANDIDATE", _[3] ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_ENV_LSENV_VERSION", v ) )
    }
}

# EndSection

# Section: user view

function user_view(      x1, x2 ,y1, y2 ){
    x1 = y1 = 1
    x2 = tapp_canvas_rowsize_get()
    y2 = tapp_canvas_colsize_get()
    if (ROWS_COLS_HAS_CHANGED) comp_navi_change_set_all( o, LSENV_KP )
    user_paint( x1, x2, y1, y2 )
}

function user_paint_status( o, kp, x1, x2, y1, y2,      s, l, i, _ ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    l = split( s, _, ROOTKP_SEP)
    s = th( TH_THEME_MINOR_COLOR, "CANDIDATE: " ) _[3]
    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

function user_paint_version_info( o, kp, rootkp, x1, x2, y1, y2,        s, _version ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")

    _version = o[ kp, rootkp, "version" ]
    if (_version == "") return
    _info = o[ kp, rootkp, "info" ]
    s = th( TH_THEME_MINOR_COLOR, "version: " ) _version # \
        # "\n" th( TH_THEME_MINOR_COLOR, "info: " ) info
    comp_textbox_put(o, CUSTOM_FILEINFO_KP, s)
    return comp_textbox_paint(o, CUSTOM_FILEINFO_KP, x1, x2, y1, y2)
}

function user_paint( x1, x2, y1, y2,       _res ){
    if (! comp_statusline_isfullscreen(o, LS_STATUSLINE_KP)) {
        _res = comp_navi_paint( o, LSENV_KP, x1, x2-2, y1, y2)

        if ( comp_navi_paint_preview_ischange( o, LSENV_KP ) ){
            _res = _res user_paint_version_info( o, LSENV_KP, \
                o[ LSENV_KP, "PREVIEW", "KP" ], \
                o[ LSENV_KP, "PREVIEW", "X1" ], \
                o[ LSENV_KP, "PREVIEW", "X2" ], \
                o[ LSENV_KP, "PREVIEW", "Y1" ], \
                o[ LSENV_KP, "PREVIEW", "Y2" ] )
        }


        _res = _res user_paint_status( o, LSENV_KP, x2-1, x2-1, y1, y2 )
        _res = _res comp_statusline_paint( o, LS_STATUSLINE_KP, x2, x2, y1, y2 )
        paint_screen( _res )
    }else {
        comp_statusline_set_fullscreen( o, LS_STATUSLINE_KP, x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, LS_STATUSLINE_KP) )
    }
}

# EndSection
