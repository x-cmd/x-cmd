
function comp_table_init( o, kp ){
    draw_table_style_init()
    o[ kp, "TYPE" ] = "table"
    table_arr_init(o, kp)
    ctrl_page_init( o, kp, 1)
    ctrl_num_init( o, kp, 1)
    ctrl_sw_init( o, kp SUBSEP "ctrl.filter", false )
    ctrl_sw_init( o, kp SUBSEP "ctrl.search", false )

    draw_table_cell_highlight( o, kp, 1, 1, true )
    draw_table_row_highlight( o, kp, 1, true )
    draw_table_col_highlight( o, kp, 1, true )

    comp_textbox_init(o, kp SUBSEP "footer-textbox")
    draw_table_init( o, kp )
    comp_table_display_column_num( o, kp, true )
}

# Section: ctrl handle
function comp_table_set_limit(o, kp, v) {
    if (v <= 1) return
    comp_table___multiple_mode(o, kp, true)
    draw_table_row_selected_limit( o, kp, ((v ~ "^[0-9]+$") ? int(v) : "no-limit") )
}

function comp_table___multiple_mode(o, kp, v){
    if ( v == "" )      return o[ kp, "ismultiple" ]
    o[ kp, "ismultiple" ] = (v == true)
}

function comp_table_display_column_num(o, kp, v){
    if (v == "") return o[ kp, "display_num" ]
    o[ kp, "display_num" ] = v
}

function comp_table_handle( o, kp, char_value, char_name, char_type,        r, c, _has_no_handle ) {

    if ( o[ kp, "TYPE" ] != "table" ) return false
    # slct: remap
    draw_table_cell_highlight( o, kp, r = comp_table_get_focused_row(o, kp), c = comp_table_get_focused_col(o, kp), false )
    draw_table_row_highlight( o, kp, r, false )
    draw_table_col_highlight( o, kp, c, false )

    if (comp_table_ctrl_filter_sw_get(o, kp) == true){
        if (char_name == U8WC_NAME_CARRIAGE_RETURN) comp_table_ctrl_filter_sw_toggle(o, kp)
        else if (comp_table___slct_handle(o, kp, char_value, char_name, char_type)) ctrl_page_set( o, kp, 1)
        else _has_no_handle = true
    }
    else if (comp_table_ctrl_search_sw_get(o, kp) == true){
        if (char_name == U8WC_NAME_UP)                      comp_table_ctrl_search_dec(o, kp)
        else if (char_name == U8WC_NAME_DOWN)               comp_table_ctrl_search_inc(o, kp)
        else if (char_name == U8WC_NAME_CARRIAGE_RETURN)    comp_table_ctrl_search_sw_toggle(o, kp)
        else if (comp_table___search_handle(o, kp, char_value, char_name, char_type)) comp_table___search_date( o, kp )
        else _has_no_handle = true
    }
    else if (char_value == "n")             ctrl_page_next_page(o, kp)
    else if (char_value == "p")             ctrl_page_prev_page(o, kp)
    else if ((char_value == "k") || (char_name == U8WC_NAME_UP))    ctrl_page_rdec(o, kp)
    else if ((char_value == "j") || (char_name == U8WC_NAME_DOWN))  ctrl_page_rinc(o, kp)
    else if ((char_value == "h") || (char_name == U8WC_NAME_LEFT))  _has_no_handle = 1 - comp_table___handle_left(o, kp )
    else if ((char_value == "l") || (char_name == U8WC_NAME_RIGHT)) _has_no_handle = 1 - comp_table___handle_right(o, kp )
    else if (((char_value == " ") || (char_name == U8WC_NAME_HORIZONTAL_TAB)) && comp_table___multiple_mode(o, kp)) {
        comp_table___row_selected_sw_toggle(o, kp, comp_table_get_cur_row(o, kp))
        ctrl_page_rinc(o, kp)
    }
    else _has_no_handle = true

    if ( _has_no_handle != true ){
        change_set(o, kp, "table.head")
        change_set(o, kp, "table.body")
        change_set(o, kp, "table.foot")
    }

    draw_table_cell_highlight( o, kp, r = comp_table_get_focused_row(o, kp), c = comp_table_get_focused_col(o, kp), true )
    draw_table_row_highlight( o, kp, r, true )
    draw_table_col_highlight( o, kp, c, true )

    return ( _has_no_handle == true ) ? false : true

    # sort: remap
}

