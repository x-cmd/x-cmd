function comp_table_style_init(){
    TH_TABLE_SELECTED_COL           = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_SELECTED_COL" ]            : TH_THEME_COLOR
    TH_TABLE_SELECTED_ROW           = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_SELECTED_ROW" ]            : UI_TEXT_REV
    TH_TABLE_SELECTED_ROW_COL       = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_SELECTED_ROW_COL" ]        : TH_THEME_COLOR UI_TEXT_REV UI_TEXT_BOLD
    TH_TABLE_HEADER_ITEM_NORMAL     = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_HEADER_ITEM_NORMAL" ]      : UI_TEXT_UNDERLINE UI_TEXT_BOLD
    TH_TABLE_HEADER_ITEM_FOCUSED    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_HEADER_ITEM_FOCUSED" ]     : UI_TEXT_UNDERLINE UI_TEXT_BOLD  TH_THEME_COLOR
    TH_TABLE_NUM_NORMAL             = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_NUM_NORMAL" ]              : ""
    TH_TABLE_NUM_FOCUSED            = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_NUM_FOCUSED" ]             : ""
    TH_TABLE_NUM_PREFIX_SELECTED    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_NUM_PREFIX_SELECTED" ]     : TH_THEME_COLOR "> " UI_END
    TH_TABLE_NUM_PREFIX_UNSELECTED  = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_NUM_PREFIX_UNSELECTED" ]   : "  "
    TH_TABLE_NUM_PREFIX_WIDTH       = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_NUM_PREFIX_WIDTH" ]        : int(wcswidth_cache(str_remove_esc(TH_TABLE_NUM_PREFIX_UNSELECTED)))
    TH_TABLE_FOOTER                 = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_FOOTER" ]                  : TH_THEME_MINOR_COLOR
    TH_TABLE_BOX                    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_BOX" ]                     : TH_THEME_COLOR # UI_FG_DARKGRAY
    TH_TABLE_ICON                   = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_ICON" ]                    : "" # "✨" # "⚡"
    TH_TABLE_ICON_STYLE             = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_ICON_STYLE" ]              : TH_TABLE_HEADER_ITEM_FOCUSED
    TH_TABLE_CURRENT_INFO           = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_TABLE_CURRENT_INFO" ]            : "" # UI_FG_BLUE
    TH_TABLE_DATA_BLANK_PROMPT      = "Data loading ..."
}

function comp_table_init( o, kp ){
    comp_table_style_init()
    o[ kp, "TYPE" ] = "table"
    table_arr_init(o, kp)
    ctrl_page_init( o, kp, 1)
    ctrl_num_init( o, kp, 1)
    ctrl_sw_init( o, kp, false )
    comp_table_cell_highlight_set( o, kp, 1, 1, true )
    comp_table_row_highlight_set( o, kp, 1, true )
    comp_table_col_highlight_set( o, kp, 1, true )
    comp_textbox_init(o, kp SUBSEP "footer-textbox")
    comp_table_change_set_all( o, kp )
}
function comp_table_set_limit(o, kp, v) {
    if (v <= 1) return
    comp_table_multiple_sel(o, kp, true)
    o[ kp, "limit" ] = (v ~ "^[0-9]+$") ? v : "no-limit"
}
function comp_table_multiple_sel(o, kp, v){    ctrl_sw_init( o, kp SUBSEP "ismultiple", v);     }
function comp_table_multiple_sel_sw_get(o, kp){     return ctrl_sw_get(o, kp SUBSEP "ismultiple");    }
function comp_table_row_selected_sw_toggle(o, kp, r,        l){
    if (comp_table_row_is_sel(o, kp, r)) comp_table_sel_row_set(o, kp, r, false)
    else if ( ((l = o[ kp, "limit"]) == "no-limit") || l > comp_table_sel_len(o, kp))
        comp_table_sel_row_set(o, kp, r, true)
}
function comp_table_sel_row_set(o, kp, r, tf){
    o[ kp, "data-arr", "data", "ROW", r, "IS_SELECTED" ] = tf = (tf != "") ? tf : true
    if (tf == true) model_arr_add( o, kp SUBSEP "selected", r )
    else model_arr_rm( o, kp SUBSEP "selected", r )
}
function comp_table_sel_len(o, kp){
    return model_arr_data_len( o, kp SUBSEP "selected" )
}
function comp_table_row_is_sel(o, kp, r){
    return o[ kp, "data-arr", "data", "ROW", r, "IS_SELECTED" ]
}
function comp_table_selected_get(o, kp, i){
    return model_arr_data_get(o, kp SUBSEP "selected", i)
}


