function comp_gsel_style_init(){
    draw_gsel_style_init()
}

function comp_gsel_init( o, kp, title, filter_sw ) {
    o[ kp, "TYPE" ] = "gsel"

    ctrl_page_init( o, kp )
    ctrl_sw_init( o, kp SUBSEP "isfilter" , ((filter_sw == false) ? false : true) )
    ctrl_sw_init(o, kp SUBSEP "ismultiple", false)
    model_arr_init( o, kp )
    comp_gsel_title( o, kp, title )
    comp_lineedit_init(o, kp SUBSEP "select")
    comp_gsel_style_init()
    draw_gsel_change_set_all( o, kp )
}

function comp_gsel_filter_sw_toggle(o, kp){     ctrl_sw_toggle( o, kp SUBSEP "isfilter");   }
function comp_gsel_filter_sw_get(o, kp){        return ctrl_sw_get(o, kp SUBSEP "isfilter");    }
function comp_gsel_multiple_sw_toggle(o, kp){   ctrl_sw_toggle( o, kp SUBSEP "ismultiple");   }
function comp_gsel_multiple_sw_get(o, kp){      return ctrl_sw_get(o, kp SUBSEP "ismultiple");    }

function comp_gsel_set_limit( o, kp, v ){
    if (v == 1) return
    comp_gsel_set_multiple_style()
    ctrl_sw_init(o, kp SUBSEP "ismultiple", true)
    draw_gsel_cell_selected_limit( o, kp, ((v ~ "^[0-9]+$") ? int(v) : "no-limit") )
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
            draw_gsel_cell_selected_sw_toggle(o, kp, comp_gsel_get_cur_cell( o, kp ))
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
        draw_gsel_cell_selected_sw_toggle(o, kp, comp_gsel_get_cur_cell( o, kp ))
        ctrl_page_rinc(o, kp)
    }
    else return false

    change_set( o, kp, "gsel.body")
    change_set( o, kp, "gsel.foot")
    return true
}

# Section: gsel model
function comp_gsel_model_end(o, kp){
    draw_gsel_change_set_all( o, kp )
    comp_gsel___slct_data( o, kp )
}

function comp_gsel_get_focused_cell(o, kp){
    return ctrl_page_val(o, kp)
}

function comp_gsel_get_cur_cell( o, kp,        i ){
    i = comp_gsel_get_focused_cell(o, kp)
    i = model_arr_get(o, kp, "view-row" SUBSEP i)
    return i
}
function comp_gsel_get_cur_item(o, kp,          i){
    i = comp_gsel_get_cur_cell( o, kp )
    return comp_gsel_data_get(o, kp, i)
}

function comp_gsel_get_selected_item(o, kp,         i, l, v){
    l = draw_gsel_cell_selected_count(o, kp)
    for (i=1; i<=l; ++i) v = ((v) ? v "\n" : "") comp_gsel_data_get(o, kp, draw_gsel_select_item(o, kp, i))
    return v
}

function comp_gsel___slct_data(o, kp,          s, l, i, _viewl ){
    s = comp_gsel___slct_get( o, kp )
    l = comp_gsel_data_len( o, kp )
    model_arr_set_key_value( o, kp, "view-row" SUBSEP 1, 0 )
    for (i=1; i<=l; ++i){
        if ((s != "") && ( index(comp_gsel_data_get( o, kp, i ), s) <=0 )) continue
        model_arr_set_key_value(o, kp, "view-row" SUBSEP (++_viewl), i)
    }
    comp_gsel___slct_data_maxrow( o, kp, _viewl )
}

function comp_gsel___slct_data_maxrow(o, kp, v){
    if ( v == "")  return ctrl_page_max_get(o, kp)
    else           ctrl_page_max_set(o, kp, v)
}
function comp_gsel___slct_set( o, kp, char_value, char_name, char_type ){
    return comp_lineedit_handle(o, kp SUBSEP "select", char_value, char_name, char_type)
}
function comp_gsel___slct_put(o, kp, v){      comp_lineedit_put(o, kp SUBSEP "select", v);    }
function comp_gsel___slct_get(o, kp){         return comp_lineedit_get(o, kp SUBSEP "select");    }
function comp_gsel___slct_width(o, kp){       return comp_lineedit_width(o, kp SUBSEP "select");    }
function comp_gsel___slct_cursor_pos(o, kp){  return comp_lineedit___cursor_pos(o, kp SUBSEP "select");    }
function comp_gsel___slct_start_pos(o, kp){   return comp_lineedit___start_pos(o, kp SUBSEP "select");    }

# EndSection

# Section: gsel paint
function comp_gsel_change_set_all( o, kp ){
    draw_gsel_change_set_all(o, kp)
}

function comp_gsel_paint( o, kp, x1, x2, y1, y2, no_title, no_footer,       _opt, _res, _body_change, _title_change ){
    _body_change = change_is(o, kp, "gsel.body")
    _title_change = change_is(o, kp, "gsel.title")
    opt_set( _opt, "item.width",    comp_gsel_item_width(o, kp))
    opt_set( _opt, "cur.cell",      comp_gsel_get_focused_cell(o, kp))
    opt_set( _opt, "data.maxrow",   comp_gsel___slct_data_maxrow(o, kp) )

    if ( _title_change ) {
        opt_set( _opt, "title.text",    comp_gsel_title(o, kp) )
        opt_set( _opt, "filter.text",   comp_gsel___slct_get(o, kp) )
        opt_set( _opt, "filter.width",  comp_gsel___slct_width(o, kp) )
        opt_set( _opt, "filter.cursor", comp_gsel___slct_cursor_pos(o, kp) )
        opt_set( _opt, "filter.start",  comp_gsel___slct_start_pos(o, kp) )
    }

    _res = draw_gsel_paint( o, kp, x1, x2, y1, y2, no_title, no_footer, _opt )

    if ( _body_change ) {
        comp_gsel___pagesize( o, kp, opt_get( _opt, "pagesize" ))
        comp_gsel___pagesize_row( o, kp, opt_get( _opt, "pagesize.row" ))
    }
    return _res
}

function comp_gsel___pagesize(o, kp, v){
    if (v == "")  return ctrl_page_pagesize_get(o, kp)
    else          ctrl_page_pagesize_set(o, kp, v)
}

function comp_gsel___pagesize_row(o, kp, v){
    if (v == "")  return ctrl_page_rowsize_get(o, kp)
    else          ctrl_page_rowsize_set(o, kp, v)
}

# EndSection

# Section: private
function comp_gsel_title( o, kp, v ){
    if ( v == "" )      return model_arr_get(o, kp, "title")
    change_set(o, kp, "gsel.title")
    return model_arr_set_key_value(o, kp, "title", v)
}

function comp_gsel_item_width( o, kp, w ){
    if ( w == "" )      return model_arr_get(o, kp, "width")
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    return model_arr_set_key_value(o, kp, "width", w);
}

function comp_gsel_data_len( o, kp ) {   return model_arr_data_len( o, kp );  }
function comp_gsel_data_get( o, kp, idx ) {   return model_arr_data_get( o, kp, idx );  }
function comp_gsel_data_add( o, kp, val ) {
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    model_arr_add( o, kp, val )
    comp_gsel_model_end( o, kp )
}
function comp_gsel_data_cp( o, kp, src, srckp,  start, end ) {
    model_arr_cp( o, kp, src, srckp, start, end )
    comp_gsel_model_end( o, kp )
}
function comp_gsel_data_clear( o, kp ) {
    change_set(o, kp, "gsel.body")
    change_set(o, kp, "gsel.foot")
    return model_arr_clear( o, kp )
}
# EndSection
