function comp_navi_init( o, kp ){
    o[ kp, "TYPE" ] = "navi"
    # ROOTKP_SEP = "\"SUBSEP\""
    ROOTKP_SEP = SUBSEP
    comp_navi___cur_col_init( o, kp )
    comp_textbox_init(o, kp SUBSEP "navi.footer")
    change_set(o, kp, "navi.body")
    change_set(o, kp, "navi.footer")
    ctrl_sw_init( o, kp SUBSEP "IS_DIM", false)
}

# Section: ctrl, handle, data modification
function comp_navi_handle( o, kp, char_value, char_name, char_type,             _has_no_handle ){
    if ( o[ kp, "TYPE" ] != "navi" ) return false
    else if ((ctrl_navi_sel_sw_get(o, kp) == false) && ((char_value == "h") || (char_name == U8WC_NAME_LEFT)))
        _has_no_handle = 1 - comp_navi___ctrl_col_dec(o, kp)
    else if ((ctrl_navi_sel_sw_get(o, kp) == false) && ((char_value == "l") || (char_name == U8WC_NAME_RIGHT)))
        _has_no_handle = 1 - comp_navi___ctrl_col_inc(o, kp)
    else if (comp_navi___handle_sel( o, kp, char_value, char_name, char_type)) _has_no_handle = false
    else _has_no_handle = true

    if ( _has_no_handle == true ) return false
    change_set(o, kp, "navi.body")
    change_set(o, kp, "navi.footer")
    return true
}

function comp_navi_sel_sw_toggle( o, kp ){
    change_set( o, kp, "navi.body" )
    return comp_gsel_filter_sw_toggle( o, kp SUBSEP "comp.sel" SUBSEP comp_navi___trace_col_val_get( o, kp, comp_navi___cur_col_get(o, kp) ) )
}

function ctrl_navi_sel_sw_get( o, kp ) {
    return comp_gsel_filter_sw_get( o, kp SUBSEP "comp.sel" SUBSEP comp_navi___trace_col_val_get( o, kp, comp_navi___cur_col_get(o, kp) ) )
}

function comp_navi_get_cur_rootkp( o, kp,           c, r, rootkp, preview_kp ){
    if ((r = comp_navi___col_row_get( o, kp, c = comp_navi___cur_col_get(o, kp) )) == "" )   return
    rootkp = comp_navi___trace_col_val_get( o, kp, c )
    preview_kp = comp_navi___trace_row_val_get(o, kp, c, r)
    return rootkp ROOTKP_SEP preview_kp
}

function comp_navi_get_cur_preview_type( o, kp ){
    return comp_navi_get_col_preview_type( o, kp, comp_navi___cur_col_get(o, kp) )
}

function comp_navi_get_col_preview_type( o, kp, c,        r, rootkp ){
    if ((r = comp_navi___col_row_get( o, kp, c )) == "" )   return
    rootkp = comp_navi___trace_col_val_get( o, kp, c )
    return comp_navi_data_preview( o, kp, rootkp, r)
}

function comp_navi___cur_col_init( o, kp ){
    o[ kp, "ctrl-col" ] = 1
    o[ kp, "trace.col.rootkp", col ] = ""
}

function comp_navi___cur_col_get( o, kp ){
    return o[ kp, "ctrl-col" ]
}

function comp_navi___cur_col_set( o, kp, val ){
    o[ kp, "ctrl-col" ] = val
}

function comp_navi___ctrl_col_inc( o, kp,     v, _rootkp ){
    v = o[ kp, "ctrl-col" ]
    _rootkp = comp_navi_get_cur_rootkp( o, kp )
    if (( ! comp_navi_cur_preview_type_is_sel( o, kp ) ) || (comp_navi_data_len(o, kp, _rootkp) < 1 )) return false
    comp_navi___trace_col_val_set( o, kp, ++v, _rootkp )
    o[ kp, "ctrl-col" ] = v
    return true
}

function comp_navi___ctrl_col_dec( o, kp,     v ){
    v = o[ kp, "ctrl-col" ]
    if ( v <= 1 ) return false
    o[ kp, "ctrl-col" ] = --v
    return true
}

function comp_navi___col_row_get( o, kp, col ){
    return comp_gsel_focused_item_true_get( o, kp SUBSEP "comp.sel" SUBSEP comp_navi___trace_col_val_get( o, kp, col) )
}