function comp_table_handle( o, kp, char_value, char_name, char_type,        r, c, _has_no_handle ) {

    if ( o[ kp, "TYPE" ] != "table" ) return false
    # slct: remap
    comp_table_cell_highlight_set( o, kp, r = comp_table_get_focused_row(o, kp), c = comp_table_get_focused_col(o, kp), false )
    comp_table_row_highlight_set( o, kp, r, false )
    comp_table_col_highlight_set( o, kp, c, false )

    if (ctrl_sw_get(o, kp) == true){
        if (char_name == U8WC_NAME_CARRIAGE_RETURN) ctrl_sw_toggle(o, kp)
        else if (comp_table_slct_set(o, kp, char_value, char_name, char_type)) ctrl_page_set( o, kp, 1)
        else _has_no_handle = true
    }
    else if (char_value == "n")             ctrl_page_next_page(o, kp)
    else if (char_value == "p")             ctrl_page_prev_page(o, kp)
    else if ((char_value == "k") || (char_name == U8WC_NAME_UP))    ctrl_page_rdec(o, kp)
    else if ((char_value == "j") || (char_name == U8WC_NAME_DOWN))  ctrl_page_rinc(o, kp)
    else if ((char_value == "h") || (char_name == U8WC_NAME_LEFT))  _has_no_handle = 1 - ctrl_table_dec(o, kp )
    else if ((char_value == "l") || (char_name == U8WC_NAME_RIGHT)) _has_no_handle = 1 - ctrl_table_inc(o, kp )
    else if (((char_value == " ") || (char_name == U8WC_NAME_HORIZONTAL_TAB)) && comp_table_multiple_sel_sw_get(o, kp)) {
        comp_table_row_selected_sw_toggle(o, kp, r)
        ctrl_page_rinc(o, kp)
    }
    else _has_no_handle = true

    if ( _has_no_handle != true ){
        change_set(o, kp, "table.head")
        change_set(o, kp, "table.body")
        change_set(o, kp, "table.foot")
    }

    comp_table_cell_highlight_set( o, kp, r = comp_table_get_focused_row(o, kp), c = comp_table_get_focused_col(o, kp), true )
    comp_table_row_highlight_set( o, kp, r, true )
    comp_table_col_highlight_set( o, kp, c, true )

    return ( _has_no_handle == true ) ? false : true

    # sort: remap
}

function ctrl_table_dec( o, kp ){
    if (ctrl_num_get( o, kp ) == ctrl_num_get_min(o, kp)) return false
    ctrl_num_dec(o, kp )
    return true
}

function ctrl_table_inc( o, kp ){
    if (ctrl_num_get( o, kp ) == ctrl_num_get_max(o, kp)) return false
    ctrl_num_inc(o, kp )
    return true
}

# Section: slct

function comp_table_slct_set(o, kp, char_value, char_name, char_type,       _kp){
    _kp = kp SUBSEP "slct" SUBSEP comp_table_get_cur_col(o, kp)
    if (comp_lineedit_handle(o, _kp, char_value, char_name, char_type)) {
        change_set( o, kp, "table.slct" )
        return true
    }
}

function comp_table_slct_get(o, kp, coli){
    return comp_lineedit_get(o, kp SUBSEP "slct" SUBSEP coli)
}