function comp_table___handle_left( o, kp ){
    if (ctrl_num_get( o, kp ) == ctrl_num_get_min(o, kp)) return false
    ctrl_num_dec(o, kp )
    return true
}

function comp_table___handle_right( o, kp ){
    if (ctrl_num_get( o, kp ) == ctrl_num_get_max(o, kp)) return false
    ctrl_num_inc(o, kp )
    return true
}

function comp_table___row_selected_sw_toggle(o, kp, r){
    draw_table_row_selected_sw_toggle(o, kp, r)
}

# EndSection

# Section: filter
function comp_table_ctrl_filter_sw_get(o, kp){  return ctrl_sw_get(o, kp SUBSEP "ctrl.filter"); }
function comp_table_ctrl_filter_sw_toggle(o, kp){   ctrl_sw_toggle(o, kp SUBSEP "ctrl.filter"); }
function comp_table___slct_get(o, kp, coli){    return comp_lineedit_get(o, kp SUBSEP "filter" SUBSEP coli);  }
function comp_table___slct_width(o, kp, coli){  return comp_lineedit_width(o, kp SUBSEP "filter" SUBSEP coli);    }
function comp_table___slct_cursor_pos(o, kp, coli){  return comp_lineedit___cursor_pos(o, kp SUBSEP "filter" SUBSEP coli);    }
function comp_table___slct_start_pos(o, kp, coli){  return comp_lineedit___start_pos(o, kp SUBSEP "filter" SUBSEP coli);    }
function comp_table___slct_handle(o, kp, char_value, char_name, char_type,       _kp){
    _kp = kp SUBSEP "filter" SUBSEP comp_table_get_cur_col(o, kp)
    if (comp_lineedit_handle(o, _kp, char_value, char_name, char_type)) {
        change_set( o, kp, "table.filter" )
        return true
    }
}

function comp_table___slct_data( o, kp,             i, l, _viewl ){
    l = comp_table_model_maxrow(o, kp)
    model_arr_set_key_value(o, kp, "view-row" SUBSEP 1, 0)
    for (i=1; i<=l; ++i) {
        if (comp_table___slct_data_do( o, kp, i ) == false) continue
        model_arr_set_key_value(o, kp, "view-row" SUBSEP (++_viewl), i)
    }
    comp_table___slct_data_maxrow( o, kp, int(_viewl) )
}

function comp_table___slct_data_do( o, kp, rowi,         i, l, _slct){
    l = comp_table_model_maxcol(o, kp)
    for (i=1; i<=l; ++i) {
        _slct = comp_table___slct_get(o, kp, i)
        if (_slct == "") continue
        if (index(table_arr_get_data(o, kp, rowi, i), _slct)<=0) return false
    }
    return true
}

function comp_table___slct_data_maxrow(o, kp, v){
    if ( v == "")  return ctrl_page_max_get(o, kp)
    else           ctrl_page_max_set(o, kp, v)
}

## Section: sort: TODO by el
# EndSection

# Section: search
function comp_table_ctrl_search_sw_get(o, kp){  return ctrl_sw_get(o, kp SUBSEP "ctrl.search"); }
function comp_table_ctrl_search_sw_toggle(o, kp){
    ctrl_sw_toggle(o, kp SUBSEP "ctrl.search")
    if (comp_table_ctrl_search_sw_get(o, kp))
        comp_lineedit_init(o, kp SUBSEP "search", "", 30)
}
function comp_table_ctrl_search_dec(o, kp){
    r = comp_table_get_focused_row(o, kp)
    comp_table___search_date(o, kp, r, -1)
}

function comp_table_ctrl_search_inc(o, kp){
    r = comp_table_get_focused_row(o, kp)
    comp_table___search_date(o, kp, r, +1)
}

