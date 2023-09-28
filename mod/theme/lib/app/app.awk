# Section: user model
BEGIN{
    TAPP_CANVAS_FULLSCREEN = 1
}
function tapp_init(){
    THEME_STYLE_PREVIEW_PATH = ENVIRON[ "style_preview" ]
    THEME_NAVI_ROW = ENVIRON[ "navi_row" ]
    THEME_NAVI_ROW = (THEME_NAVI_ROW != "") ? THEME_NAVI_ROW : 6
    APPKP = "theme_kp"
    navi_init(o, APPKP)
    navi_statusline_init( o, APPKP )
    change_set(o, APPKP, "theme.custom.tip")
    comp_navi_ctrl_rowloop_sw_set(o, APPKP, false)
}

function user_request_data(o, kp, rootkp,               _content, width, i, j, k, m, _kp, _l_layout, _l_theme, _l_scheme, k_layout, k_theme, v_scheme, view_layout_data, layout, theme, scheme){
    _content = cat( ENVIRON[ "classify_fp" ] )
    yml_parse( _content, obj )
    width = int(tapp_canvas_colsize_get()/3)
    comp_navi_data_init( o, kp )
    l = obj[L]
    for (i=1; i<=l; ++i){
        _kp = S "\""i"\""
        _l_layout = obj[ _kp L ]
        for (j=1; j<=_l_layout; ++j){
            k_layout = obj[ _kp S j ]
            layout = (k_layout ~ "^\"") ? juq(k_layout) : k_layout
            view_layout_data = layout
            if ((j == _l_layout) && (i != l)) view_layout_data = UI_TEXT_UNDERLINE layout
            comp_navi_data_add_kv( o, kp, "", view_layout_data, "{", layout, width )
            comp_navi_data_init(o, kp, layout)
            _l_theme = obj[ _kp S k_layout L ]
            for (k=1; k<=_l_theme; ++k){
                k_theme = obj[ _kp S k_layout S k ]
                theme = (k_theme ~ "^\"") ? juq(k_theme) : k_theme
                comp_navi_data_add_kv( o, kp, layout, theme, "{", layout "/" theme, width )
                comp_navi_data_init( o, kp, layout "/" theme )
                _l_scheme = obj[ _kp S k_layout S k_theme L ]
                for (m=1; m<=_l_scheme; ++m){
                    v_scheme = obj[ _kp S k_layout S k_theme S "\""m"\"" ]
                    scheme = (v_scheme ~ "^\"") ? juq(v_scheme) : v_scheme
                    comp_navi_data_add_kv( o, kp, layout "/" theme, scheme, "null", layout "/" theme "/" scheme, width )
                }
                comp_navi_data_end( o, kp, layout "/" theme )
            }
            comp_navi_data_end(o, kp, layout)
        }
    }
    comp_navi_data_end( o, kp )
    change_set(o, kp, "theme.custom.tip")
}

# EndSection

# Section: user ctrl
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, APPKP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type ){
    if ( navi_handle_wchar( o, APPKP, value, name, type ) ) {
        change_set(o, APPKP, "theme.custom.tip")
    }
}

function tapp_handle_response(fp,       _content){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
}

function tapp_handle_exit( exit_code,       rootkp, _ ){
    if (exit_is_with_cmd()){
        if (FINALCMD == "ENTER"){
                if (comp_navi_cur_preview_type_is_sel( o, APPKP ))    rootkp = comp_navi_get_col_rootkp(o, APPKP, 3)
                else    rootkp = comp_navi_get_cur_rootkp(o, APPKP)

            split(rootkp, _, "/")
            tapp_send_finalcmd( sh_varset_val( "___X_CMD_THEME_SCHEME", _[2] "/" _[3]) )
        }
    }
}

# EndSection

# Section: user view
function user_paint_theme_preview( x1, x2, y1, y2, rootkp,         _draw_clear, _res, _, fp, style ){
    _draw_clear = painter_clear_allline( x1, x2 )
    if (split(rootkp, _, "/") < 3) return
    fp = THEME_STYLE_PREVIEW_PATH "/" _[2] "/" _[3]
    if ((style = THEME_STYLE_PREVIEW[ fp ]) == "") {
        style = cat(fp)
        gsub(/^[ \t\b\v\n]+/, "", style)
        gsub(/[ \t\b\v\n]+$/, "", style)
        THEME_STYLE_PREVIEW[ fp ] = style
    }
    _res = painter_goto_rel(x1, y1) "\r" style
    return _draw_clear _res
}

function user_paint_custom_component( o, kp, x1, x2, y1, y2,      rootkp, c, i ){
    if ( (! change_is(o, kp, "theme.custom.tip")) && (! change_is(o, kp, "navi.preview")) ) return
    change_unset(o, kp, "navi.preview")
    change_unset(o, kp, "theme.custom.tip")
    if ( comp_navi_paint_preview_ischange( o, kp ) )        rootkp = o[ kp, "PREVIEW", "KP" ]
    else if (comp_navi_cur_preview_type_is_sel( o, kp ))    rootkp = comp_navi_get_col_rootkp(o, kp, 3)

    return user_paint_theme_preview( x1, x2, y1, y2, rootkp )
}

function user_paint( x1, x2, y1, y2,            kp, _res ){
    kp = APPKP
    if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")) {
        # _res = comp_statusline_paint( o, kp SUBSEP "statusline", x1, x1, y1, y2 )
        _res = _res comp_navi_paint( o, kp, x1, x1+1+THEME_NAVI_ROW, y1, y2)
        _res = _res user_paint_custom_component( o, kp, x1+2+THEME_NAVI_ROW, x2, y1, y2 )
        paint_screen( _res )
    } else {
        comp_statusline_set_fullscreen( o, kp SUBSEP "statusline", x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, kp SUBSEP "statusline") )
    }
}

# EndSection