function comp_table_handle_slct_do( o, kp, rowi,         i, l, _slct){
    l = comp_table_model_maxcol(o, kp)
    for (i=1; i<=l; ++i) {
        _slct = comp_table_slct_get(o, kp, i)
        if (_slct == "") continue
        if (index(table_arr_get_data(o, kp, rowi, i), _slct)<=0) return false
    }
    return true
}

function comp_table_handle_slct( o, kp,             i, l, _viewl ){
    l = comp_table_model_maxrow(o, kp)
    model_arr_set_key_value(o, kp, "view-row" SUBSEP 1, 0)
    for (i=1; i<=l; ++i) {
        if (comp_table_handle_slct_do( o, kp, i ) == false) continue
        model_arr_set_key_value(o, kp, "view-row" SUBSEP (++_viewl), i)
    }

    model_arr_set_key_value( o, kp, "view-row" L, _viewl )
    ctrl_page_max_set( o, kp, _viewl )
}
# EndSection

# Section: sort: TODO by el

# EndSection

# Section: data

function comp_table_model_end( o, kp ){
    change_set( o, kp, "table.head" )
    change_set( o, kp, "table.body" )
    change_set( o, kp, "table.foot" )
    return comp_table_handle_slct( o, kp )
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
    # gsub("\n.*$", "", val)
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

# Section: table model request
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

function comp_table_model_fulldata_mode( o, kp ){
    return o[ kp, "fulldata_mode" ]
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
# EndSection

function comp_table_cell_highlight_set( o, kp, row, col, tf ){
    o[ kp, "data-arr", "data", row, col, "HIGHLIGHT" ] = (tf != "") ? tf : true
}

function comp_table_cell_is_highlight( o, kp, row, col ){
    return (o[ kp, "data-arr", "data", row, col, "HIGHLIGHT" ] == true) ? true : false
}

function comp_table_row_highlight_set( o, kp, row, tf ){
    o[ kp, "data-arr", "data", "ROW", row, "HIGHLIGHT" ] = (tf != "") ? tf : true
}

function comp_table_row_is_highlight( o, kp, row ){
    return (o[ kp, "data-arr", "data", "ROW", row, "HIGHLIGHT" ] == true) ? true : false
}

function comp_table_col_highlight_set( o, kp, col, tf ){
    o[ kp, "data-arr", "data", "COL", col, "HIGHLIGHT" ] = (tf != "") ? tf : true
}

function comp_table_col_is_highlight( o, kp, col ){
    return (o[ kp, "data-arr", "data", "COL", col, "HIGHLIGHT" ] == true) ? true : false
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

# Section: paint
function comp_table_change_set_all( o, kp ){
    change_set( o, kp, "table.box" )
    change_set( o, kp, "table.slct" )
    change_set( o, kp, "table.head" )
    change_set( o, kp, "table.body" )
    change_set( o, kp, "table.foot" )
}

function comp_table_paint( o, kp, x1, x2, y1, y2,        _comp_box, _comp_filter, _comp_header, _comp_boby, _comp_footer ){
    # if (comp_table_model_isfulldata( o, kp )) {
    #     # paint with selector/sort enabled
    # } else {
    #     # paint with selector/sort disabled
    # }
    _comp_box = comp_table_paint_box( o, kp, x1, x2, y1, y2, TH_TABLE_BOX )
    x1++; x2--; y1++; y2--
    x1++; x2--; y1++; y2--

    if ( ctrl_sw_get(o, kp )) {
        _comp_filter = comp_table_paint_filter( o, kp, x1, x1, y1, y2 )
        x1++
    }
    _comp_header = comp_table_paint_header( o, kp, x1, x1, y1, y2 )
    _comp_boby   = comp_table_paint_body( o, kp, x1+1, x2-2, y1, y2 )
    _comp_footer = comp_table_paint_footer( o, kp, x2+1, x2+1, y1, y2 )

    return _comp_box _comp_filter _comp_header _comp_boby _comp_footer
}

# Section: paint table body
function comp_table_paint_body( o, kp, x1, x2, y1, y2,      _next_line, row, _selected_w, _viewcoll, _unavailable_row, _start, _end, i, l, ri, j, w, c, _str, col, _num_w){
    if ( ! change_is(o, kp, "table.body") ) return
    change_unset(o, kp, "table.body")

    comp_table_set_unava( o, kp, "" )
    _next_line = "\r\n" painter_right( y1 )
    _unavailable_row = -1

    row = x2-x1+1
    col = y2-y1+1
    if (comp_table_multiple_sel_sw_get(o, kp)) _selected_w = TH_TABLE_NUM_PREFIX_WIDTH
    _num_w = length( l = model_arr_get(o, kp, "view-row" L) ) + 1 + _selected_w
    layout_avg_cal(o, kp, col = col-_num_w)
    ctrl_page_pagesize_set( o, kp, row )
    _viewcoll = layout_avg_get_len(o, kp)
    ctrl_num_set_max( o, kp, _viewcoll)

    _start = ctrl_page_begin(o, kp)
    _end = ctrl_page_end(o, kp)
    for (i=_start; i<=_end; ++i) {
        if (i > l) {    _str = _str space_rep(col) _next_line;  continue;   }

        _str = _str comp_table_paint_num( o, kp, i, _num_w )
        ri = model_arr_get(o, kp, "view-row" SUBSEP i)
        if (! table_arr_is_available(o, kp, ri)) {
            if (_unavailable_row == -1) _unavailable_row = ri
            _str = _str comp_table_paint_null_data( o, kp, ri, col )
        } else {
            c = _num_w
            for (j=1; j<=_viewcoll; ++j) {
                w = layout_avg_get_size(o, kp, j)
                _str = _str "\r" painter_right( y1+c ) comp_table_paint_cell(o, kp, i, j, w)
                c += w
            }
        }
        _str = _str _next_line
    }
    if ( _str == "" ) _str = comp_table_paint_null_data( o, kp, 0, col )
    # request data
    if ( _unavailable_row != -1 ) comp_table_set_unava( o, kp, _unavailable_row )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

function comp_table_paint_cell( o, kp, i, j, w,             ri, ci, v, l, _v_1 ){
    ri = model_arr_get(o, kp, "view-row" SUBSEP i)
    ci = layout_avg_get_item(o, kp, j)
    v  =  table_arr_get_data(o, kp, ri, ci)
    gsub("\n.*$", "", v)
    w --

    _v_1 = wcstruncate_cache( v, w )
    if (_v_1 == v)  v = v space_rep(w - wcswidth_cache( v )) " "
    else            v = wcstruncate_cache( _v_1, w-2 ) "…  "

    if ( comp_table_cell_is_highlight(o, kp, i, j) )  v = th( TH_TABLE_SELECTED_ROW_COL, v )
    else if ( comp_table_row_is_highlight(o, kp, i) ) v = th( TH_TABLE_SELECTED_ROW, v )
    else if ( comp_table_col_is_highlight(o, kp, j) ) v = th( TH_TABLE_SELECTED_COL, v )
    return v
}

function comp_table_paint_num( o, kp, i, w,         v, _prefix ){
    v = space_restrict_or_pad(i, w)
    if (comp_table_multiple_sel_sw_get(o, kp)) {
        if (comp_table_row_is_sel( o, kp, i ) ) _prefix = TH_TABLE_NUM_PREFIX_SELECTED
        else _prefix = TH_TABLE_NUM_PREFIX_UNSELECTED
    }
    if (i == comp_table_get_cur_row( o, kp ) ) return _prefix th( TH_TABLE_NUM_FOCUSED, v )
    return _prefix th( TH_TABLE_NUM_NORMAL, v )
}

function comp_table_paint_null_data( o, kp, i, w,        v){
    v = TH_TABLE_DATA_BLANK_PROMPT
    v = wcstruncate_cache( v, w )
    v = space_restrict_or_pad(v, w)
    if ( i == comp_table_get_focused_row(o, kp) ) v = UI_TEXT_REV v
    return th( UI_TEXT_DIM, v )
}
# EndSection

function comp_table_paint_box( o, kp, x1, x2, y1, y2, color,       s ){
    if ( ! change_is(o, kp, "table.box") ) return
    change_unset(o, kp, "table.box")
    s = painter_box_arc( x1, x2, y1, y2, color ); x2-=2
    s = s painter_hline_ends( x2, y1, y2, color  )
    return s
}

function comp_table_paint_header(o, kp, x1, x2, y1, y2,                space_w, _selected_w, s, l, i, w, v, icon_w, c ){
    if ( ! change_is(o, kp, "table.head") ) return
    change_unset(o, kp, "table.head")
    if (comp_table_multiple_sel_sw_get(o, kp)) _selected_w = TH_TABLE_NUM_PREFIX_WIDTH
    c = space_w = length( model_arr_get(o, kp, "view-row" L) ) + 1 + _selected_w
    layout_avg_cal(o, kp, y2-y1+1-space_w)
    l = layout_avg_get_len(o, kp)

    s = TH_TABLE_HEADER_ITEM_NORMAL space_rep(space_w)
    for (i=1; i<=l; ++i){
        w = layout_avg_get_size(o, kp, i)
        v = comp_table_get_head_title(o, kp, layout_avg_get_item(o, kp, i))
        gsub("\n.*$", "", v)
        if ( i != comp_table_get_focused_col(o, kp) ) v = th( TH_TABLE_HEADER_ITEM_NORMAL, space_restrict_or_pad_utf8(v, w) )
        else {
            icon_w = wcswidth_cache(TH_TABLE_ICON)
            v = wcstruncate_cache(v, w - icon_w)
            v = th( TH_TABLE_HEADER_ITEM_FOCUSED, v ) th( TH_TABLE_ICON_STYLE, TH_TABLE_ICON ) th( TH_TABLE_HEADER_ITEM_FOCUSED, space_rep( w-wcswidth_cache(v)-icon_w ) )
        }
        s = s "\r" painter_right( y1+c ) v
        c += w
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) s
}

function comp_table_paint_filter(o, kp, x1, x2, y1, y2,         ci, v, _keypath){
    if ( ! change_is(o, kp, "table.slct") ) return
    change_unset(o, kp, "table.slct")
    ci = layout_avg_get_item(o, kp, comp_table_get_focused_col(o, kp))
    v = comp_table_slct_get(o, kp, ci)
    _keypath = kp SUBSEP "slct" SUBSEP ci
    comp_lineedit_change_set( o, _keypath )
    if (v == "") v = th( UI_TEXT_DIM, comp_table_get_head_title(o, kp, ci) )
    else         v = comp_lineedit_paint_with_cursor(o, _keypath, x1, y1+8, y2)
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) "FILTER: " v
}

function comp_table_paint_footer(o, kp, x1, x2, y1, y2,        i, j, v){
    if ( ! change_is(o, kp, "table.foot") ) return
    change_unset(o, kp, "table.foot")
    i = comp_table_get_cur_row(o, kp)
    j = comp_table_get_cur_col(o, kp)
    v = th(TH_TABLE_FOOTER, "SELECT: ") table_arr_get_data(o, kp, i, j)
    comp_textbox_put(o, kp SUBSEP "footer-textbox", v)
    return comp_textbox_paint(o, kp SUBSEP "footer-textbox", x1, x2, y1, y2)
}

# EndSection

function comp_table_inject_statusline_default( statuso, kp ){
    comp_statusline_data_put( statuso, kp, "←↓↑→/hjkl", "Move focus","Press keys to move focus"  )
    comp_statusline_data_put( statuso, kp, "n/p", "Next/Previous page", "Press 'n' to table next page, 'p' to table previous page" )
}