function comp_table___search_get(o, kp){    return comp_lineedit_get(o, kp SUBSEP "search");  }
function comp_table___search_width(o, kp){  return comp_lineedit_width(o, kp SUBSEP "search");    }
function comp_table___search_cursor_pos(o, kp){  return comp_lineedit___cursor_pos(o, kp SUBSEP "search");    }
function comp_table___search_start_pos(o, kp){  return comp_lineedit___start_pos(o, kp SUBSEP "search");    }
function comp_table___search_handle(o, kp, char_value, char_name, char_type){
    if (comp_lineedit_handle(o, kp SUBSEP "search", char_value, char_name, char_type)) {
        change_set( o, kp, "table.search" )
        return true
    }
}
function comp_table___search_date(o, kp, r, step,        _search, l, c, i){
    c = comp_table_get_cur_col(o, kp)
    if ((_search = comp_table___search_get(o, kp)) == "") return
    step = (step) ? step : 1
    if (step > 0) {
        l = comp_table_model_maxrow(o, kp)
        for (i=r+1; i<=l; i+=step)
            if (index(table_arr_get_data(o, kp, i, c), _search) > 0)
                return ctrl_page_set( o, kp, i )
    } else {
        for (i=r-1; i>=1; i+=step)
            if (index(table_arr_get_data(o, kp, i, c), _search) > 0)
                return ctrl_page_set( o, kp, i )
    }
}
# EndSection

# Section: table model data
function comp_table_model_end( o, kp ){
    change_set( o, kp, "table.head" )
    change_set( o, kp, "table.body" )
    change_set( o, kp, "table.foot" )
    comp_table___slct_data( o, kp )
}

function comp_table_model_set( o, kp, arr,      _start, _end, i, l, j ){
    l = int(arr[ "col" ])
    _start = int(arr[ "start" ])
    _end = int(arr[ "end" ])
    for (i=_start; i<=_end; ++i)
        for (j=1; j<=l; ++j)
            table_arr_data_add(o, kp, i, j, arr[i, j])

    if ( _end > comp_table_model_maxrow(o, kp)) comp_table_model_maxrow(o, kp, _end)
}

function comp_table_model_set_cell(o, kp, i, j, val){
    table_arr_data_add(o, kp, i, j, val)
    if (i > comp_table_model_maxrow(o, kp)) comp_table_model_maxrow(o, kp, i)
}

function comp_table_model_maxrow(o, kp, maxrow){
    if (maxrow == "")   return model_arr_get(o, kp, "max-row")
    else                model_arr_set_key_value(o, kp, "max-row", maxrow)
}

function comp_table_model_maxcol(o, kp){
    return table_arr_head_len(o, kp)
}

function comp_table_head_add(o, kp, title){
    change_set(o, kp, "table.head")
    return table_arr_head_add( o, kp, title )
}

function comp_table_layout_avg_ele_add(o, kp, colid, min, max){
    comp_lineedit_init(o, kp SUBSEP "filter" SUBSEP colid, "", max)
    return layout_avg_ele_add( o, kp, colid, min, max )
}

function comp_table_get_head_title(o, kp, i){
    return table_arr_head_get(o, kp, i)
}

function comp_table_get_focused_row(o, kp){
    return ctrl_page_val(o, kp)
}

function comp_table_get_focused_col(o, kp){
    return ctrl_num_get(o, kp)
}

function comp_table_get_cur_row(o, kp){
    return model_arr_get(o, kp, "view-row" SUBSEP comp_table_get_focused_row(o, kp))
}

function comp_table_get_cur_col(o, kp){
    return layout_avg_get_item(o, kp, comp_table_get_focused_col(o, kp))
}

function comp_table_get_cur_line(o, kp, has_color, sep,             _line, _color_end, _color, l, i, ri){
    if (sep == "") sep = "\n"
    l = comp_table_model_maxcol(o, kp)
    ri = comp_table_get_cur_row(o, kp)
    if (has_color) { _color = TH_TABLE_CURRENT_INFO; _color_end = UI_END; }
    _line = _color comp_table_get_head_title(o, kp, 1) ": " _color_end table_arr_get_data(o, kp, ri, 1)
    for (i=2; i<=l; ++i) _line = _line sep _color comp_table_get_head_title(o, kp, i) ": " _color_end table_arr_get_data(o, kp, ri, i)
    return _line
}

# table model request
BEGIN{
    FULLDATA_MODE_FALSE = 0
    FULLDATA_MODE_ONTHEWAY = 1
    FULLDATA_MODE_TRUE = 2
}

function comp_table_model_fulldata_mode( o, kp, mode ){
    if (mode == "") return o[ kp, "fulldata_mode" ]
    else            return o[ kp, "fulldata_mode" ] = mode
}

