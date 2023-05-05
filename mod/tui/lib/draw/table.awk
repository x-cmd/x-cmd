function draw_table_style_init(){
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

function draw_table( o, kp, x1, x2, y1, y2, opt, \
    _draw_box, _draw_filter, _draw_header, _draw_boby, _draw_footer ){

    _draw_box = draw_table___on_box(            o, kp, x1,      x2,     y1, y2, TH_TABLE_BOX )
    x1++; x2--; y1++; y2--
    x1++; x2--; y1++; y2--

    if ( opt_getor( opt, "filter.enable", false ) ) {
        _draw_filter = draw_table___on_filter(  o, kp, x1,      x1,     y1, y2, opt )
        x1++
    }
    _draw_header = draw_table___on_header(      o, kp, x1,      x1,     y1, y2, opt )
    _draw_boby   = draw_table___on_body(        o, kp, x1+1,    x2-2,   y1, y2, opt )
    _draw_footer = draw_table___on_footer(      o, kp, x2+1,    x2+1,   y1, y2, opt )

    return _draw_box _draw_filter _draw_header _draw_boby _draw_footer
}

# Section: paint table body
function draw_table___on_body( o, kp, x1, x2, y1, y2, opt,      _next_line, row, _selected_w, _viewcoll, _unavailable_row, _start, _end, i, l, ri, j, w, c, _str, col, _num_w){
    if ( ! change_is(o, kp, "table.body") ) return
    change_unset(o, kp, "table.body")

    _next_line = "\r\n" painter_right( y1 )
    _unavailable_row = -1

    row = x2-x1+1
    col = y2-y1+1
    if (opt_getor( opt, "multiple.enable", false )) _selected_w = TH_TABLE_NUM_PREFIX_WIDTH
    _num_w = length( l = opt_get( opt, "data.maxrow" ) ) + 1 + _selected_w
    layout_avg_cal(o, kp, col = col-_num_w)
    _viewcoll = layout_avg_get_len(o, kp)

    opt_set( opt, "pagesize.row", row )
    opt_set( opt, "pagesize.col", _viewcoll )

    _start = draw_unit_page_begin( opt_get( opt, "cur.row" ), row )
    _end   = draw_unit_page_end( opt_get( opt, "cur.row" ), row, l )
    for (i=_start; i<=_end; ++i) {
        if (i > l) {    _str = _str space_rep(col) _next_line;  continue;   }

        ri = model_arr_get(o, kp, "view-row" SUBSEP i)
        _str = _str draw_table___on_num( o, kp, i, _num_w, opt )
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
    opt_set( opt, "unava.row", _unavailable_row )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

function draw_table___on_cell( o, kp, i, j, w,             ri, ci, v, l, _v_1 ){
    ri = model_arr_get(o, kp, "view-row" SUBSEP i)
    ci = layout_avg_get_item(o, kp, j)
    v  = table_arr_get_data(o, kp, ri, ci)
    gsub("\n.*$", "", v)
    w --

    _v_1 = wcstruncate_cache( v, w )
    if (_v_1 == v)  v = v space_rep(w - wcswidth_cache( v )) " "
    else            v = wcstruncate_cache( _v_1, w-2 ) "…  "

    if ( draw_table_cell_highlight(o, kp, i, j) )  v = th( TH_TABLE_SELECTED_ROW_COL, v )
    else if ( draw_table_row_highlight(o, kp, i) ) v = th( TH_TABLE_SELECTED_ROW, v )
    else if ( draw_table_col_highlight(o, kp, j) ) v = th( TH_TABLE_SELECTED_COL, v )
    return v
}

function draw_table___on_num( o, kp, i, w, opt,        v, _prefix ){
    v = space_restrict_or_pad(i, w)
    if (opt_getor( opt, "multiple.enable", false )) {
        if (draw_table_row_selected( o, kp, model_arr_get(o, kp, "view-row" SUBSEP i) ) ) _prefix = TH_TABLE_NUM_PREFIX_SELECTED
        else _prefix = TH_TABLE_NUM_PREFIX_UNSELECTED
    }
    if (i == opt_get( opt, "cur.row.true" ) ) return _prefix th( TH_TABLE_NUM_FOCUSED, v )
    return _prefix th( TH_TABLE_NUM_NORMAL, v )
}

function draw_table___on_null_data( o, kp, i, w,        v){
    v = TH_TABLE_DATA_BLANK_PROMPT
    v = wcstruncate_cache( v, w )
    v = space_restrict_or_pad(v, w)
    if ( i == opt_get( opt, "cur.col" )  ) v = UI_TEXT_REV v
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

function draw_table___on_header(o, kp, x1, x2, y1, y2, opt,               space_w, _selected_w, s, l, i, w, v, icon_w, c ){
    if ( ! change_is(o, kp, "table.head") ) return
    change_unset(o, kp, "table.head")
    if (opt_getor( opt, "multiple.enable", false )) _selected_w = TH_TABLE_NUM_PREFIX_WIDTH
    c = space_w = length( opt_get( opt, "data.maxrow" ) ) + 1 + _selected_w
    layout_avg_cal(o, kp, y2-y1+1-space_w)
    l = layout_avg_get_len(o, kp)

    s = TH_TABLE_HEADER_ITEM_NORMAL space_rep(space_w)
    for (i=1; i<=l; ++i){
        w = layout_avg_get_size(o, kp, i)
        v = table_arr_head_get(o, kp, layout_avg_get_item(o, kp, i))
        gsub("\n.*$", "", v)
        if ( i != opt_get( opt, "cur.col" ) ) v = th( TH_TABLE_HEADER_ITEM_NORMAL, space_restrict_or_pad_utf8(v, w) )
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

function draw_table___on_filter(o, kp, x1, x2, y1, y2, opt,         ci, v, _keypath, _opt){
    if ( ! change_is(o, kp, "table.slct") ) return
    change_unset(o, kp, "table.slct")
    ci = opt_get( opt, "cur.col.true" )
    v = opt_get( opt, "filter.text" )
    _keypath = kp SUBSEP "slct" SUBSEP ci
    if (v == "") v = th( UI_TEXT_DIM, table_arr_head_get(o, kp, ci) )
    else {
        opt_set( _opt, "line.text",     v )
        opt_set( _opt, "line.width",    opt_get( opt, "filter.width" ) )
        opt_set( _opt, "cursor.pos",    opt_get( opt, "filter.cursor" ) )
        opt_set( _opt, "start.pos",     opt_get( opt, "filter.start" ) )
        v = draw_lineedit_paint(o, _keypath, x1, x1, y1+8, y2, _opt)
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) "FILTER: " v
}

function draw_table___on_footer(o, kp, x1, x2, y1, y2, opt,        i, j, v){
    if ( ! change_is(o, kp, "table.foot") ) return
    change_unset(o, kp, "table.foot")
    i = opt_get( opt, "cur.row.true" )
    j = opt_get( opt, "cur.col.true" )
    v = th(TH_TABLE_FOOTER, "SELECT: ") table_arr_get_data(o, kp, i, j)
    draw_textbox_data_init( o, kp SUBSEP "footer-textbox", v)
    return draw_textbox_paint( o, kp SUBSEP "footer-textbox", x1, x2, y1, y2 )
}

# Section: draw model
function draw_table_cell_highlight( o, kp, row, col, tf ){
    if ( tf == "" )     return (o[ kp, "draw", "hl-cell", row, col ] == true)
    else                o[ kp, "draw", "hl-cell", row, col ] = tf
}

function draw_table_row_highlight( o, kp, row, tf ){
    if ( tf == "" )     return (o[ kp, "draw", "hl-row", row ] == true)
    else                o[ kp, "draw", "hl-row", row ] = tf
}

function draw_table_col_highlight( o, kp, col, tf ){
    if ( tf == "" )     return (o[ kp, "draw", "hl-col", col ] == true)
    else                o[ kp, "draw", "hl-col", col ] = tf
}

function draw_table_row_selected(o, kp, r, tf,          n){
    if ( tf == "" )     return o[ kp, "draw", "sel-row", r ]

    o[ kp, "draw", "sel-row", r ] = tf
    n = o[ kp, "draw", "sel-count" ]
    if (tf == true) o[ kp, "draw", "sel-count" ] = n+1
    else o[ kp, "draw", "sel-count" ] = (n<=0) ? 0 : n-1
}

function draw_table_row_selected_limit( o, kp, v ){
    if ( v == "" )  return o[ kp, "draw", "limit" ]
    else            o[ kp, "draw", "limit"] = v
}

function draw_table_row_selected_count(o, kp){
    return o[ kp, "draw", "sel-count" ]
}

function draw_table_row_selected_sw_toggle(o, kp, r,        l){
    if (draw_table_row_selected(o, kp, r) == true) draw_table_row_selected(o, kp, r, false)
    else if ( ((l = draw_table_row_selected_limit(o, kp)) == "no-limit") || l > draw_table_row_selected_count(o, kp))
        draw_table_row_selected(o, kp, r, true)
}

# EndSection
