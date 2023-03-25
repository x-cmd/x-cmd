function user_comp_ctrl_sw_toggle( o, kp ){
    ctrl_sw_toggle( o, kp )
    user_change_set_all()
    user_statusline_set( o, kp )
}

# Section: statusline
function user_statusline_set( o, kp ){
    if ( ! ctrl_sw_get( o, kp ) ) {
        if (ctrl_navi_sel_sw_get( o, NAVI_KP )) user_statusline_navi_search( o, STATUSLINE_KP )
        else user_statusline_navi_normal( o, STATUSLINE_KP )
    }
    else user_statusline_help(o, STATUSLINE_KP)
}

function user_statusline_navi_normal(o, kp){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "Tab", "Switch view", "Switch view to control" )
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "/", "Search", "Press '/' to search items" )
    comp_statusline_data_put( o, kp, "←↓↑→/hjkl", "Move focus","Press keys to move focus" )
    comp_statusline_data_put( o, kp, "n/p", "Next/Previous page", "Press 'n' to table next page, 'p' to table previous page" )
    comp_statusline_data_put( o, kp, "?", "Open help", "Close help" )
}

function user_statusline_navi_search(o, kp) {
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "←↓↑→/hjkl", "Move focus" )
    # comp_statusline_data_put( o, kp, "ctrl n/p", "Next/Previous page" )
    comp_statusline_data_put( o, kp, "/", "Close search" )
}

function user_statusline_help(o, kp){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "Tab", "Switch view", "Switch view to control" )
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    comp_statusline_data_put( o, kp, "↓↑/jk", "Scroll", "Scroll help document" )
    comp_statusline_data_put( o, kp, "?", "Open help", "Close help" )
}

# EndSection

# Section: user data
function user_data_navi_init( o, kp,         _list, l, i, _, v ){
    _list = ENVIRON[ "___X_CMD_HELPAPP_APP_LIST" ]
    l = split( _list, _, "\n" )
    for (i=1; i<=l; ++i){
        v = _[ i ]
        if ( ! match( v, "\001") ) continue
        comp_navi_data_add_kv( o, kp, "", substr( v, 1, RSTART-1), "{",  substr(v, RSTART+1))
    }
}

function user_release_ref( o, kp,       _kp, l, i, arr, r, filepath, _ ){
    l = split( kp, arr, SUBSEP)
    for (i=2; i<=l; ++i){
        _kp = _kp SUBSEP arr[i]
        if ( (r = jref_get(o, _kp) ) != false ) {
            filepath = ___X_CMD_ROOT_MOD "/" juq(r)
            jiparse2leaf_fromfile( _, _kp, filepath )
            jref_rm(o, _kp)
            cp_cover(o, _kp, _, _kp)
        }
    }
}

function user_data_navi_subcmd( o, kp, rootkp,       l, _filepath, _obj_kp, i, _, v, j, k, _l, subcmd_group ){
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    comp_navi_data_set_available( o, kp, rootkp, true )
    lock_release( o, kp )
    if (match( rootkp, "^"ROOTKP_SEP"[^"ROOTKP_SEP"]+")) {
        l = length( ROOTKP_SEP )
        _filepath = substr( rootkp, l+1, RLENGTH-l)
        if ( ! change_is(FILE_DATA_OBJ, _filepath) ) {
            jiparse2leaf_fromfile(FILE_DATA_OBJ, "DATA" SUBSEP substr(rootkp, 1, RLENGTH), _filepath)
            change_set(FILE_DATA_OBJ, _filepath)
            FILE_DATA_OBJ[ "IS_FILE_NOT_FOUND", _filepath ] = cat_is_filenotfound()
        }

        if( FILE_DATA_OBJ[ "IS_FILE_NOT_FOUND", _filepath ] ) return
        _obj_kp = "DATA" SUBSEP rootkp
        user_release_ref(FILE_DATA_OBJ, _obj_kp)

        comp_advise_parse_group(FILE_DATA_OBJ, _obj_kp, subcmd_group)
        l = arr_len(subcmd_group)
        for (i=0; i<=l; ++i){
            k = subcmd_group[i]
            if (ADVISE_DEV_TAG[ SUBSEP k ]) continue
            _l = subcmd_group[ k L ]
            for (j=1; j<=_l; ++j){
                v = subcmd_group[ k, "\""j"\"" ]
                split( juq(v), _, "|" )
                comp_navi_data_add_kv( o, kp, rootkp, _[1], "{",  v)
            }
        }
        user_change_set_all()
    }
}