function comp_navi___col_row_set( o, kp, col, row,            _rootkp ){
    _rootkp = comp_navi___trace_col_val_get(o, kp, col)
    if (row > comp_navi_data_len(o, kp, _rootkp)) return false
    return ctrl_page_set(o, kp SUBSEP "comp.sel" SUBSEP _rootkp, row)
}

function comp_navi___trace_col_val_get( o, kp, col ){
    return o[ kp, "trace.col.rootkp", col ]
}

function comp_navi___trace_col_val_set( o, kp, col, val ){
    o[ kp, "trace.col.rootkp", col ] = val
}

function comp_navi___trace_row_val_get( o, kp, col, row,      rootkp ){
    rootkp = comp_navi___trace_col_val_get( o, kp, col )
    return comp_navi_data_preview_kp(o, kp, rootkp, row)
}

function comp_navi___handle_sel( o, kp, char_value, char_name, char_type,         _rootkp ){
    _rootkp = comp_navi___trace_col_val_get(o, kp, comp_navi___cur_col_get(o, kp))
    return comp_gsel_handle(o, kp SUBSEP "comp.sel" SUBSEP _rootkp, char_value, char_name, char_type)
}

function comp_navi___sel_data_add( o, kp, rootkp, val ){
    comp_gsel_init( o, kp SUBSEP "comp.sel" SUBSEP rootkp, "", false )
    comp_gsel_data_add( o, kp SUBSEP "comp.sel" SUBSEP rootkp, val)
}

# EndSection

# Section: data

# viewdata 是显示的内容
# previewdata 是 { 或者 preview 的类型

# TODO: demo: ls expolorer
function comp_navi_data_set_available( o, kp, rootkp, v, viewlen ){
    o[ kp, "data", rootkp, "ava" ] = v
    o[ kp, "data", rootkp, "viewlen" ] = (viewlen != "") ? viewlen : 20
}
function comp_navi_data_add_kv( o, kp, rootkp, viewdata, previewdata, preview_kp, viewlen,        l ){
    l = o[ kp, "data", rootkp L ] = o[ kp, "data", rootkp L ] + 1
    comp_navi_data_set_available( o, kp, rootkp, true, viewlen )
    o[ kp, "data", rootkp, l, "view" ] = viewdata
    o[ kp, "data", rootkp, l, "preview" ] = previewdata
    o[ kp, "data", rootkp, l, "preview_kp" ] = preview_kp
    comp_navi___sel_data_add( o, kp, rootkp, viewdata)
    change_set( o, kp, "navi.body")
    change_set( o, kp, "navi.footer")
}

function comp_navi_data_len( o, kp, rootkp ){
    return (o[ kp, "data", rootkp L ])
}

function comp_navi_data_view( o, kp, rootkp, idx ){
    return o[ kp, "data", rootkp, idx, "view" ]
}

function comp_navi_data_preview( o, kp, rootkp, idx ){
    return o[ kp, "data", rootkp, idx, "preview" ]
}

function comp_navi_data_preview_kp( o, kp, rootkp, idx ){
    return o[ kp, "data", rootkp, idx, "preview_kp" ]
}

function comp_navi_data_maxviewlen( o, kp ){
    return o[ kp, "maxviewlen" ]
}

function comp_navi_data_maxviewlen_set( o, kp, val ){
    o[ kp, "maxviewlen" ] = val
}

function comp_navi_data_viewlen_set( o, kp, rootkp, val ){
    o[ kp, "data", rootkp, "viewlen" ] = val
}

function comp_navi_data_viewlen( o, kp, rootkp,        l, m ){
    return ( (l = o[ kp, "data", rootkp, "viewlen" ]) > (m = comp_navi_data_maxviewlen(o, kp)) ) ? m : l
}

function comp_navi_unava_set( o, kp, rootkp ){
    change_set( o, kp, "unava" )
    o[ kp, "unava" ] = rootkp
}

function comp_navi_unava_get( o, kp ){
    return o[ kp, "unava" ]
}

function comp_navi_unava_has_set( o, kp ){
    return change_is( o, kp, "unava" )
}

function comp_navi_unava_unset( o, kp ){
    change_unset( o, kp, "unava" )
    o[ kp, "unava" ] = ""
}

function comp_navi_cur_preview_type_is_sel( o, kp ){
    return (comp_navi_get_cur_preview_type( o, kp ) == "{")
}

