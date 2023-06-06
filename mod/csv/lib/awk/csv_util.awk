
function csv_parse_width(arr, str, cols, sep,        i, l, w, _is_stream){
    _is_stream = 1
    l = split(str, arr, sep)
    cols = cols - (l * 3)
    for (i=1; i<=l; ++i){
        w = arr[i]
        if ( w == "-" ) {
            _is_stream = 0
            continue
        }

        if ( w ~ "^[0-9]+%$") w = int(cols * w / 100)
        arr[ i, "CUSTOM_WIDTH" ] = true
        arr[ i, "width" ] = int(w)
    }
    arr[L] = int(l)
    return _is_stream
}

