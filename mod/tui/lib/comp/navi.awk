function comp_navi_init( o, kp ){
    o[ kp, "TYPE" ] = "navi"
    comp_navi___cur_col(o, kp, 1)
    navi_arr_data_trace_col_val(o, kp, col, "", true)
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
    return comp_gsel_ctrl_filter_sw_toggle( o, navi_arr_data_sel_kp_get( kp, navi_arr_data_trace_col_val( o, kp, comp_navi___cur_col(o, kp) ) ) )
}

function ctrl_navi_sel_sw_get( o, kp ) {
    return comp_gsel_ctrl_filter_sw_get( o, navi_arr_data_sel_kp_get( kp, navi_arr_data_trace_col_val( o, kp, comp_navi___cur_col(o, kp) ) ) )
}

function comp_navi_get_cur_rootkp( o, kp,           c, r, rootkp, preview_kp ){
    if ((r = comp_navi___col_row_get( o, kp, c = comp_navi___cur_col(o, kp) )) == "" )   return
    rootkp = navi_arr_data_trace_col_val( o, kp, c )
    return comp_navi_data_preview_kp( o, kp, rootkp, r)
}

function comp_navi_get_cur_preview_type( o, kp ){
    return comp_navi_get_col_preview_type( o, kp, comp_navi___cur_col(o, kp) )
}

function comp_navi_get_col_preview_type( o, kp, c,        r, rootkp ){
    if ((r = comp_navi___col_row_get( o, kp, c )) == "" )   return
    rootkp = navi_arr_data_trace_col_val( o, kp, c )
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
    navi_arr_data_trace_col_val( o, kp, ++v, _rootkp, true )
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
    return comp_gsel_get_cur_cell( o, navi_arr_data_sel_kp_get( kp, navi_arr_data_trace_col_val( o, kp, col) ) )
}

function comp_navi___col_row_set( o, kp, col, row,            _rootkp ){
    _rootkp = navi_arr_data_trace_col_val(o, kp, col)
    if (row > comp_navi_data_len(o, kp, _rootkp)) return false
    return ctrl_page_set(o, navi_arr_data_sel_kp_get( kp, _rootkp ), row)
}

function comp_navi___trace_row_val_get( o, kp, col, row,      rootkp ){
    rootkp = navi_arr_data_trace_col_val( o, kp, col )
    return comp_navi_data_preview_kp(o, kp, rootkp, row)
}

function comp_navi___handle_sel( o, kp, char_value, char_name, char_type,         _rootkp ){
    _rootkp = navi_arr_data_trace_col_val(o, kp, comp_navi___cur_col(o, kp))
    if( ! comp_gsel_handle(o, navi_arr_data_sel_kp_get( kp, _rootkp ), char_value, char_name, char_type) ) return false
    comp_gsel_model_end( o, navi_arr_data_sel_kp_get( kp, _rootkp ) )
    return true
}

function comp_navi___sel_data_add( o, kp, rootkp, val ){
    comp_gsel_init( o, navi_arr_data_sel_kp_get( kp, rootkp ), "", false )
    comp_gsel_data_add( o, navi_arr_data_sel_kp_get( kp, rootkp ), val)
}

# EndSection

# Section: data

# viewdata 是显示的内容
# previewdata 是 { 或者 preview 的类型

# TODO: demo: ls expolorer
function comp_navi_data_init( o, kp, rootkp ){
    comp_gsel_init( o, navi_arr_data_sel_kp_get( kp, rootkp ), "", false )
    comp_navi_data_available( o, kp, rootkp, true )
}
function comp_navi_data_end( o, kp, rootkp ){
    comp_gsel_model_end( o, navi_arr_data_sel_kp_get( kp, rootkp ) )
    draw_navi_change_set_all( o, kp )
}
function comp_navi_data_add_kv( o, kp, rootkp, viewdata, previewdata, preview_kp, viewlen ){
    navi_arr_data_add_kv( o, kp, rootkp, viewdata, previewdata, preview_kp, viewlen )
}

function comp_navi_data_len( o, kp, rootkp ){               return navi_arr_data_len( o, kp, rootkp );              }
function comp_navi_data_view( o, kp, rootkp, idx ){         return navi_arr_data_view( o, kp, rootkp, idx );        }
function comp_navi_data_preview( o, kp, rootkp, idx ){      return navi_arr_data_preview( o, kp, rootkp, idx );     }
function comp_navi_data_preview_kp( o, kp, rootkp, idx ){   return navi_arr_data_preview_kp( o, kp, rootkp, idx );  }
function comp_navi_data_maxview_width( o, kp, v ){          return navi_arr_data_maxview_width(o, kp, v);           }
function comp_navi_data_view_width( o, kp, rootkp, v ){     return navi_arr_data_view_width( o, kp, rootkp, v );    }

function comp_navi_unava_has_set( o, kp ){                  return draw_navi_unava_has_set( o, kp );                }
function comp_navi_unava(o, kp, v, force_set){              return draw_navi_unava(o, kp, v, force_set);            }
function comp_navi_data_available( o, kp, rootkp, tf ){     return draw_navi_data_available( o, kp, rootkp, tf );   }
function comp_navi_cur_preview_type_is_sel( o, kp ){
    return (comp_navi_get_cur_preview_type( o, kp ) == "{")
}
function comp_navi_col_preview_type_is_sel( o, kp, c ){
    return (comp_navi_get_col_preview_type( o, kp, c ) == "{")
}

# EndSection

# Section: paint

# Paint only the available columns
# paint the right part first
function comp_navi_change_set_all( o, kp ){
    draw_navi_change_set_all( o, kp )
}

function comp_navi_paint( o, kp, x1, x2, y1, y2, is_dim,        _opt, c ){
    opt_set( _opt, "cur.col",       (c = comp_navi___cur_col(o, kp)) )
    opt_set( _opt, "cur.col.row",   comp_navi___col_row_get(o, kp, c) )
    opt_set( _opt, "cur.rootkp",    comp_navi_get_cur_rootkp(o, kp) )
    opt_set( _opt, "cur.preview_kp",comp_navi_get_cur_rootkp(o, kp) )
    opt_set( _opt, "sel.sw",        ctrl_navi_sel_sw_get(o, kp) )
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
        _kp = navi_arr_data_trace_col_val(o, kp, c)
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
