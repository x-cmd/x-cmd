function comp_table___style_init(){
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

function draw_table_init( o, kp ){
    draw_table_change_set_all( o, kp )
}

function draw_table_change_set_all( o, kp ){
    change_set( o, kp, "table.box" )
    change_set( o, kp, "table.slct" )
    change_set( o, kp, "table.head" )
    change_set( o, kp, "table.body" )
    change_set( o, kp, "table.foot" )
}

function draw_table( o, kp, x1, x2, y1, y2,        _comp_box, _comp_filter, _comp_header, _comp_boby, _comp_footer ){
    # if (comp_table_model_isfulldata( o, kp )) {
    #     # paint with selector/sort enabled
    # } else {
    #     # paint with selector/sort disabled
    # }
    _comp_box = draw_table___on_box( o, kp, x1, x2, y1, y2, TH_TABLE_BOX )
    x1++; x2--; y1++; y2--
    x1++; x2--; y1++; y2--

    if ( ctrl_sw_get(o, kp )) {
        _comp_filter = draw_table___on_filter( o, kp, x1, x1, y1, y2 )
        x1++
    }
    _comp_header = draw_table___on_header( o, kp, x1, x1, y1, y2 )
    _comp_boby   = draw_table___on_body( o, kp, x1+1, x2-2, y1, y2 )
    _comp_footer = draw_table___on_footer( o, kp, x2+1, x2+1, y1, y2 )

    return _comp_box _comp_filter _comp_header _comp_boby _comp_footer
}

# Section: paint table body
function draw_table___on_body( o, kp, x1, x2, y1, y2,      _next_line, row, _selected_w, _viewcoll, _unavailable_row, _start, _end, i, l, ri, j, w, c, _str, col, _num_w){
    if ( ! change_is(o, kp, "table.body") ) return
    change_unset(o, kp, "table.body")

    comp_table_set_unava( o, kp, "" )
    _next_line = "\r\n" painter_right( y1 )
    _unavailable_row = -1

    row = x2-x1+1
    col = y2-y1+1
    if (draw_table_multiple_sel_sw_get(o, kp)) _selected_w = TH_TABLE_NUM_PREFIX_WIDTH
    _num_w = length( l = model_arr_get(o, kp, "view-row" L) ) + 1 + _selected_w
    layout_avg_cal(o, kp, col = col-_num_w)
    ctrl_page_pagesize_set( o, kp, row )
    _viewcoll = layout_avg_get_len(o, kp)
    ctrl_num_set_max( o, kp, _viewcoll)

    _start = ctrl_page_begin(o, kp)
    _end = ctrl_page_end(o, kp)
    for (i=_start; i<=_end; ++i) {
        if (i > l) {    _str = _str space_rep(col) _next_line;  continue;   }

        _str = _str draw_table___on_num( o, kp, i, _num_w )
        ri = model_arr_get(o, kp, "view-row" SUBSEP i)
        if (! table_arr_is_available(o, kp, ri)) {
            if (_unavailable_row == -1) _unavailable_row = ri
            _str = _str draw_table___on_null_data( o, kp, ri, col )
        } else {
            c = _num_w
            for (j=1; j<=_viewcoll; ++j) {
                w = layout_avg_get_size(o, kp, j)
                _str = _str "\r" painter_right( y1+c ) draw_table___on_cell(o, kp, i, j, w)
                c += w
            }
        }
        _str = _str _next_line
    }
    if ( _str == "" ) _str = draw_table___on_null_data( o, kp, 0, col )
    # request data
    if ( _unavailable_row != -1 ) comp_table_set_unava( o, kp, _unavailable_row )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

function draw_table___on_cell( o, kp, i, j, w,             ri, ci, v, l, _v_1 ){
    ri = model_arr_get(o, kp, "view-row" SUBSEP i)
    ci = layout_avg_get_item(o, kp, j)
    v  =  table_arr_get_data(o, kp, ri, ci)
    gsub("\n.*$", "", v)
    w --

    _v_1 = wcstruncate_cache( v, w )
    if (_v_1 == v)  v = v space_rep(w - wcswidth_cache( v )) " "
    else            v = wcstruncate_cache( _v_1, w-2 ) "…  "

    if ( draw_table_cell_is_highlight(o, kp, i, j) )  v = th( TH_TABLE_SELECTED_ROW_COL, v )
    else if ( draw_table_row_is_highlight(o, kp, i) ) v = th( TH_TABLE_SELECTED_ROW, v )
    else if ( draw_table_col_is_highlight(o, kp, j) ) v = th( TH_TABLE_SELECTED_COL, v )
    return v
}

function draw_table___on_num( o, kp, i, w,         v, _prefix ){
    v = space_restrict_or_pad(i, w)
    if (draw_table_multiple_sel_sw_get(o, kp)) {
        if (draw_table_row_is_sel( o, kp, i ) ) _prefix = TH_TABLE_NUM_PREFIX_SELECTED
        else _prefix = TH_TABLE_NUM_PREFIX_UNSELECTED
    }
    if (i == comp_table_get_cur_row( o, kp ) ) return _prefix th( TH_TABLE_NUM_FOCUSED, v )
    return _prefix th( TH_TABLE_NUM_NORMAL, v )
}

function draw_table___on_null_data( o, kp, i, w,        v){
    v = TH_TABLE_DATA_BLANK_PROMPT
    v = wcstruncate_cache( v, w )
    v = space_restrict_or_pad(v, w)
    if ( i == comp_table_get_focused_row(o, kp) ) v = UI_TEXT_REV v
    return th( UI_TEXT_DIM, v )
}
# EndSection

function draw_table___on_box( o, kp, x1, x2, y1, y2, color,       s ){
    if ( ! change_is(o, kp, "table.box") ) return
    change_unset(o, kp, "table.box")
    s = painter_box_arc( x1, x2, y1, y2, color ); x2-=2
    s = s painter_hline_ends( x2, y1, y2, color  )
    return s
}

function draw_table___on_header(o, kp, x1, x2, y1, y2,                space_w, _selected_w, s, l, i, w, v, icon_w, c ){
    if ( ! change_is(o, kp, "table.head") ) return
    change_unset(o, kp, "table.head")
    if (draw_table_multiple_sel_sw_get(o, kp)) _selected_w = TH_TABLE_NUM_PREFIX_WIDTH
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

function draw_table___on_filter(o, kp, x1, x2, y1, y2,         ci, v, _keypath){
    if ( ! change_is(o, kp, "table.slct") ) return
    change_unset(o, kp, "table.slct")
    ci = layout_avg_get_item(o, kp, comp_table_get_focused_col(o, kp))
    v = comp_table___slct_get(o, kp, ci)
    _keypath = kp SUBSEP "slct" SUBSEP ci
    comp_lineedit_change_set( o, _keypath )
    if (v == "") v = th( UI_TEXT_DIM, comp_table_get_head_title(o, kp, ci) )
    else         v = comp_lineedit_paint(o, _keypath, x1, x1, y1+8, y2)
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) "FILTER: " v
}

function draw_table___on_footer(o, kp, x1, x2, y1, y2,        i, j, v){
    if ( ! change_is(o, kp, "table.foot") ) return
    change_unset(o, kp, "table.foot")
    i = comp_table_get_cur_row(o, kp)
    j = comp_table_get_cur_col(o, kp)
    v = th(TH_TABLE_FOOTER, "SELECT: ") table_arr_get_data(o, kp, i, j)
    comp_textbox_put(o, kp SUBSEP "footer-textbox", v)
    return comp_textbox_paint(o, kp SUBSEP "footer-textbox", x1, x2, y1, y2)
}

# Section: draw model

function draw_table_cell_highlight_set( o, kp, row, col, tf ){
    # o[ kp, "data-arr", "data", row, col, "HIGHLIGHT" ] = (tf != "") ? tf : true
    o[ kp, "draw", "hl-cell", row, col ] = (tf != "") ? tf : true
}

function draw_table_cell_is_highlight( o, kp, row, col ){
    # return (o[ kp, "data-arr", "data", row, col, "HIGHLIGHT" ] == true) ? true : false
    return (o[ kp, "draw", "hl-cell", row, col ] == true) ? true : false
}

function draw_table_row_highlight_set( o, kp, row, tf ){
    # o[ kp, "data-arr", "data", "ROW", row, "HIGHLIGHT" ] = (tf != "") ? tf : true
    o[ kp, "draw", "hl-row", row ] = (tf != "") ? tf : true
}

function draw_table_row_is_highlight( o, kp, row ){
    # return (o[ kp, "data-arr", "data", "ROW", row, "HIGHLIGHT" ] == true) ? true : false
    return (o[ kp, "draw", "hl-row", row ] == true) ? true : false
}

function draw_table_col_highlight_set( o, kp, col, tf ){
    # o[ kp, "data-arr", "data", "COL", col, "HIGHLIGHT" ] = (tf != "") ? tf : true
    o[ kp, "draw", "hl-col", col ] = (tf != "") ? tf : true
}

function draw_table_col_is_highlight( o, kp, col ){
    # return (o[ kp, "data-arr", "data", "COL", col, "HIGHLIGHT" ] == true) ? true : false
    return (o[ kp, "draw", "hl-col", col ] == true) ? true : false
}

function draw_table_multiple_sel_sw_set(o, kp, v){
    ctrl_sw_init( o, kp SUBSEP "ismultiple", v)
}

function draw_table_multiple_sel_sw_get(o, kp){
    return ctrl_sw_get(o, kp SUBSEP "ismultiple")
}

function draw_table_row_selected_sw_toggle(o, kp, r,        l){
    if (draw_table_row_is_sel(o, kp, r)) draw_table_sel_row_set(o, kp, r, false)
    else if ( ((l = o[ kp, "limit"]) == "no-limit") || l > draw_table_sel_len(o, kp))
        draw_table_sel_row_set(o, kp, r, true)
}
function draw_table_sel_row_set(o, kp, r, tf){
    # o[ kp, "data-arr", "data", "ROW", r, "IS_SELECTED" ] = tf = (tf != "") ? tf : true
    o[ kp, "draw", "sel-row", r ] = tf = (tf != "") ? tf : true
    if (tf == true) model_arr_add( o, kp SUBSEP "selected", r )
    else model_arr_rm( o, kp SUBSEP "selected", r )
}
function draw_table_sel_len(o, kp){
    return model_arr_data_len( o, kp SUBSEP "selected" )
}
function draw_table_row_is_sel(o, kp, r){
    return o[ kp, "draw", "sel-row", r ]
}
function draw_table_selected_get(o, kp, i){
    return model_arr_data_get(o, kp SUBSEP "selected", i)
}
# EndSection
