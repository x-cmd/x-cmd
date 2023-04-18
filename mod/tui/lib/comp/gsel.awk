function comp_gsel_style_init(){
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
function comp_gsel_init( o, kp, title, filter_sw ) {
    o[ kp, "TYPE" ] = "gsel"

    ctrl_page_init( o, kp )
    ctrl_sw_init( o, kp SUBSEP "isfilter" , ((filter_sw == false) ? false : true) )
    ctrl_sw_init(o, kp SUBSEP "ismultiple", false)
    model_arr_init( o, kp )
    comp_gsel_title_set( o, kp, title )
    comp_lineedit_init(o, kp SUBSEP "select")
    comp_gsel_style_init()
}

function comp_gsel_filter_sw_toggle(o, kp){     ctrl_sw_toggle( o, kp SUBSEP "isfilter");   }
function comp_gsel_filter_sw_get(o, kp){        return ctrl_sw_get(o, kp SUBSEP "isfilter");    }
function comp_gsel_multiple_sw_toggle(o, kp){   ctrl_sw_toggle( o, kp SUBSEP "ismultiple");   }
function comp_gsel_multiple_sw_get(o, kp){      return ctrl_sw_get(o, kp SUBSEP "ismultiple");    }

function comp_gsel_set_limit( o, kp, v ){
    if (v == 1) return
    comp_gsel_set_multiple_style()
    ctrl_sw_init(o, kp SUBSEP "ismultiple", true)
    o[ kp, "limit" ] = (v) ? v : "no-limit"
}

function comp_gsel_set_multiple_style(){
    TH_GSEL_ITEM_FOCUSED    =   TH_THEME_COLOR
    TH_GSEL_ITEM_SELECTED   =   TH_THEME_COLOR
    TH_GSEL_ITEM_UNSELECTED =   ""

    TH_GSEL_ITEM_FOCUSED_PREFIX     = th(TH_THEME_COLOR, "> ")
    TH_GSEL_ITEM_UNFOCUSED_PREFIX   = "  "
    TH_GSEL_ITEM_UNSELECTED_PREFIX  = th(TH_THEME_COLOR, "○ ")
    TH_GSEL_ITEM_SELECTED_PREFIX    = th(TH_THEME_COLOR, "◉ ")      # "● "
    TH_GSEL_ITEM_PREFIX_WIDTH = 4
}

# TODO: Add Insert.
function comp_gsel_handle( o, kp, char_value, char_name, char_type ) {
    if ( o[ kp, "TYPE" ] != "gsel" ) return false
    if (char_name == U8WC_NAME_UP)                      ctrl_page_rdec(o, kp)
    else if (char_name == U8WC_NAME_DOWN)               ctrl_page_rinc(o, kp)
    else if (char_name == U8WC_NAME_LEFT)               ctrl_page_prev_col(o, kp)
    else if (char_name == U8WC_NAME_RIGHT)              ctrl_page_next_col(o, kp)
    else if (char_name == U8WC_NAME_DATA_LINK_ESCAPE)   ctrl_page_prev_page(o, kp)
    else if (char_name == U8WC_NAME_SHIFT_OUT)          ctrl_page_next_page(o, kp)
    else if (comp_gsel_filter_sw_get(o, kp) == true) {
        if (char_name == U8WC_NAME_CARRIAGE_RETURN) comp_gsel_filter_sw_toggle(o, kp)
        else if ((char_name == U8WC_NAME_HORIZONTAL_TAB) && comp_gsel_multiple_sw_get(o, kp)) {
            comp_gsel___cell_selected_sw_toggle(o, kp, comp_gsel_focused_item_true_get( o, kp ))
            ctrl_page_rinc(o, kp)
        }
        else if (comp_gsel___slct_set( o, kp, char_value, char_name, char_type )) {
            ctrl_page_set(o, kp, 1)
            comp_gsel_change_set_all( o, kp )
            return true
        }
    }
    else if (char_value == "k")     ctrl_page_rdec(o, kp)
    else if (char_value == "j")     ctrl_page_rinc(o, kp)
    else if (char_value == "h")     ctrl_page_prev_col(o, kp)
    else if (char_value == "l")     ctrl_page_next_col(o, kp)
    else if (char_value == "p")     ctrl_page_prev_page(o, kp)
    else if (char_value == "n")     ctrl_page_next_page(o, kp)
    else if ((char_value == " ") && comp_gsel_multiple_sw_get(o, kp)) {
        comp_gsel___cell_selected_sw_toggle(o, kp, comp_gsel_focused_item_true_get( o, kp ))
        ctrl_page_rinc(o, kp)
    }
    else return false

    change_set( o, kp, "gsel.body")
    change_set( o, kp, "gsel.foot")
    return true
}

# Section: gsel model
function comp_gsel_focused_item_get(o, kp){
    return ctrl_page_val(o, kp)
}

function comp_gsel_focused_item_true_get( o, kp,        i ){
    i = comp_gsel_focused_item_get(o, kp)
    i = model_arr_get(o, kp, "view-row" SUBSEP i)
    return i
}
function comp_gsel_get_cur_item(o, kp,          i){
    i = comp_gsel_focused_item_true_get( o, kp )
    return comp_gsel_data_get(o, kp, i)
}

function comp_gsel___cell_selected_set( o, kp, i, tf ){
    o[ kp, "data-arr", "data", i, "SELECTED" ]= tf = ((tf != "") ? tf : true)
    if (tf == true) model_arr_add( o, kp SUBSEP "selected", i )
    else model_arr_rm( o, kp SUBSEP "selected", i )
}

function comp_gsel___selected_len(o, kp){
    return model_arr_data_len( o, kp SUBSEP "selected" )
}

function comp_gsel_get_selected_item(o, kp,         i, l, v){
    l = comp_gsel___selected_len(o, kp)
    for (i=1; i<=l; ++i) v = ((v) ? v "\n" : "") comp_gsel_data_get(o, kp, model_arr_data_get(o, kp SUBSEP "selected", i))
    return v
}

function comp_gsel___cell_is_selected( o, kp, i ){
    return o[ kp, "data-arr", "data", i, "SELECTED" ]
}

function comp_gsel___cell_selected_sw_toggle( o, kp, i,           l ){
    if (comp_gsel___cell_is_selected( o, kp, i ))  comp_gsel___cell_selected_set(o, kp, i, false )
    else if (( (l=o[ kp, "limit" ]) == "no-limit" ) || l > comp_gsel___selected_len( o, kp ))
        comp_gsel___cell_selected_set(o, kp, i, true)
}

function comp_gsel___handle_slct(o, kp,          s, l, i, _viewl ){
    s = comp_gsel___slct_get( o, kp )
    l = comp_gsel_data_len( o, kp )
    model_arr_set_key_value( o, kp, "view-row" SUBSEP 1, 0 )
    for (i=1; i<=l; ++i){
        if ((s != "") && ( index(comp_gsel_data_get( o, kp, i ), s) <=0 )) continue
        model_arr_set_key_value(o, kp, "view-row" SUBSEP (++_viewl), i)
    }
    model_arr_set_key_value( o, kp, "view-row" L, _viewl )
}

function comp_gsel___slct_set( o, kp, char_value, char_name, char_type ){
    return comp_lineedit_handle(o, kp SUBSEP "select", char_value, char_name, char_type)
}
function comp_gsel___slct_get( o, kp ){
    return comp_lineedit_get(o, kp SUBSEP "select")
}
function comp_gsel___slct_get_with_cursor( o, kp, x1, y1, y2 ){
    comp_lineedit_width(o, kp SUBSEP "select", y2-y1)
    comp_lineedit_change_set(o, kp SUBSEP "select")
    return comp_lineedit_paint_with_cursor(o, kp SUBSEP "select", x1, y1, y2)
}

# EndSection

# Section: gsel paint
function comp_gsel_change_set_all( o, kp ){
    change_set( o, kp, "gsel.title")
    change_set( o, kp, "gsel.body")
    change_set( o, kp, "gsel.foot")
}

function comp_gsel_paint( o, kp, x1, x2, y1, y2,             _comp_body, _comp_title, _comp_footer, _comp_box, w ){

    w = wcswidth_cache(TH_GSEL_ITEM_UNFOCUSED_PREFIX)
    _comp_title  = comp_gsel_paint_title(o, kp, x1, x1, y1+w, y2)
    _comp_body   = comp_gsel_paint_body(o, kp, x1+1, x2-1, y1, y2)
    _comp_footer = comp_gsel_paint_footer(o, kp, x2, x2, y1+w, y2)

    return _comp_title _comp_body _comp_footer
}

function comp_gsel_paint_body( o, kp, x1, x2, y1, y2,       r, w, iw, ps, l, i, _start, _end, _comp_body ){
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
        _comp_body = _comp_body comp_gsel___paint_cell( o, kp, i, iw ) \
            ( (i%r != 0) ? "\r\n" : "\r" painter_up(r-1) ) \
            painter_right( y1 + int( (i % ps) / r ) * iw )
    }

    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _comp_body
}

