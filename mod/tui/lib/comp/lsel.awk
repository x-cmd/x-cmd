BEGIN{ comp_lsel_color_init();  }
function comp_lsel_color_init(){
    TH_LSEL_ITEM_NORMAL     =   TH_THEME_COLOR UI_TEXT_BOLD
    TH_LSEL_ITEM_FOCUSED    =   UI_TEXT_REV
    TH_LSEL_TITLE           =   UI_TEXT_DIM
}
function comp_lsel_init( o, kp, title ) {
    o[ kp, "TYPE" ] = "lsel"

    ctrl_page_init( o, kp, 1 )
    ctrl_sw_init( o, kp, true )
    model_arr_init( o, kp )
    comp_lsel_title_set( o, kp, title )
    comp_lineedit_init(o, kp SUBSEP "select")
}

# TODO: Add Insert.
function comp_lsel_handle( o, kp, char_value, char_name, char_type ) {
    if ( o[ kp, "TYPE" ] != "lsel" ) return false
    if (char_name == U8WC_NAME_RIGHT)       ctrl_page_next_page(o, kp)
    else if (char_name == U8WC_NAME_LEFT)   ctrl_page_prev_page(o, kp)
    else if (char_name == U8WC_NAME_UP)     ctrl_page_rdec(o, kp)
    else if (char_name == U8WC_NAME_DOWN)   ctrl_page_rinc(o, kp)
    else if (char_name == U8WC_NAME_HORIZONTAL_TAB) ctrl_page_rinc(o, kp)
    else if (ctrl_sw_get(o, kp) == true) {
        if (char_name == U8WC_NAME_CARRIAGE_RETURN) ctrl_sw_toggle(o, kp)
        else if (comp_lsel_slct_set( o, kp, char_value, char_name, char_type )) {
            ctrl_page_set(o, kp, 1)
            comp_lsel_change_set_all( o, kp )
            return true
        }
    }
    else return false

    change_set( o, kp, "lsel.body")
    change_set( o, kp, "lsel.foot")
    return true
}

# Section: select
function comp_lsel_handle_slct(o, kp,          s, l, i, _viewl, idx){
    s = comp_lsel_slct_get( o, kp )
    l = comp_lsel_data_len( o, kp )
    for (i=1; i<=l; ++i){
        if ((s != "") && ((idx = index(comp_lsel_data_get( o, kp, i ), s)) <=0 )) continue
        model_arr_set_key_value(o, kp, "view-row" SUBSEP (++_viewl), i)
    }
    model_arr_set_key_value( o, kp, "view-row" L, _viewl )
}

function comp_lsel_slct_set( o, kp, char_value, char_name, char_type ){
    return comp_lineedit_handle(o, kp SUBSEP "select", char_value, char_name, char_type)
}
function comp_lsel_slct_get( o, kp ){
    return comp_lineedit_get(o, kp SUBSEP "select")
}
function comp_lsel_slct_get_with_cursor( o, kp, x1, y1, y2 ){
    comp_lineedit_change_set(o, kp SUBSEP "select")
    return comp_lineedit_paint_with_cursor(o, kp SUBSEP "select", x1, y1, y2)
}
# EndSection

function comp_lsel_focused_item_get(o, kp){ return ctrl_page_val(o, kp); }
function comp_lsel_focused_item_true_get(o, kp,         i){
    i = comp_lsel_focused_item_get(o, kp)
    return model_arr_get(o, kp, "view-row" SUBSEP i)
}
function comp_lsel_get_cur_item(o, kp,          i){
    i = comp_lsel_focused_item_true_get(o, kp)
    i = model_arr_get(o, kp, "view-row" SUBSEP i)
    return comp_lsel_data_get(o, kp, i)
}

function comp_lsel_change_set_all( o, kp ){
    change_set( o, kp, "lsel.title")
    change_set( o, kp, "lsel.body")
    change_set( o, kp, "lsel.foot")
}

