
function comp_table_init( o, kp ){
    comp_table___style_init()
    o[ kp, "TYPE" ] = "table"
    table_arr_init(o, kp)
    ctrl_page_init( o, kp, 1)
    ctrl_num_init( o, kp, 1)
    ctrl_sw_init( o, kp, false )


    draw_table_cell_highlight_set( o, kp, 1, 1, true )
    draw_table_row_highlight_set( o, kp, 1, true )
    draw_table_col_highlight_set( o, kp, 1, true )

    comp_textbox_init(o, kp SUBSEP "footer-textbox")
    draw_table_init( o, kp )
}

# Section: ctrl handle
function comp_table_set_limit(o, kp, v) {
    if (v <= 1) return
    comp_table___multiple_sel_sw_set(o, kp, true)
    o[ kp, "limit" ] = (v ~ "^[0-9]+$") ? v : "no-limit"
}

function comp_table_handle( o, kp, char_value, char_name, char_type,        r, c, _has_no_handle ) {

    if ( o[ kp, "TYPE" ] != "table" ) return false
    # slct: remap
    draw_table_cell_highlight_set( o, kp, r = comp_table_get_focused_row(o, kp), c = comp_table_get_focused_col(o, kp), false )
    draw_table_row_highlight_set( o, kp, r, false )
    draw_table_col_highlight_set( o, kp, c, false )

    if (ctrl_sw_get(o, kp) == true){
        if (char_name == U8WC_NAME_CARRIAGE_RETURN) ctrl_sw_toggle(o, kp)
        else if (comp_table___slct_set(o, kp, char_value, char_name, char_type)) ctrl_page_set( o, kp, 1)
        else _has_no_handle = true
    }
    else if (char_value == "n")             ctrl_page_next_page(o, kp)
    else if (char_value == "p")             ctrl_page_prev_page(o, kp)
    else if ((char_value == "k") || (char_name == U8WC_NAME_UP))    ctrl_page_rdec(o, kp)
    else if ((char_value == "j") || (char_name == U8WC_NAME_DOWN))  ctrl_page_rinc(o, kp)
    else if ((char_value == "h") || (char_name == U8WC_NAME_LEFT))  _has_no_handle = 1 - ctrl_table___dec(o, kp )
    else if ((char_value == "l") || (char_name == U8WC_NAME_RIGHT)) _has_no_handle = 1 - ctrl_table___inc(o, kp )
    else if (((char_value == " ") || (char_name == U8WC_NAME_HORIZONTAL_TAB)) && comp_table___multiple_sel_sw_get(o, kp)) {
        comp_table___row_selected_sw_toggle(o, kp, r)
        ctrl_page_rinc(o, kp)
    }
    else _has_no_handle = true

    if ( _has_no_handle != true ){
        change_set(o, kp, "table.head")
        change_set(o, kp, "table.body")
        change_set(o, kp, "table.foot")
    }

    draw_table_cell_highlight_set( o, kp, r = comp_table_get_focused_row(o, kp), c = comp_table_get_focused_col(o, kp), true )
    draw_table_row_highlight_set( o, kp, r, true )
    draw_table_col_highlight_set( o, kp, c, true )

    return ( _has_no_handle == true ) ? false : true

    # sort: remap
}

function ctrl_table___dec( o, kp ){
    if (ctrl_num_get( o, kp ) == ctrl_num_get_min(o, kp)) return false
    ctrl_num_dec(o, kp )
    return true
}

function ctrl_table___inc( o, kp ){
    if (ctrl_num_get( o, kp ) == ctrl_num_get_max(o, kp)) return false
    ctrl_num_inc(o, kp )
    return true
}

function comp_table___multiple_sel_sw_set(o, kp, v){
    draw_table_multiple_sel_sw_set(o, kp, v)
}

function comp_table___multiple_sel_sw_get(o, kp){
    return draw_table_multiple_sel_sw_get(o, kp)
}

function comp_table___row_selected_sw_toggle(o, kp, r){
    draw_table_row_selected_sw_toggle(o, kp, r)
}

# EndSection

# Section: slct
function comp_table___slct_set(o, kp, char_value, char_name, char_type,       _kp){
    _kp = kp SUBSEP "slct" SUBSEP comp_table_get_cur_col(o, kp)
    if (comp_lineedit_handle(o, _kp, char_value, char_name, char_type)) {
        change_set( o, kp, "table.slct" )
        return true
    }
}

function comp_table___slct_get(o, kp, coli){
    return comp_lineedit_get(o, kp SUBSEP "slct" SUBSEP coli)
}

function comp_table___handle_slct_do( o, kp, rowi,         i, l, _slct){
    l = comp_table_model_maxcol(o, kp)
    for (i=1; i<=l; ++i) {
        _slct = comp_table___slct_get(o, kp, i)
        if (_slct == "") continue
        if (index(table_arr_get_data(o, kp, rowi, i), _slct)<=0) return false
    }
    return true
}