function comp_gsel_paint_title(o, kp, x1, x2, y1, y2,       v){
    if ( ! change_is(o, kp, "gsel.title") ) return
    change_unset(o, kp, "gsel.title")
    v = comp_gsel___slct_get(o, kp)
    if (v == "") v = painter_goto_rel(x1, y1) th( TH_GSEL_TITLE, space_restrict_or_pad_utf8( comp_gsel_title_get(o, kp), y2-y1+1) )
    else         v = comp_gsel___slct_get_with_cursor(o, kp, x1, y1, y2)
    return painter_clear_screen(x1, x2, y1, y2) v
}

function comp_gsel_paint_footer(o, kp, x1, x2, y1, y2,      v, i, s, p){
    if ( ! change_is(o, kp, "gsel.foot") ) return
    change_unset(o, kp, "gsel.foot")
    s = ctrl_page_pagesize_get(o, kp)
    i = comp_gsel_focused_item_get(o, kp)
    i = int( ( i - 1 ) / s ) + 1
    p = int( ( ctrl_page_max_get(o, kp) - 1 ) / s ) + 1
    v = th( UI_TEXT_DIM, space_restrict_or_pad_utf8( "<" i "/" p ">" , y2-y1+1) )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) v
}

function comp_gsel___paint_cell( o, kp, i, w,         v, ri){
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

# EndSection

# Section: private
function comp_gsel_title_set( o, kp, title ){
    change_set(o, kp, "gsel.title")
    return model_arr_set_key_value(o, kp, "title", title)
}
function comp_gsel_title_get( o, kp, title ){   return model_arr_get(o, kp, "title");  }
function comp_gsel_item_width_set( o, kp, w ){
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    return model_arr_set_key_value(o, kp, "width", w);
}
function comp_gsel_item_width_get( o, kp ){     return model_arr_get(o, kp, "width");  }
function comp_gsel_data_len( o, kp ) {   return model_arr_data_len( o, kp );  }
function comp_gsel_data_get( o, kp, idx ) {   return model_arr_data_get( o, kp, idx );  }
function comp_gsel_data_add( o, kp, val ) {
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    return model_arr_add( o, kp, val )
}
function comp_gsel_data_cp( o, kp, src, srckp,  start, end ) {
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    return model_arr_cp( o, kp, src, srckp, start, end )
}
function comp_gsel_data_clear( o, kp ) {
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    return model_arr_clear( o, kp )
}
# EndSection