function comp_navi_col_preview_type_is_sel( o, kp, c ){
    return (comp_navi_get_col_preview_type( o, kp, c ) == "{")
}

function comp_navi___layout_init( o, kp, w,       i, l, _colw, _viewcol_begin ){
    w -= comp_navi_data_maxviewlen(o, kp)
    l = comp_navi___cur_col_get( o, kp )
    for (i=l; i>=1; --i){
        _colw = comp_navi_data_viewlen( o, kp, comp_navi___trace_col_val_get(o, kp, comp_navi___cur_col_get(o, kp)) )
        w -= _colw
        if (w < 0) break
        _viewcol_begin = i
    }
    o[ kp, "viewcol.begin" ] = _viewcol_begin
}
# EndSection

# Section: paint

# Paint only the available columns
# paint the right part first
function comp_navi_paint( o, kp, x1, x2, y1, y2, is_dim,        _comp_clear, _comp_sel, _comp_preview, _comp_box ){
    if ( ! change_is(o, kp, "navi.body") ) return
    change_unset(o, kp, "navi.body")
    comp_navi_unava_unset( o, kp )
    comp_navi___paint_dim_set( o, kp, is_dim )

    _comp_clear = painter_clear_screen(x1, x2, y1, y2)
    _comp_box = comp_navi___paint_box( o, kp, x1, x2, y1, y2 )
    x1++; x2--; y1+=2; y2-=2

    _comp_sel = comp_navi___paint_body( o, kp, x1, x2, y1, y2 )
    w = o[ kp, "view.body", "width" ]
    _comp_preview = comp_navi___paint_preview( o, kp, x1, x2, y1+w, y2 )

    return _comp_clear _comp_box _comp_sel _comp_preview
}

function comp_navi_change_set_all( o, kp ){
    change_set(o, kp, "navi.body")
    change_set(o, kp, "navi.footer")
    comp_navi___preview_set( o, kp )
}

function comp_navi_paint_preview_ischange( o, kp ){
    return change_is( o, kp, "PREVIEW" )
}

function comp_navi___paint_body( o, kp, x1, x2, y1, y2,           _rootkp, _start, _width, i, l, w, s, c ){
    _width = y2-y1+1
    comp_navi_data_maxviewlen_set( o, kp, int(_width/3))
    comp_navi___layout_init( o, kp, _width)

    _start = o[ kp, "viewcol.begin" ]
    l = comp_navi___cur_col_get( o, kp )
    for (i=_start; i<=l; ++i) {
        _rootkp = comp_navi___trace_col_val_get( o, kp, i )
        if (o[ kp, "data", _rootkp, "ava" ] != true) {
            comp_navi_unava_set( o, kp, _rootkp )
            break
        } else {
            w = comp_navi_data_viewlen( o, kp, _rootkp )
            s = s comp_navi___paint_body_sel( o, kp, _rootkp, x1, x2, y1+c, y1+c+w-2, (i != l))
            c += w
        }
    }
    o[ kp, "view.body", "width" ] = c
    return s
}

function comp_navi___paint_body_sel(o, kp, rootkp, x1, x2, y1, y2, is_dim,        s){
    s = painter_vline_ends( x1-1, x2+1, y2 ); y2--
    return s comp_navi___sel_paint( o, kp, rootkp, x1, x2, y1, y2, (comp_navi___paint_is_dim(o, kp)) ? true : is_dim )
}

function comp_navi___paint_preview( o, kp, x1, x2, y1, y2,            c, r, s, rootkp ){
    c = comp_navi___cur_col_get( o, kp )
    if ((r = comp_navi___col_row_get( o, kp, c )) == "" )   return s

    rootkp = comp_navi_get_cur_rootkp( o, kp )
    comp_navi___preview_unset( o, kp )
    if (comp_navi_cur_preview_type_is_sel( o, kp )) {
        if (o[ kp, "data", rootkp, "ava" ] != true) comp_navi_unava_set( o, kp, rootkp )
        else s = comp_navi___paint_preview_sel(o, kp, rootkp, x1, x2, y1, y2)
    } else {
        change_set( o, kp, "navi.preview" )
        comp_navi___preview_set( o, kp )
    }
    comp_navi___paint_preview_set( o, kp, rootkp, x1, x2, y1, y2)
    return s
}

