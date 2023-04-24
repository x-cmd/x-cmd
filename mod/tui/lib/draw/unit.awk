function draw_unit_page_begin( v, page_row ) {
    return ( int((v-1) / page_row) * page_row ) + 1
}

function draw_unit_page_end( v, page_row, data_max ) {
    v = draw_unit_page_begin( v, page_row )
    v = v + page_row - 1
    return ( v > data_max ) ? data_max : v
}