# EndSection

# Section: user model
function tapp_init(){
    HELPDOC_DATA_LOADING_SW = 1
    TH_HETHEME_THEME_COLOR0 = ENVIRON[ "___X_CMD_HELP_THEME_COLOR_CODE_0" ]
    TH_HETHEME_THEME_COLOR1 = ENVIRON[ "___X_CMD_HELP_THEME_COLOR_CODE_1" ]
    TH_HETHEME_DESC_COLOR0  = ENVIRON[ "___X_CMD_HELP_DESC_COLOR_CODE_0" ]
    TH_HETHEME_DESC_COLOR1  = ENVIRON[ "___X_CMD_HELP_DESC_COLOR_CODE_1" ]
    print_helpdoc_init(IS_TH_NO_COLOR, WEBSRC_REGION, TH_HETHEME_THEME_COLOR0, TH_HETHEME_THEME_COLOR1, TH_HETHEME_DESC_COLOR0, TH_HETHEME_DESC_COLOR1)
    APPKP = "helpapp_kp"
    NAVI_KP = APPKP SUBSEP 1
    HELP_KP = APPKP SUBSEP 2
    STATUSLINE_KP = APPKP SUBSEP 3

    comp_navi_init(o, NAVI_KP)
    comp_textbox_init(o, HELP_KP, "scrollable")
    comp_statusline_init( o, STATUSLINE_KP, "?" )
    user_statusline_navi_normal( o, STATUSLINE_KP )

    ctrl_sw_init( o, APPKP, 1 )
    user_data_navi_init( o, NAVI_KP )

    user_statusline_set( o, APPKP )
}

# EndSection

# Section: user ctrl
function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 7) return false
    return rows - 1    # Assure the screen size
}

function tapp_handle_clocktick( idx, trigger, row, col ){
    if (ROWS_COLS_HAS_CHANGED) user_change_set_all()
    user_paint( 1, row, 1, col )

    if (! lock_unlocked( o, NAVI_KP )) return
    if ( comp_navi_unava_has_set( o, NAVI_KP ) ) user_data_navi_subcmd( o, NAVI_KP, comp_navi_unava_get( o, NAVI_KP ) )
}

function tapp_handle_wchar( value, name, type,              ctrl_sw, _has_no_handle ){
    if (name == U8WC_NAME_END_OF_TEXT)                              exit(0)
    else if (name == U8WC_NAME_END_OF_TRANSIMISSION)                exit(0)

    if (comp_statusline_isfullscreen(o, STATUSLINE_KP)){
        if (! comp_statusline_handle( o, STATUSLINE_KP, value, name, type )) _has_no_handle = true
        if (! comp_statusline_isfullscreen(o, STATUSLINE_KP)) user_change_set_all()
    } else {
        if ( ! ctrl_sw_get( o, APPKP ) ) {
            if ((value == "/") || (ctrl_navi_sel_sw_get( o, NAVI_KP ) && (name == U8WC_NAME_CARRIAGE_RETURN))){
                comp_navi_sel_sw_toggle( o, NAVI_KP )
                user_statusline_set( o, APPKP )
            }
            else if (comp_navi_handle( o, NAVI_KP, value, name, type ))     user_change_set_all()
            else if (value == "q")                                          exit_with_elegant("q")
            else if (name == U8WC_NAME_CARRIAGE_RETURN)                     exit_with_elegant("ENTER")
            else if (name == U8WC_NAME_HORIZONTAL_TAB )                     user_comp_ctrl_sw_toggle( o, APPKP )
            else if ((value == "l") || (name == U8WC_NAME_RIGHT))           user_comp_ctrl_sw_toggle( o, APPKP )
            else if (comp_statusline_handle( o, STATUSLINE_KP, value, name, type )) _has_no_handle = false
            else _has_no_handle = true
        } else {
            if (comp_textbox_handle( o, HELP_KP, value, name, type ))       change_set(o, HELP_KP)
            else if (value == "q")                                          exit_with_elegant("q")
            else if (name == U8WC_NAME_CARRIAGE_RETURN)                     exit_with_elegant("ENTER")
            else if (name == U8WC_NAME_HORIZONTAL_TAB )                     user_comp_ctrl_sw_toggle( o, APPKP )
            else if ((value == "h") || (name == U8WC_NAME_LEFT))            user_comp_ctrl_sw_toggle( o, APPKP )
            else if (comp_statusline_handle( o, STATUSLINE_KP, value, name, type )) _has_no_handle = false
            else _has_no_handle = true
        }
    }

    return ( _has_no_handle == true ) ? false : true
}

