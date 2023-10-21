function user_request_selected_data(){
    tapp_request("data:request")
}

function user_request_data( o, kp, rootkp,            list, i, j, k, l, _pages, _system, _cmd, _pl, _sl, _cl, _pv, _sv, _cv, arr, _){
    if ( ( l = TLDR_APP_DATA_ARR[L] ) <= 0 ) return
    for (i=1; i<=l; ++i){
        split(TLDR_APP_DATA_ARR[i], _, "/")
        jdict_put(_pages, "", _[1], true)
        jdict_put(_system, _[1], _[2], true)
        jdict_put(_cmd, _[1] S _[2], _[3], true)
    }
    l = _pages[ L ]
    comp_navi_data_init( o, kp )
    for (i=1; i<=l; ++i){
        _pv = _pages[ "", i ]
        comp_navi_data_add_kv( o, kp, "", _pv, "{", _pv, 13)
        _sl = _system[ _pv L ]
        comp_navi_data_init( o, kp, _pv )
        for (j=1; j<=_sl; ++j){
            _sv = _system[ _pv, j ]
            comp_navi_data_add_kv( o, kp, _pv, _sv, "{", _pv "/" _sv, 10)
            _cl = _cmd[ _pv, _sv L ]
            comp_navi_data_init( o, kp, _pv "/" _sv )
            for (k=1; k<=_cl; ++k){
                _cv = _cmd[ _pv, _sv, k ]
                comp_navi_data_add_kv( o, kp, _pv "/" _sv, _cv, "preview", _pv "/" _sv "/" _cv)
            }
            comp_navi_data_end( o, kp, _pv "/" _sv )
        }
        comp_navi_data_end( o, kp, _pv )
    }
    comp_navi_data_end( o, kp )
}

# Section: user model
function tapp_init(){
    user_request_selected_data()
    TLDR_APP_BASEPATH = ENVIRON[ "___X_CMD_TLDR_APP_BASEPATH" ]
    TLDR_KP = "ls_kp"
    navi_init(o, TLDR_KP)

    TLDR_DOC_KP = TLDR_KP SUBSEP "tldr.doc"
    comp_textbox_init(o, TLDR_DOC_KP, "scrollable")

    navi_statusline_init( o, TLDR_KP )
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

function tapp_handle_response(fp,       _content){
    _content = cat(fp)
    if( _content == "" )                    panic("list data is empty")
    else if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else arr_cut(TLDR_APP_DATA_ARR, _content, "\n")

    draw_navi_change_set_all( o, kp )
}

function tapp_handle_exit( exit_code,       p, v ){
    if (exit_is_with_cmd()){
        # debug( qu1(comp_navi_get_cur_rootkp(o, TLDR_KP) ) )
        if ((FINALCMD == "ENTER") && (! comp_navi_cur_preview_type_is_sel( o, TLDR_KP )))
            tapp_send_finalcmd( "___x_cmd_tldr_cat " qu1( comp_navi_get_cur_rootkp(o, TLDR_KP) ) )
    }
}

# EndSection

# Section: user view
function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        s, _filepath, _content ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")
    _filepath = rootkp
    if (_filepath == "") return
    if ((_content = o[ kp, TLDR_DOC_KP, "content", _filepath ]) == "")
        o[ TLDR_DOC_KP, "content", _filepath ] = _content = cat(TLDR_APP_BASEPATH "/" _filepath)

    s = comp_tldr_paint_of_file_content( _content, y2-y1, IS_TH_NO_COLOR)
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
