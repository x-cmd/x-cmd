function comp_statusline_style_init(){
    TH_STATUSLINE_BOX           = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_STATUSLINE_BOX" ]        : TH_THEME_COLOR
    TH_STATUSLINE_FULL_KEY      = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_STATUSLINE_FULL_KEY" ]   : TH_THEME_MINOR_COLOR
    TH_STATUSLINE_NORMAL_KEY    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_STATUSLINE_NORMAL_KEY" ] : UI_TEXT_DIM
    TH_STATUSLINE_NORMAL_VAL    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_STATUSLINE_NORMAL_VAL" ] : UI_TEXT_DIM
}

function comp_statusline_init( o, kp, val, bool ){
    comp_statusline_style_init()
    o[ kp, "TYPE" ] = "statusline"
    model_arr_init(o, kp)
    o[ kp, "sw" ] = (val != "") ? val : "\t"
    ctrl_sw_init( o, kp SUBSEP "expand", bool )
    comp_textbox_init(o, kp SUBSEP "short-help")
    comp_textbox_init(o, kp SUBSEP "long-help", "scrollable")
    comp_statusline_set_fullscreen(o, kp, 1, tapp_canvas_rowsize_get(), 1, tapp_canvas_colsize_get())
}

function comp_statusline_handle(o, kp, char_value, char_name, char_type,        _has_no_handle){
    if ( o[ kp, "TYPE" ] != "statusline" ) return false
    if ( ctrl_sw_get(o, kp SUBSEP "expand" )) {
        if (comp_textbox_handle( o, kp SUBSEP "long-help", char_value, char_name, char_type )) _has_no_handle = false
        else if ( o[ kp, "sw" ] == char_value ) {
            ctrl_page_set(o, kp SUBSEP "long-help", 1)
            ctrl_sw_toggle(o, kp SUBSEP "expand" )
            change_set(o, "fullscreen")
            paint_screen(comp_statusline_fullscreen_clear(o, kp))
        }
        else _has_no_handle = true
    }
    else if ( o[ kp, "sw" ] == char_value ) ctrl_sw_toggle(o, kp SUBSEP "expand" )
    else _has_no_handle = true

    if ( _has_no_handle == true ) return false
    change_set(o, kp, "statusline")
    return true
}

# Section: paint
function comp_statusline_set_fullscreen( o, kp, x1, x2, y1, y2 ){
    model_arr_set_key_value(o, kp, "full-size.x1", x1)
    model_arr_set_key_value(o, kp, "full-size.x2", x2)
    model_arr_set_key_value(o, kp, "full-size.y1", y1)
    model_arr_set_key_value(o, kp, "full-size.y2", y2)
}
function comp_statusline_fullscreen_clear(o, kp,    x1, x2, y1, y2){
    return painter_clear_screen( model_arr_get(o, kp, "full-size.x1")\
        , model_arr_get(o, kp, "full-size.x2") \
        , model_arr_get(o, kp, "full-size.y1") \
        , model_arr_get(o, kp, "full-size.y2") )
}

function comp_statusline_change_set_all(o, kp){
    change_set(o, kp, "statusline")
}

function comp_statusline_paint(o, kp, x1, x2, y1, y2,       l, i, s, c, v){
    if ( ! change_is(o, kp, "statusline") ) return
    change_unset(o, kp, "statusline")

    l = o[ kp, "data-arr", "data" L ]
    if (! comp_statusline_isfullscreen(o, kp)) {

        for (i=1; i<=l; ++i) {
            c = comp_statusline___get_command(o, kp, i)
            v = comp_statusline_data_get_short(o, kp, c)
            if (v == "") continue
            s = s th( TH_STATUSLINE_NORMAL_KEY, "<" c ">:" ) th( TH_STATUSLINE_NORMAL_VAL, v ) "  "
        }
        comp_textbox_put(o, kp SUBSEP "short-help", s)
        return painter_clear_screen(x1, x1, y1, y2) \
        comp_textbox_paint(o, kp SUBSEP "short-help", x1, x1, y1, y2)
    } else {
        for (i=1; i<=l; ++i) {
            c = comp_statusline___get_command(o, kp, i)
            v = comp_statusline_data_get_long(o, kp, c)
            if (v != "") s = ((s) ? s "\n" : "") th( TH_STATUSLINE_FULL_KEY, c ":" )"\n" v
        }

        comp_textbox_put(o, kp SUBSEP "long-help", s)
        x1 = model_arr_get(o, kp, "full-size.x1")
        x2 = model_arr_get(o, kp, "full-size.x2")
        y1 = model_arr_get(o, kp, "full-size.y1")
        y2 = model_arr_get(o, kp, "full-size.y2")

        return comp_statusline_fullscreen_clear(o, kp) \
        painter_box(x1, x2, y1, y2, TH_STATUSLINE_BOX) \
        comp_textbox_paint(o, kp SUBSEP "long-help", x1+1, x2-1, y1+1, y2-1)
    }
}
# EndSection

# Section: data
function comp_statusline___get_command(o, kp, i){
    return o[ kp, "data-arr", "data", i ]
}

function comp_statusline_isfullscreen(o, kp){
    return ctrl_sw_get( o, kp SUBSEP "expand"  )
}

function comp_statusline_data_get_long(o, kp, command){
    return model_arr_get(o, kp, command SUBSEP "long")
}

function comp_statusline_data_get_short(o, kp, command){
    return model_arr_get(o, kp, command SUBSEP "short")
}

function comp_statusline_data_set_long(o, kp, command, val){
    change_set(o, kp, "statusline")
    model_arr_set_key_value(o, kp, command SUBSEP "long", val)
}

function comp_statusline_data_set_short(o, kp, command, val){
    change_set(o, kp, "statusline")
    model_arr_set_key_value(o, kp, command SUBSEP "short", val)
}

function comp_statusline_data_put( o, kp, command, short, long){
    change_set(o, kp, "statusline")
    model_arr_add(o, kp, command)
    model_arr_set_key_value(o, kp, command SUBSEP "short", short)
    model_arr_set_key_value(o, kp, command SUBSEP "long", long)
}

function comp_statusline_data_clear( o, kp,     v ){
    change_set(o, kp, "statusline")
    v = o[ kp, "sw" ]
    model_arr_clear(o, kp)
    comp_statusline_init( o, kp, v, ctrl_sw_get(o, kp SUBSEP "expand" ) )
}
# EndSection
