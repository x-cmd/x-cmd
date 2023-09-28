function draw_gsel_style_init(){
    TH_GSEL_TITLE           =   UI_TEXT_DIM
    TH_GSEL_ITEM_FOCUSED    =   UI_TEXT_REV TH_THEME_COLOR
    TH_GSEL_ITEM_UNFOCUSED  =   ""
    TH_GSEL_ITEM_UNSELECTED =   ""
    TH_GSEL_ITEM_SELECTED   =   ""

    TH_GSEL_ITEM_FOCUSED_PREFIX     = ""
    TH_GSEL_ITEM_UNFOCUSED_PREFIX   = ""
    TH_GSEL_ITEM_UNSELECTED_PREFIX  = ""
    TH_GSEL_ITEM_SELECTED_PREFIX    = ""
    TH_GSEL_ITEM_PREFIX_WIDTH       = 0
}

function draw_gsel_multiple_style_init(){
    TH_GSEL_ITEM_FOCUSED    =   TH_THEME_COLOR
    TH_GSEL_ITEM_SELECTED   =   TH_THEME_COLOR
    TH_GSEL_ITEM_UNSELECTED =   ""

    TH_GSEL_ITEM_FOCUSED_PREFIX     = th(TH_THEME_COLOR, "> ")
    TH_GSEL_ITEM_UNFOCUSED_PREFIX   = "  "
    TH_GSEL_ITEM_UNSELECTED_PREFIX  = th(TH_THEME_COLOR, "○ ")
    TH_GSEL_ITEM_SELECTED_PREFIX    = th(TH_THEME_COLOR, "◉ ")      # "● "
    TH_GSEL_ITEM_PREFIX_WIDTH = 4
}


function draw_gsel_change_set_all( o, kp ){
    change_set( o, kp, "gsel.title")
    change_set( o, kp, "gsel.body")
    change_set( o, kp, "gsel.foot")
}

function draw_gsel_paint( o, kp, x1, x2, y1, y2, no_title, no_footer, opt,             _draw_body, _draw_title, _draw_footer, _draw_box, w ){

    w = wcswidth_cache(TH_GSEL_ITEM_UNFOCUSED_PREFIX)
    if ( ! no_title ) _draw_title  = draw_gsel___on_title(o, kp, x1, x1++, y1+w, y2, opt)
    _draw_body = draw_gsel___on_body(o, kp, x1, ((no_footer) ? x2 : x2-1), y1, y2, opt)
    if ( ! no_footer ) _draw_footer = draw_gsel___on_footer(o, kp, x2, x2, y1+w, y2, opt)

    return _draw_title _draw_body _draw_footer
}

