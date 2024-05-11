function draw_unit_page_begin( v, page_row ) {
    if ( page_row <= 0 ) return 1
    return ( int((v-1) / page_row) * page_row ) + 1
}

function draw_unit_page_end( v, page_row, data_max ) {
    v = draw_unit_page_begin( v, page_row )
    v = v + page_row - 1
    return ( v > data_max ) ? data_max : v
}

function draw_unit_truncate_string( str, w,      v ){
    str = draw_text_first_line( str )
    v = wcstruncate_cache( str, w )
    if (v == str)  return str space_rep(w - wcswidth_cache( str ))
    return wcstruncate_cache( v, w-1 ) "…"
}

function draw_unit_cell_match_highlight( s, v, style,           sl, id ){
    if ((s == "") || ((id = index(tolower(v), tolower(s))) <= 0)) return th( style, v )
    sl = length(s)
    return style substr(v, 1, id-1) \
        UI_FG_YELLOW substr(v, id, sl) UI_END \
        style substr(v, id+sl) UI_END
}
