
# Need to prefetch line
function md_handle_table( line, output_arr,         _line1, _line2, _c, _a1l, _a2l, arr, row, i, j, r, l, w, width, item ){
    _c = md_getline()
    _line1 = line
    _line2 = $0

    if (_line2 !~ MD_REGEX_TABLE_HEADER_LINE) {
        md_handle_body( _line1, output_arr )
        md_handle_body( _line2, output_arr )
        return (_c == 1)
    }

    _a1l = md_handle_table_arr( _line1, arr, width, ++row )
    _a2l = md_handle_table_arr( _line2, arr, width, ++row )
    if (_a1l > _a2l){
        md_handle_body( _line1, output_arr )
        md_handle_body( _line2, output_arr )
        return 1
    }


    while(md_getline()){
        if ($0 ~ MD_REGEX_SPACE) break
        md_handle_table_arr( $0, arr, width, ++row )
    }

    # keep split and render using table
    # When finish, then print the table
    for (i=1; i<=row; ++i){
        l = arr[ 2 L ]
        if (i == 2) {
            for (j=1; j<=l; ++j){
                w = width[j]
                item = str_rep("─", w) "──"
                r = ((j == 1) ? "──" : r "┼─" ) item
            }
        } else {
            for (j=1; j<=l; ++j){
                w = width[j]
                item = wcstruncate(arr[ i, j ] md_space_str(w), w) "  "
                r = ((j == 1) ? "  " : r "│ " ) item
            }
        }
        md_output( r, output_arr )
    }
    return 1
}

function md_handle_table_arr( line, arr, width, kp,        _a, _item, w, i, l ){
    gsub("(^[ ]*[|])|([|][ ]*$)", "", line)
    l = split(line, _a, "|")
    for (i=1; i<=l; ++i) {
        _item = md_str_trim( _a[i] )
        w = wcswidth( _item )
        if (width[i] < w) width[i] = w
        arr[ kp, i ] = _item
    }
    return arr[ kp L ] = l
}

function md_space_str(w,       s){
    if ( (s = SPACE_STR[ w ]) != "" ) return s
    return SPACE_STR[ w ] = str_rep( " ", w )
}