function comp_table_model_fulldata_mode_is_ontheway( o, kp ){
    return (o[ kp, "fulldata_mode" ] == FULLDATA_MODE_ONTHEWAY)
}

function comp_table_model_isfulldata( o, kp ){
    return (comp_table_model_maxrow(o, kp) <= table_arr_available_count(o, kp))
}

function comp_table_unava(o, kp, row){
    if (row == "")  return o[ kp, "unava-row" ]
    else            return o[ kp, "unava-row" ] = row
}

function comp_table_get_the_first_unava(o, kp,          i, l){
    l = comp_table_model_maxrow(o, kp)
    for (i=1; i<=l; ++i)
        if (! table_arr_is_available(o, kp, i)) return i
}

# EndSection

function comp_table_paint( o, kp, x1, x2, y1, y2,       _opt, _slct_change, _body_change, _cur_col, _cur_row, _cur_col_true, _cur_row_true, _filter_enable ) {

    _search_change = change_is(o, kp, "table.search")
    _slct_change = change_is(o, kp, "table.filter")
    _body_change = change_is(o, kp, "table.body")

    _cur_col = comp_table_get_focused_col(o, kp)
    _cur_row = comp_table_get_focused_row(o, kp)
    _cur_col_true = comp_table_get_cur_col(o, kp)
    _cur_row_true = comp_table_get_cur_row(o, kp)

    opt_set( _opt, "multiple.enable", comp_table___multiple_mode(o, kp) )
    opt_set( _opt, "num.enable",      comp_table_display_column_num(o, kp) )
    opt_set( _opt, "filter.enable",   comp_table_ctrl_filter_sw_get(o, kp) )
    opt_set( _opt, "search.enable",   comp_table_ctrl_search_sw_get(o, kp) )

    if ( _slct_change ) {
        opt_set( _opt, "filter.text",     comp_table___slct_get(o, kp, _cur_col_true) )
        opt_set( _opt, "filter.width",    comp_table___slct_width(o, kp, _cur_col_true) )
        opt_set( _opt, "filter.cursor",   comp_table___slct_cursor_pos(o, kp, _cur_col_true) )
        opt_set( _opt, "filter.start",    comp_table___slct_start_pos(o, kp, _cur_col_true) )
    }

    if ( _search_change ) {
        opt_set( _opt, "search.text",     comp_table___search_get(o, kp) )
        opt_set( _opt, "search.width",    comp_table___search_width(o, kp) )
        opt_set( _opt, "search.cursor",   comp_table___search_cursor_pos(o, kp) )
        opt_set( _opt, "search.start",    comp_table___search_start_pos(o, kp) )
    }

    opt_set( _opt, "cur.col",       _cur_col )
    opt_set( _opt, "cur.row",       _cur_row )
    opt_set( _opt, "cur.col.true",  _cur_col_true )
    opt_set( _opt, "cur.row.true",  _cur_row_true )
    opt_set( _opt, "data.maxrow",   comp_table___slct_data_maxrow(o, kp) )

    _res = draw_table( o, kp, x1, x2, y1, y2, _opt )

    if ( _body_change ) {
        comp_table___pagesize_row( o, kp, opt_get( _opt, "pagesize.row" ))
        comp_table___pagesize_col( o, kp, opt_get( _opt, "pagesize.col" ))
        comp_table_unava(o, kp, opt_get( _opt, "unava.row" ))
    }

    return _res
}

function comp_table_change_set_all( o, kp  ) {
    return draw_table_change_set_all( o, kp )
}


function comp_table_inject_statusline_default( statuso, kp ){
    comp_statusline_data_put( statuso, kp, "←↓↑→/hjkl", "Move focus","Press keys to move focus"  )
    comp_statusline_data_put( statuso, kp, "n/p", "Next/Previous page", "Press 'n' to table next page, 'p' to table previous page" )
}

function comp_table___pagesize_row(o, kp, v){
    if (v == "")  return ctrl_page_pagesize_get(o, kp)
    else          ctrl_page_pagesize_set(o, kp, v)
}

function comp_table___pagesize_col(o, kp, v){
    if (v == "")  return ctrl_num_get_max(o, kp)
    else          ctrl_num_set_max(o, kp, v)
}