function comp_navi___paint_preview_sel(o, kp, rootkp, x1, x2, y1, y2,             s){
    return comp_navi___sel_paint( o, kp, rootkp, x1, x2, y1, y2, true, true)
}

function comp_navi___sel_paint( o, kp, rootkp, x1, x2, y1, y2, is_dim, is_preview,           gkp, _comp_gsel_title, _comp_gsel_body ) {
    gkp = kp SUBSEP "comp.sel" SUBSEP rootkp
    comp_gsel_change_set_all( o, gkp )
    if (is_dim == true) {
        if (is_preview != true) TH_GSEL_ITEM_FOCUSED_PREFIX = ">"
        else TH_GSEL_ITEM_FOCUSED_PREFIX = " "
        TH_GSEL_ITEM_UNSELECTED = UI_TEXT_DIM
        TH_GSEL_ITEM_UNFOCUSED_PREFIX = " "
        TH_GSEL_ITEM_PREFIX_WIDTH = 1
        TH_GSEL_ITEM_FOCUSED = UI_TEXT_ITALIC UI_TEXT_BOLD
    }

    if (ctrl_navi_sel_sw_get(o, kp) && (rootkp == comp_navi___trace_col_val_get( o, kp, comp_navi___cur_col_get(o, kp)))) {
        comp_gsel_title_set( o, gkp, "Search:" )
        _comp_gsel_title = comp_gsel___paint_title( o, gkp, x1, x1, y1, y2)
        x1++
    }
    _comp_gsel_body = comp_gsel___paint_body( o, gkp, x1, x2, y1, y2)
    comp_gsel_style_init()
    return _comp_gsel_title _comp_gsel_body
}

function comp_navi___paint_box( o, kp, x1, x2, y1, y2 ){
    return painter_box_arc( x1, x2, y1, y2, (comp_navi___paint_is_dim(o, kp) == true) ? UI_TEXT_DIM : TH_THEME_COLOR )
}

function comp_navi___paint_preview_set( o, kp, rootkp, x1, x2, y1, y2 ){
    o[ kp, "PREVIEW", "KP" ] = rootkp
    o[ kp, "PREVIEW", "X1" ] = x1
    o[ kp, "PREVIEW", "X2" ] = x2
    o[ kp, "PREVIEW", "Y1" ] = y1
    o[ kp, "PREVIEW", "Y2" ] = y2
}

function comp_navi___preview_unset( o, kp ){
    change_unset( o, kp, "PREVIEW" )
}

function comp_navi___preview_set( o, kp ){
    change_set( o, kp, "PREVIEW" )
}

function comp_navi___paint_dim_set( o, kp, v ){  o[ kp, "IS_DIM" ] = v;    }
function comp_navi___paint_is_dim( o, kp ){  return o[ kp, "IS_DIM" ];   }

# EndSection

# Section: current position
function comp_navi_current_position_var(o, kp, s,       a, i, l){
    l = split(s, a, "/")
    for (i=1; i<=l; ++i) o[ kp, "cur.pos", i ] = a[i]
    return o[ kp, "cur.pos", "unprocessed_arg_count" ] = o[ kp, "cur.pos" L ] = l
}

function comp_navi_current_position_set(o, kp,          c, l, _kp){
    if (o[ kp, "cur.pos", "unprocessed_arg_count" ] <= 0) return
    c = comp_navi___cur_col_get(o, kp)
    if (c <= (l = o[ kp, "cur.pos" L ])){
        _kp = comp_navi___trace_col_val_get(o, kp, c)
        if (o[ kp, "data", _kp, "ava" ] == true){
            if (comp_navi___col_row_set(o, kp, c, o[ kp, "cur.pos", c ]) == false) return
            comp_navi_change_set_all( o, kp )
            if ((c < l) && (comp_navi_col_preview_type_is_sel(o, kp, c)) && (comp_navi___ctrl_col_inc(o, kp) == false)) return
            o[ kp, "cur.pos", "unprocessed_arg_count" ] --
        }
    }
}

function comp_navi_current_position_get(o, kp,      c, i, r, s){
    c = comp_navi___cur_col_get(o, kp)
    for (i=1; i<=c; ++i){
        r = comp_navi___col_row_get(o, kp, i)
        s = s ((s != "") ? "/" r : r)
    }
    return s
}

# EndSection