function tapp_handle_response(fp,       _content, _rootkp, _log, l, i, arr){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))

}

function tapp_handle_exit( exit_code ){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_HELP_APP_FINAL_COMMAND", FINALCMD ) )
    }
}

# EndSection

# Section: user view
function user_change_set_all(){
    comp_navi_change_set_all( o, NAVI_KP)
    change_set(o, HELP_KP)
    comp_statusline_change_set_all(o, STATUSLINE_KP)
}

function user_helpdoc_paint( x1, x2, y1, y2, is_ctrl_help,      rootkp, w, _res){
    if ( ! change_is(o, HELP_KP) ) return
    if (HELPDOC_DATA_LOADING_SW == true) {
        comp_textbox_clear( o, HELP_KP )
        comp_textbox_put( o, HELP_KP, th((is_ctrl_help ? "" : UI_TEXT_DIM ), "Help document data loading...") )
        HELPDOC_DATA_LOADING_SW = false
    } else {
        change_unset(o, HELP_KP)
        rootkp = comp_navi_get_cur_rootkp(o, NAVI_KP)
        w = y2 - y1 - 4
        if ( ! change_is( HELPDOC, rootkp, w)) {
            # HELPDOC[ rootkp, w ] = jstr(FILE_DATA_OBJ, "DATA" SUBSEP rootkp)
            HELPDOC[ rootkp, w ] = print_helpdoc(FILE_DATA_OBJ, "DATA" SUBSEP rootkp, w)
            change_set( HELPDOC, rootkp, w)
        }

        if ((HELPDOC[ "LASTDOC", "kp" ] != rootkp) || (HELPDOC[ "LASTDOC", "width" ] != w)) {
            comp_textbox_clear( o, HELP_KP )
            comp_textbox_put( o, HELP_KP, HELPDOC[ rootkp, w ] )
            HELPDOC[ "LASTDOC", "kp" ] = rootkp
            HELPDOC[ "LASTDOC", "width" ] = w
        }
    }
    comp_textbox_change_set(o, HELP_KP)
    _res = comp_textbox_paint( o, HELP_KP, x1, x2, y1, y2, true, (is_ctrl_help ? TH_THEME_COLOR : UI_TEXT_DIM ), true, 1 )
    return _res
}

function user_paint( x1, x2, y1, y2 ){
    if (! comp_statusline_isfullscreen(o, STATUSLINE_KP)) {
        ctrl_help = ctrl_sw_get(o, APPKP)
        paint_screen( comp_statusline_paint( o, STATUSLINE_KP, x1, x1, y1, y2 ) )
        paint_screen( comp_navi_paint( o, NAVI_KP, x1+1, x2, y1, y1+42, ctrl_help ) )
        paint_screen( user_helpdoc_paint( x1+1, x2, y1+43, y2, ctrl_help ) )
    } else {
        comp_statusline_set_fullscreen( o, STATUSLINE_KP, x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, STATUSLINE_KP) )
    }
}

# EndSection
