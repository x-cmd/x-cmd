# Section: user model
function user_tldr_init(){
    TLDR_APP_BASEPATH = ENVIRON[ "___X_CMD_TLDR_APP_BASEPATH" ]
    TLDR_NO_BACKGROUND = ENVIRON[ "___X_CMD_TLDR_NO_BACKGROUND" ]
    comp_tldr_parse_ignorelang( TLDR_IGNORELANG_ARR, ENVIRON[ "___X_CMD_TLDR_LANG_IGNORE" ], "," )
    TLDR_KP = "ls_kp"
    navi_init(o, TLDR_KP)

    TLDR_DOC_KP = TLDR_KP SUBSEP "tldr.doc"
    comp_textbox_init( o, TLDR_DOC_KP, "scrollable" )
    navi_statusline_init( o, TLDR_KP )
    arr_cut(TLDR_APP_OS_LIST, "common,linux,osx,windows,android,sunos,openbsd,freebsd,netbsd", ",")
}

# EndSection

# Section: user ctrl
# use user_paint and user_request_data
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, TLDR_KP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type ){
    if ( navi_handle_wchar( o, TLDR_KP, value, name, type ) ) return
}

function tapp_handle_exit( exit_code,       p, v ){
    if (exit_is_with_cmd()){
        # debug( qu1(comp_navi_get_cur_rootkp(o, TLDR_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_CURRENT_TLDR_POSITION", comp_navi_current_position_get(o, TLDR_KP)) )
        if (FINALCMD == "ENTER") {
            if (! comp_navi_cur_preview_type_is_sel( o, TLDR_KP )) {
                v = qu1( comp_navi_get_cur_rootkp(o, TLDR_KP) )
                if (v == "") return
                tapp_send_finalcmd( "tldr:info x tldr --cat " v " ; ___x_cmd_tldr_cat " v )
            }
        }
    }
}

# EndSection

# Section: user view
function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        s, _filepath, _content, _lang ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")
    _filepath = rootkp
    if (_filepath == "") return
    _lang = substr(_filepath, 7, index( _filepath, "/" ) - 7)
    if ( TLDR_IGNORELANG_ARR[_lang] ) {
        s = UI_END "The current tldr app does not support displaying this document.\n"UI_END"You can use `" \
            th(TH_THEME_COLOR,  "x tldr "_filepath) \
            "` to view the document."
    }
    else {
        if ((_content = o[ kp, TLDR_DOC_KP, "content", _filepath ]) == "")
            o[ TLDR_DOC_KP, "content", _filepath ] = _content = cat(TLDR_APP_BASEPATH "/" _filepath)
        s = comp_tldr_paint_of_file_content( _content, y2-y1, IS_TH_NO_COLOR, TLDR_NO_BACKGROUND)
    }
    comp_textbox_put(o, TLDR_DOC_KP, s)
    return comp_textbox_paint(o, TLDR_DOC_KP, x1, x2, y1, y2)
}

function user_paint_status( o, kp, x1, x2, y1, y2,      s, _log, _path ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    s = th( UI_TEXT_BOLD TH_THEME_COLOR, "Path: " ) s
    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

# use user_paint_custom_component and user_paint_status
function user_paint( x1, x2, y1, y2 ){
    navi_paint( o, TLDR_KP, x1, x2, y1, y2 )
}

# EndSection