function comp_lsel_paint( o, kp, x1, x2, y1, y2,             _comp_body, _comp_title, _comp_footer, _comp_box ){

    _comp_title  = comp_lsel_paint_title(o, kp, x1, x1, y1, y2)
    _comp_body   = comp_lsel_paint_body(o, kp, x1+1, x2-1, y1, y2)
    _comp_footer = comp_lsel_paint_footer(o, kp, x2, x2, y1, y2)

    return _comp_title _comp_body _comp_footer
}

function comp_lsel_paint_body( o, kp, x1, x2, y1, y2,        r, w, l, _start, _end, i, _next_line, _comp_body){
    if ( ! change_is(o, kp, "lsel.body") ) return
    change_unset(o, kp, "lsel.body")
    comp_lsel_handle_slct(o, kp)

    r = x2-x1+1
    w = y2-y1+1
    l = model_arr_get(o, kp, "view-row" L)
    ctrl_page_init(o, kp, 1, l, "", r)
    _next_line = "\r\n" painter_right( y1 )

    _start = ctrl_page_begin( o, kp )
    _end   = ctrl_page_end( o, kp )
    for (i=_start; i<=_end; ++i){
        _comp_body = _comp_body comp_lsel_paint_cell( o, kp, i, w ) _next_line
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _comp_body
}

function comp_lsel_paint_cell( o, kp, i, w,         v, ri ){
    ri = model_arr_get(o, kp, "view-row" SUBSEP i)
    v = comp_lsel_data_get(o, kp, ri)
    v = space_restrict_or_pad_utf8(v, w)
    if ( i == comp_lsel_focused_item_get( o, kp ) ) return th( TH_LSEL_ITEM_FOCUSED, v )
    else return th( TH_LSEL_ITEM_NORMAL, v )
}

function comp_lsel_paint_title(o, kp, x1, x2, y1, y2,       v){
    if ( ! change_is(o, kp, "lsel.title") ) return
    change_unset(o, kp, "lsel.title")
    v = comp_lsel_slct_get(o, kp)
    if (v == "") v = painter_goto_rel(x1, y1) th( TH_LSEL_TITLE, space_restrict_or_pad_utf8( comp_lsel_title_get(o, kp), y2-y1+1) )
    else         v = comp_lsel_slct_get_with_cursor(o, kp, x1, y1, y2)
    return painter_clear_screen(x1, x2, y1, y2) v
}

function comp_lsel_paint_footer(o, kp, x1, x2, y1, y2,      v, i, s, p){
    if ( ! change_is(o, kp, "lsel.foot") ) return
    change_unset(o, kp, "lsel.foot")
    w = y2-y1+1
    i = comp_lsel_focused_item_get(o, kp)
    s = ctrl_page_pagesize_get(o, kp)
    i = int( ( i - 1 ) / s ) + 1
    p = int( ( ctrl_page_max_get(o, kp) - 1 ) / s ) + 1
    v = th( UI_TEXT_DIM, space_restrict_or_pad_utf8( "<" i "/" p ">" , w) )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) v
}

# Section: private
function comp_lsel_title_set( o, kp, title ){
    change_set(o, kp, "lsel.title")
    return model_arr_set_key_value(o, kp, "title", title)
}
function comp_lsel_title_get( o, kp, title ){   return model_arr_get(o, kp, "title");  }
function comp_lsel_data_len( o, kp ) {   return model_arr_data_len( o, kp );  }
function comp_lsel_data_get( o, kp, idx ) {   return model_arr_data_get( o, kp, idx );  }
function comp_lsel_data_add( o, kp, val ) {
    change_set(o, kp, "lsel.body")
    change_set(o, kp, "lsel.foot")
    return model_arr_add( o, kp, val )
}
function comp_lsel_data_cp( o, kp, src, srckp, start, end ) {
    change_set(o, kp, "lsel.body")
    change_set(o, kp, "lsel.foot")
    return model_arr_cp( o, kp, src, srckp, start, end )
}
function comp_lsel_data_clear( o, kp ) {
    change_set(o, kp, "lsel.body")
    change_set(o, kp, "lsel.foot")
    return model_arr_clear( o, kp )
}
# EndSection