function comp_table___handle_slct( o, kp,             i, l, _viewl ){
    l = comp_table_model_maxrow(o, kp)
    model_arr_set_key_value(o, kp, "view-row" SUBSEP 1, 0)
    for (i=1; i<=l; ++i) {
        if (comp_table___handle_slct_do( o, kp, i ) == false) continue
        model_arr_set_key_value(o, kp, "view-row" SUBSEP (++_viewl), i)
    }

    model_arr_set_key_value( o, kp, "view-row" L, _viewl )
    ctrl_page_max_set( o, kp, _viewl )
}
## Section: sort: TODO by el
## EndSection
# EndSection

# Section: table model data
function comp_table_model_end( o, kp ){
    change_set( o, kp, "table.head" )
    change_set( o, kp, "table.body" )
    change_set( o, kp, "table.foot" )
    return comp_table___handle_slct( o, kp )
}

function comp_table_model_set( o, kp, arr,      _start, _end, i, l, j ){
    l = int(arr[ "col" ])
    _start = int(arr[ "start" ])
    _end = int(arr[ "end" ])
    for (i=_start; i<=_end; ++i)
        for (j=1; j<=l; ++j)
            table_arr_add(o, kp, i, j, arr[i, j])

    if ( _end > comp_table_model_maxrow(o, kp)) comp_table_model_maxrow_set(o, kp, _end)
}

function comp_table_model_set_cell(o, kp, i, j, val){
    table_arr_add(o, kp, i, j, val)
    if (i > comp_table_model_maxrow(o, kp)) comp_table_model_maxrow_set(o, kp, i)
}

function comp_table_model_maxrow_set( o, kp, row ){
    model_arr_set_key_value(o, kp, "max-row", row)
}

function comp_table_model_maxrow(o, kp){
    return model_arr_get(o, kp, "max-row")
}

function comp_table_model_maxcol(o, kp){
    return model_arr_get(o, kp, "max-col")
}

function comp_table_head_add(o, kp, title,          l){
    change_set(o, kp, "table.head")
    kp = kp SUBSEP "data-arr"
    o[ kp, "max-col" ] = l = o[  kp, "max-col" ] + 1
    o[ kp, "head", l, "title" ] = title
    return l
}

function comp_table_layout_avg_ele_add(o, kp, colid, min, max){
    comp_lineedit_init(o, kp SUBSEP "slct" SUBSEP colid, "", max)
    return layout_avg_ele_add( o, kp, colid, min, max )
}

function comp_table_get_head_title(o, kp, i){
    return o[ kp, "data-arr", "head", i, "title" ]
}

# table model request
BEGIN{
    FULLDATA_MODE_FALSE = 0
    FULLDATA_MODE_ONTHEWAY = 1
    FULLDATA_MODE_TRUE = 2
    o[ kp, "fulldata_mode" ] = FULLDATA_MODE_FALSE
}

function comp_table_model_fulldata_mode_set( o, kp, mode ){
    o[ kp, "fulldata_mode" ] = mode
}

function comp_table_model_fulldata_mode_get( o, kp ){
    return o[ kp, "fulldata_mode" ]
}

function comp_table_model_fulldata_mode_is_ontheway( o, kp ){
    return (o[ kp, "fulldata_mode" ] == FULLDATA_MODE_ONTHEWAY)
}

function comp_table_model_isfulldata( o, kp ){
    return comp_table_model_maxrow(o, kp) == table_arr_available_row(o, kp)
}

function comp_table_set_unava(o, kp, row){
    o[ kp, "unava-row" ] = row
}
function comp_table_get_unava(o, kp){
    return o[ kp, "unava-row" ]
}
function comp_table_get_the_first_unava(o, kp,          i, l){
    l = comp_table_model_maxrow(o, kp)
    for (i=1; i<=l; ++i)
        if (! table_arr_is_available(o, kp, i)) return i
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

function comp_table_get_cur_line(o, kp, has_color,     _line, _color_end, _color, l, i, ri){
    l = comp_table_model_maxcol(o, kp)
    ri = comp_table_get_cur_row(o, kp)
    if (has_color) { _color = TH_TABLE_CURRENT_INFO; _color_end = UI_END; }
    _line = _color comp_table_get_head_title(o, kp, 1) ": " _color_end table_arr_get_data(o, kp, ri, 1)
    for (i=2; i<=l; ++i) _line = _line "\n" _color comp_table_get_head_title(o, kp, i) ": " _color_end table_arr_get_data(o, kp, ri, i)
    return _line
}
# EndSection

function comp_table_paint( o, kp, x1, x2, y1, y2 ) {
    return draw_table( o, kp, x1, x2, y1, y2 )
}

function comp_table_change_set_all( o, kp  ) {
    return draw_table_change_set_all( o, kp )
}


function comp_table_inject_statusline_default( statuso, kp ){
    comp_statusline_data_put( statuso, kp, "←↓↑→/hjkl", "Move focus","Press keys to move focus"  )
    comp_statusline_data_put( statuso, kp, "n/p", "Next/Previous page", "Press 'n' to table next page, 'p' to table previous page" )
}
