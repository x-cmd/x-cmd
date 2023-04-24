function draw_gsel_style_init(){
    TH_GSEL_TITLE           =   UI_TEXT_DIM
    TH_GSEL_ITEM_FOCUSED    =   UI_TEXT_REV TH_THEME_COLOR
    TH_GSEL_ITEM_UNSELECTED =   ""
    TH_GSEL_ITEM_SELECTED   =   ""

    TH_GSEL_ITEM_FOCUSED_PREFIX     = ""
    TH_GSEL_ITEM_UNFOCUSED_PREFIX   = ""
    TH_GSEL_ITEM_UNSELECTED_PREFIX  = ""
    TH_GSEL_ITEM_SELECTED_PREFIX    = ""
    TH_GSEL_ITEM_PREFIX_WIDTH       = 0
}

function draw_gsel_change_set_all( o, kp ){
    change_set( o, kp, "gsel.title")
    change_set( o, kp, "gsel.body")
    change_set( o, kp, "gsel.foot")
}

function draw_gsel_paint( o, kp, x1, x2, y1, y2,             _draw_body, _draw_title, _draw_footer, _draw_box, w ){

    w = wcswidth_cache(TH_GSEL_ITEM_UNFOCUSED_PREFIX)
    _draw_title  = draw_gsel___on_title(o, kp, x1, x1, y1+w, y2)
    _draw_body   = draw_gsel___on_body(o, kp, x1+1, x2-1, y1, y2)
    _draw_footer = draw_gsel___on_footer(o, kp, x2, x2, y1+w, y2)

    return _draw_title _draw_body _draw_footer
}

function draw_gsel___on_body( o, kp, x1, x2, y1, y2,       r, w, iw, ps, l, i, _start, _end, _draw_body ){
    if ( ! change_is(o, kp, "gsel.body") ) return
    change_unset(o, kp, "gsel.body")
    comp_gsel___handle_slct(o, kp)

    r = x2-x1+1
    w = y2-y1+1
    l = model_arr_get(o, kp, "view-row" L)
    iw = (( (iw = comp_gsel_item_width_get(o, kp)) != "" ) ? iw : w )
    if ( iw > w ) iw = w
    ps = int( w / iw ) * r
    ctrl_page_init( o, kp, 1, l, "", ps, r)

    _start = ctrl_page_begin( o, kp )
    _end   = ctrl_page_end( o, kp )
    for (i=_start; i<=_end; ++i){
        _draw_body = _draw_body draw_gsel___on_cell( o, kp, i, iw ) \
            ( (i%r != 0) ? "\r\n" : "\r" painter_up(r-1) ) \
            painter_right( y1 + int( (i % ps) / r ) * iw )
    }

    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _draw_body
}

function draw_gsel___on_title(o, kp, x1, x2, y1, y2,       v){
    if ( ! change_is(o, kp, "gsel.title") ) return
    change_unset(o, kp, "gsel.title")
    v = comp_gsel___slct_get(o, kp)
    if (v == "") v = painter_goto_rel(x1, y1) th( TH_GSEL_TITLE, space_restrict_or_pad_utf8( comp_gsel_title_get(o, kp), y2-y1+1) )
    else         v = comp_gsel___slct_get_with_cursor(o, kp, x1, y1, y2)
    return painter_clear_screen(x1, x2, y1, y2) v
}

function draw_gsel___on_footer(o, kp, x1, x2, y1, y2,      v, i, s, p){
    if ( ! change_is(o, kp, "gsel.foot") ) return
    change_unset(o, kp, "gsel.foot")
    s = ctrl_page_pagesize_get(o, kp)
    i = comp_gsel_focused_item_get(o, kp)
    i = int( ( i - 1 ) / s ) + 1
    p = int( ( ctrl_page_max_get(o, kp) - 1 ) / s ) + 1
    v = th( UI_TEXT_DIM, space_restrict_or_pad_utf8( "<" i "/" p ">" , y2-y1+1) )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) v
}

function draw_gsel___on_cell( o, kp, i, w,         v, ri){
    w = w - TH_GSEL_ITEM_PREFIX_WIDTH
    ri = model_arr_get(o, kp, "view-row" SUBSEP i)
    v = comp_gsel_data_get(o, kp, ri)
    v = space_restrict_or_pad_utf8_esc(v, w)

    if (comp_gsel___cell_is_selected( o, kp, ri )) v = TH_GSEL_ITEM_SELECTED_PREFIX th( TH_GSEL_ITEM_SELECTED, v )
    else v = TH_GSEL_ITEM_UNSELECTED_PREFIX th( TH_GSEL_ITEM_UNSELECTED, v )

    if (i == comp_gsel_focused_item_get( o, kp )) v = TH_GSEL_ITEM_FOCUSED_PREFIX th( TH_GSEL_ITEM_FOCUSED, v )
    else v = TH_GSEL_ITEM_UNFOCUSED_PREFIX v
    return v
}

# Section: private
# function comp_gsel_title_set( o, kp, title ){
#     change_set(o, kp, "gsel.title")
#     return model_arr_set_key_value(o, kp, "title", title)
# }
# function comp_gsel_title_get( o, kp, title ){   return model_arr_get(o, kp, "title");  }
# function comp_gsel_item_width_set( o, kp, w ){
#     change_set(o, kp, "gsel.body")
#     change_set(o, kp, "gsel.foot")
#     return model_arr_set_key_value(o, kp, "width", w);
# }
# function comp_gsel_item_width_get( o, kp ){     return model_arr_get(o, kp, "width");  }
# function comp_gsel_data_len( o, kp ) {   return model_arr_data_len( o, kp );  }
# function comp_gsel_data_get( o, kp, idx ) {   return model_arr_data_get( o, kp, idx );  }
# function comp_gsel_data_add( o, kp, val ) {
#     change_set(o, kp, "gsel.body")
#     change_set(o, kp, "gsel.foot")
#     return model_arr_add( o, kp, val )
# }
# function comp_gsel_data_cp( o, kp, src, srckp,  start, end ) {
#     change_set(o, kp, "gsel.body")
#     change_set(o, kp, "gsel.foot")
#     return model_arr_cp( o, kp, src, srckp, start, end )
# }
# function comp_gsel_data_clear( o, kp ) {
#     change_set(o, kp, "gsel.body")
#     change_set(o, kp, "gsel.foot")
#     return model_arr_clear( o, kp )
# }
# EndSection
