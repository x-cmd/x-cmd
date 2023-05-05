function comp_navi_init( o, kp ){
    o[ kp, "TYPE" ] = "navi"
    # ROOTKP_SEP = "\"SUBSEP\""
    ROOTKP_SEP = SUBSEP
    comp_navi___cur_col(o, kp, 1)
    comp_navi___trace_col_val(o, kp, col, "", true)
    comp_textbox_init(o, kp SUBSEP "navi.footer")
    ctrl_sw_init( o, kp SUBSEP "IS_DIM", false)
    change_set(o, kp, "navi.footer")
    change_set(o, kp, "navi.body")
    comp_navi_unava(o, kp, -1)
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
    return comp_gsel_filter_sw_toggle( o, kp SUBSEP "comp.sel" SUBSEP comp_navi___trace_col_val( o, kp, comp_navi___cur_col(o, kp) ) )
}

function ctrl_navi_sel_sw_get( o, kp ) {
    return comp_gsel_filter_sw_get( o, kp SUBSEP "comp.sel" SUBSEP comp_navi___trace_col_val( o, kp, comp_navi___cur_col(o, kp) ) )
}

function comp_navi_get_cur_rootkp( o, kp,           c, r, rootkp, preview_kp ){
    if ((r = comp_navi___col_row_get( o, kp, c = comp_navi___cur_col(o, kp) )) == "" )   return
    rootkp = comp_navi___trace_col_val( o, kp, c )
    preview_kp = comp_navi___trace_row_val_get(o, kp, c, r)
    return rootkp ROOTKP_SEP preview_kp
}

function comp_navi_get_cur_preview_type( o, kp ){
    return comp_navi_get_col_preview_type( o, kp, comp_navi___cur_col(o, kp) )
}

function comp_navi_get_col_preview_type( o, kp, c,        r, rootkp ){
    if ((r = comp_navi___col_row_get( o, kp, c )) == "" )   return
    rootkp = comp_navi___trace_col_val( o, kp, c )
    return comp_navi_data_preview( o, kp, rootkp, r)
}

function comp_navi___cur_col(o, kp, v){
    if (v == "")    return o[ kp, "ctrl-col" ]
    else            o[ kp, "ctrl-col" ] = v
}

function comp_navi___ctrl_col_inc( o, kp,     v, _rootkp ){
    v = comp_navi___cur_col(o, kp)
    _rootkp = comp_navi_get_cur_rootkp( o, kp )
    if (( ! comp_navi_cur_preview_type_is_sel( o, kp ) ) || (comp_navi_data_len(o, kp, _rootkp) < 1 )) return false
    comp_navi___trace_col_val( o, kp, ++v, _rootkp, true )
    comp_navi___cur_col(o, kp, v)
    return true
}

function comp_navi___ctrl_col_dec( o, kp,     v ){
    v = comp_navi___cur_col(o, kp)
    if ( v <= 1 ) return false
    comp_navi___cur_col(o, kp, --v)
    return true
}

function comp_navi___col_row_get( o, kp, col ){
    return comp_gsel_get_cur_cell( o, kp SUBSEP "comp.sel" SUBSEP comp_navi___trace_col_val( o, kp, col) )
}

function comp_navi___col_row_set( o, kp, col, row,            _rootkp ){
    _rootkp = comp_navi___trace_col_val(o, kp, col)
    if (row > comp_navi_data_len(o, kp, _rootkp)) return false
    return ctrl_page_set(o, kp SUBSEP "comp.sel" SUBSEP _rootkp, row)
}

function comp_navi___trace_col_val( o, kp, col, val, force_set ){
    if ((val == "") && (!force_set))  return o[ kp, "trace.col.rootkp", col ]
    else                              o[ kp, "trace.col.rootkp", col ] = val
}

function comp_navi___trace_row_val_get( o, kp, col, row,      rootkp ){
    rootkp = comp_navi___trace_col_val( o, kp, col )
    return comp_navi_data_preview_kp(o, kp, rootkp, row)
}