function draw_gsel___on_body( o, kp, x1, x2, y1, y2, opt,        r, w, iw, ps, l, i, _start, _end, _draw_body ){
    if ( ! change_is(o, kp, "gsel.body") ) return
    change_unset(o, kp, "gsel.body")

    r = x2-x1+1
    w = y2-y1+1
    l = opt_get( opt, "data.maxrow" )
    iw = int(( (iw = opt_get( opt, "item.width" )) != "" ) ? iw : w )
    if ( iw > w ) iw = w
    ps = int( w / iw ) * r
    opt_set( opt, "pagesize", ps )
    opt_set( opt, "pagesize.row", r )

    _start = draw_unit_page_begin( opt_get( opt, "cur.cell" ), ps )
    _end   = draw_unit_page_end( opt_get( opt, "cur.cell" ), ps, l )
    for (i=_start; i<=_end; ++i){
        _draw_body = _draw_body draw_gsel___on_cell( o, kp, i, iw, opt ) \
            ( (i%r != 0) ? "\r\n" : "\r" painter_up(r-1) ) \
            painter_right( y1 + int( (i % ps) / r ) * iw )
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _draw_body
}

function draw_gsel___on_title(o, kp, x1, x2, y1, y2, opt,        title_val, v, _opt){
    if ( ! change_is(o, kp, "gsel.title") ) return
    change_unset(o, kp, "gsel.title")
    title_val = painter_goto_rel(x1, y1) th( TH_GSEL_TITLE, space_restrict_or_pad_utf8( opt_get( opt, "title.text" ), y2-y1+1) )
    if (opt_get( opt, "filter.enable" )){
        v = opt_get( opt, "filter.text" )
        if (v == "") v = title_val
        else {
            opt_set( _opt, "line.text",     v )
            opt_set( _opt, "line.width",    opt_get( opt, "filter.width" ) )
            opt_set( _opt, "cursor.pos",    opt_get( opt, "filter.cursor" ) )
            opt_set( _opt, "start.pos",     opt_get( opt, "filter.start" ) )
            v = draw_lineedit_paint(x1, x1, y1, y2, _opt)
        }
    }
    else if (opt_get( opt, "search.enable" )){
        v = opt_get( opt, "search.text" )
        if (v == "") v = title_val
        else {
            opt_set( _opt, "line.text",     v )
            opt_set( _opt, "line.width",    opt_get( opt, "search.width" ) )
            opt_set( _opt, "cursor.pos",    opt_get( opt, "search.cursor" ) )
            opt_set( _opt, "start.pos",     opt_get( opt, "search.start" ) )
            v = draw_lineedit_paint(x1, x1, y1, y2, _opt)
        }
    }
    else v = title_val
    return painter_clear_screen(x1, x2, y1, y2) v
}

function draw_gsel___on_footer(o, kp, x1, x2, y1, y2, opt,       v, i, s, p){
    if ( ! change_is(o, kp, "gsel.foot") ) return
    change_unset(o, kp, "gsel.foot")
    s = opt_get( opt, "pagesize" )
    i = opt_get( opt, "cur.cell" )
    i = int( ( i - 1 ) / s ) + 1
    p = int( ( opt_get( opt, "data.maxrow" ) - 1 ) / s ) + 1
    v = th( UI_TEXT_DIM, space_restrict_or_pad_utf8( "<" i "/" p ">" , y2-y1+1) )
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) v
}

function draw_gsel___on_cell( o, kp, i, w, opt,         v, ri){
    w = w - TH_GSEL_ITEM_PREFIX_WIDTH
    ri = model_arr_get(o, kp, "view-row" SUBSEP i)
    v = model_arr_data_get(o, kp, ri)
    v = space_restrict_or_pad_utf8_esc(v, w)

    if (draw_gsel_cell_selected( o, kp, ri )) v = TH_GSEL_ITEM_SELECTED_PREFIX th( TH_GSEL_ITEM_SELECTED, v )
    else v = TH_GSEL_ITEM_UNSELECTED_PREFIX th( TH_GSEL_ITEM_UNSELECTED, v )

    if (i == opt_get( opt, "cur.cell" )) v = TH_GSEL_ITEM_FOCUSED_PREFIX th( TH_GSEL_ITEM_FOCUSED, v )
    else v = TH_GSEL_ITEM_UNFOCUSED_PREFIX th( TH_GSEL_ITEM_UNFOCUSED, v )
    return v
}

## Section: draw model
function draw_gsel_cell_selected(o, kp, i, tf){
    if ( tf == "" ) return o[ kp, "draw", "sel-cell", i ]
    o[ kp, "draw", "sel-cell", i ] = tf
    draw_gsel_select_item(o, kp, i, tf)
}

function draw_gsel_cell_selected_limit(o, kp, v){
    if ( v == "" )  return o[ kp, "draw", "limit" ]
    else            o[ kp, "draw", "limit"] = v
}

function draw_gsel_cell_selected_count(o, kp){
    return model_arr_data_len( o,  kp SUBSEP "draw" SUBSEP "sel-cell" )
}

function draw_gsel_cell_selected_sw_toggle(o, kp, i,        l){
    if (draw_gsel_cell_selected( o, kp, i ))  draw_gsel_cell_selected(o, kp, i, false )
    else if (( (l = draw_gsel_cell_selected_limit(o, kp)) == "no-limit" ) || l > draw_gsel_cell_selected_count(o, kp))
        draw_gsel_cell_selected(o, kp, i, true)
}

function draw_gsel_select_item(o, kp, i, tf){
    if ( tf == "" )     return model_arr_data_get(o, kp SUBSEP "draw" SUBSEP "sel-cell", i)
    if (tf == true)     model_arr_add( o, kp SUBSEP "draw" SUBSEP "sel-cell", i )
    else                model_arr_rm( o, kp SUBSEP "draw" SUBSEP "sel-cell", i )
}
# EndSection
