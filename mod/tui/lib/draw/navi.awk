function draw_navi_change_set_all( o, kp ){
    change_set(o, kp, "navi.body")
    change_set(o, kp, "navi.footer")
    draw_navi_paint_preview_ischange( o, kp, true )
}

function draw_navi_data_available( o, kp, rootkp, tf ){
    if (tf == "")        return o[ kp, "data", rootkp, "ava" ]
    o[ kp, "data", rootkp, "ava" ] = tf
}

function draw_navi_paint( o, kp, x1, x2, y1, y2, is_dim, opt,       _draw_clear, _draw_sel, _draw_preview, _draw_box ){
    if ( ! change_is(o, kp, "navi.body") ) return
    change_unset(o, kp, "navi.body")
    draw_navi_unava( o, kp, -1 )
    draw_navi___paint_is_dim( o, kp, is_dim )

    _draw_clear = painter_clear_screen(x1, x2, y1, y2)
    _draw_box = draw_navi___paint_box( o, kp, x1, x2, y1, y2 )
    x1++; x2--; y1+=2; y2-=2

    _draw_sel = draw_navi___paint_body( o, kp, x1, x2, y1, y2, opt )
    w = o[ kp, "view.body", "width" ]
    _draw_preview = draw_navi___paint_preview( o, kp, x1, x2, y1+w, y2, opt )

    return _draw_clear _draw_box _draw_sel _draw_preview
}

function draw_navi___paint_body( o, kp, x1, x2, y1, y2, opt,           _rootkp, _start, _width, i, l, w, s, c ){
    _width = y2-y1+1
    navi_arr_data_maxview_width( o, kp, int(_width/3))
    l = opt_get( opt, "cur.col" )
    draw_navi_layout_init( o, kp, _width, l)

    _start = o[ kp, "viewcol.begin" ]
    for (i=_start; i<=l; ++i) {
        _rootkp = navi_arr_data_trace_col_val( o, kp, i )
        if (!draw_navi_data_available(o, kp, _rootkp)) {
            draw_navi_unava( o, kp, _rootkp, true )
            break
        } else {
            w = navi_arr_data_view_width( o, kp, _rootkp )
            s = s draw_navi___paint_body_sel( o, kp, _rootkp, x1, x2, y1+c, y1+c+w-2, (i != l), opt)
            c += w
        }
    }
    o[ kp, "view.body", "width" ] = c
    return s
}

function draw_navi___paint_body_sel(o, kp, rootkp, x1, x2, y1, y2, is_dim, opt,        s){
    s = painter_vline_ends( x1-1, x2+1, y2 ); y2--
    return s draw_navi___paint_sel( o, kp, rootkp, x1, x2, y1, y2, ((draw_navi___paint_is_dim(o, kp)) ? true : is_dim), false, opt )
}

function draw_navi___paint_preview( o, kp, x1, x2, y1, y2, opt,            c, r, s, rootkp ){
    c = opt_get( opt, "cur.col" )
    if ( (r = opt_get( opt, "cur.col.row" )) == "" )   return s

    rootkp = opt_get( opt, "cur.rootkp" )
    draw_navi_paint_preview_ischange(o, kp, false)
    if (navi_arr_data_preview_is_sel( o, kp, navi_arr_data_trace_col_val( o, kp, c ), r )) {
        if (!draw_navi_data_available(o, kp, rootkp)) draw_navi_unava( o, kp, rootkp, true )
        else s = draw_navi___paint_preview_sel(o, kp, rootkp, x1, x2, y1, y2, opt)
    } else {
        change_set( o, kp, "navi.preview" )
        draw_navi_paint_preview_ischange(o, kp, true)
    }
    draw_navi___paint_preview_set( o, kp, rootkp, x1, x2, y1, y2)
    return s
}

function draw_navi___paint_preview_sel(o, kp, rootkp, x1, x2, y1, y2, opt,             s){
    return draw_navi___paint_sel( o, kp, rootkp, x1, x2, y1, y2, true, true, opt)
}

function draw_navi___paint_sel( o, kp, rootkp, x1, x2, y1, y2, is_dim, is_preview, opt,          gkp, _draw_gsel, _no_title ) {
    gkp = navi_arr_data_sel_kp_get( kp, rootkp )
    draw_gsel_change_set_all( o, gkp )
    if (is_dim == true) {
        if (is_preview != true) TH_GSEL_ITEM_FOCUSED_PREFIX = ">"
        else TH_GSEL_ITEM_FOCUSED_PREFIX = " "
        TH_GSEL_ITEM_UNSELECTED = UI_TEXT_DIM
        TH_GSEL_ITEM_UNFOCUSED_PREFIX = " "
        TH_GSEL_ITEM_PREFIX_WIDTH = 1
        TH_GSEL_ITEM_FOCUSED = UI_TEXT_ITALIC UI_TEXT_BOLD
    }

    _no_title = true
    if (opt_get( opt, "sel.sw" ) && (rootkp == navi_arr_data_trace_col_val( o, kp, opt_get( opt, "cur.col" )))) {
        comp_gsel_title( o, gkp, "Search:" )
        _no_title = false
    }

    _draw_gsel = comp_gsel_paint(o, gkp, x1, x2, y1, y2, _no_title, true)
    comp_gsel_style_init()
    return _draw_gsel
}

function draw_navi___paint_box( o, kp, x1, x2, y1, y2 ){
    return painter_box_arc( x1, x2, y1, y2, (draw_navi___paint_is_dim(o, kp) == true) ? UI_TEXT_DIM : TH_THEME_COLOR )
}

function draw_navi___paint_preview_set( o, kp, rootkp, x1, x2, y1, y2 ){
    o[ kp, "PREVIEW", "KP" ] = rootkp
    o[ kp, "PREVIEW", "X1" ] = x1
    o[ kp, "PREVIEW", "X2" ] = x2
    o[ kp, "PREVIEW", "Y1" ] = y1
    o[ kp, "PREVIEW", "Y2" ] = y2
}

function draw_navi_paint_preview_ischange( o, kp, tf ){
    if (tf == "")           return change_is( o, kp, "PREVIEW" )
    else if (tf == true)    change_set( o, kp, "PREVIEW" )
    else                    change_unset( o, kp, "PREVIEW" )
}

function draw_navi___paint_is_dim( o, kp, v ){
    if (v == "")    return o[ kp, "IS_DIM" ]
    else            o[ kp, "IS_DIM" ] = v
}

function draw_navi_unava_has_set( o, kp ){
    return (draw_navi_unava(o, kp) != -1)
}

function draw_navi_unava(o, kp, v, force_set){
    if ((v == "") && (!force_set))   return o[ kp, "unava" ]
    else o[ kp, "unava" ] = v
}

function draw_navi_layout_init( o, kp, w, l,       i, _colw, _viewcol_begin ){
    w -= navi_arr_data_maxview_width(o, kp)
    for (i=l; i>=1; --i){
        _colw = navi_arr_data_view_width( o, kp, navi_arr_data_trace_col_val(o, kp, i) )
        w -= _colw
        if (w < 0) break
        _viewcol_begin = i
    }
    o[ kp, "viewcol.begin" ] = _viewcol_begin
}