function comp_navi___handle_sel( o, kp, char_value, char_name, char_type,         _rootkp ){
    _rootkp = comp_navi___trace_col_val(o, kp, comp_navi___cur_col(o, kp))
    if( ! comp_gsel_handle(o, kp SUBSEP "comp.sel" SUBSEP _rootkp, char_value, char_name, char_type) ) return false
    comp_gsel_model_end( o, kp SUBSEP "comp.sel" SUBSEP _rootkp )
    return true
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
function comp_navi_data_available( o, kp, rootkp, tf ){
    if (tf == "")        return o[ kp, "data", rootkp, "ava" ]
    o[ kp, "data", rootkp, "ava" ] = tf
}
function comp_navi_data_add_kv( o, kp, rootkp, viewdata, previewdata, preview_kp, viewlen,        l ){
    l = o[ kp, "data", rootkp L ] = o[ kp, "data", rootkp L ] + 1
    comp_navi_data_available( o, kp, rootkp, true )
    o[ kp, "data", rootkp, l, "view" ] = viewdata
    o[ kp, "data", rootkp, l, "preview" ] = previewdata
    o[ kp, "data", rootkp, l, "preview_kp" ] = preview_kp
    comp_navi___sel_data_add( o, kp, rootkp, viewdata)
    comp_navi_data_view_width(o, kp, rootkp, ((viewlen != "") ? int(viewlen) : 20))
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

function comp_navi_data_maxview_width( o, kp, v ){
    return draw_navi_data_maxview_width(o, kp, v)
}

function comp_navi_data_view_width( o, kp, rootkp, v ){
    return draw_navi_data_view_width( o, kp, rootkp, v )
}

function comp_navi_unava_has_set( o, kp ){
    return draw_navi_unava_has_set( o, kp )
}

function comp_navi_unava(o, kp, v, force_set){
    return draw_navi_unava(o, kp, v, force_set)
}

function comp_navi_cur_preview_type_is_sel( o, kp ){
    return draw_navi_cur_preview_type_is_sel( o, kp )
}

function comp_navi_col_preview_type_is_sel( o, kp, c ){
    return draw_navi_col_preview_type_is_sel( o, kp, c )
}

# EndSection

# Section: paint

# Paint only the available columns
# paint the right part first
function comp_navi_change_set_all( o, kp ){
    draw_navi_change_set_all( o, kp )
}

function comp_navi_paint( o, kp, x1, x2, y1, y2, is_dim,        _opt ){
    opt_set( _opt, "cur.col",   comp_navi___cur_col(o, kp) )
    opt_set( _opt, "sel.sw",    ctrl_navi_sel_sw_get(o, kp) )
    return draw_navi_paint( o, kp, x1, x2, y1, y2, is_dim, _opt )
}

function comp_navi_paint_preview_ischange(o, kp) {
    return draw_navi_paint_preview_ischange(o, kp)
}

# EndSection

# Section: current position
function comp_navi_current_position_var(o, kp, s,       a, i, l){
    l = split(s, a, "/")
    for (i=1; i<=l; ++i) o[ kp, "cur.pos", i ] = a[i]
    return o[ kp, "cur.pos", "unprocessed_arg_count" ] = o[ kp, "cur.pos" L ] = l
}

function comp_navi_current_position_set(o, kp,          c, l, _kp){
    if (o[ kp, "cur.pos", "unprocessed_arg_count" ] <= 0) return
    c = comp_navi___cur_col(o, kp)
    if (c <= (l = o[ kp, "cur.pos" L ])){
        _kp = comp_navi___trace_col_val(o, kp, c)
        if (comp_navi_data_available(o, kp, _kp)){
            if (comp_navi___col_row_set(o, kp, c, o[ kp, "cur.pos", c ]) == false) return
            comp_navi_change_set_all( o, kp )
            if ((c < l) && (comp_navi_col_preview_type_is_sel(o, kp, c)) && (comp_navi___ctrl_col_inc(o, kp) == false)) return
            o[ kp, "cur.pos", "unprocessed_arg_count" ] --
        }
    }
}

function comp_navi_current_position_get(o, kp,      c, i, r, s){
    c = comp_navi___cur_col(o, kp)
    for (i=1; i<=c; ++i){
        r = comp_navi___col_row_get(o, kp, i)
        s = s ((s != "") ? "/" r : r)
    }
    return s
}

# EndSection
