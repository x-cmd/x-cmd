BEGIN{
    CONSUMER_ITEM_STREAM = "\001"
    CONSUMER_ITEM_COL = 0
    KSEP = "\001"
    INDENT = "   "
}

function view_header(       i, _data){
    for (i=1; i<=data_col_num; ++i) {
        _data = _data sprintf( "%s%s", str_pad_right( data_header_arr[ i ], col_max[ i ], data_header_arr_wlen[ 1 KSEP i ] ), INDENT )
    }
    return _data "\n"
}

function view_body(             i, j, _data){
    _data = view_header()
    for (i=1; i<=data_len; ++i) {
        for (j=1; j <= data_col_num; ++j) _data = _data sprintf( "%s%s", str_pad_right( data[ i KSEP j ], col_max[ j ], data_wlen[ i KSEP j ] ), INDENT )
        _data = _data "\n"
    }
    return _data
}

function consume_item_push(                 l ){
    CONSUMER_ITEM_COL += 1
    l = wcswidth( CONSUMER_ITEM_STREAM )
    data_line[ data_len ] = ( data_line[ data_len ] == "" ) ? CONSUMER_ITEM_STREAM :data_line[ data_len ] "\003" CONSUMER_ITEM_STREAM

    data[ data_len KSEP CONSUMER_ITEM_COL ] = CONSUMER_ITEM_STREAM
    data_wlen [ data_len KSEP CONSUMER_ITEM_COL ] = l

    if (col_max[ CONSUMER_ITEM_COL ] < l) col_max[ CONSUMER_ITEM_COL ] = l

    CONSUMER_ITEM_STREAM = "\001"
}

function consumer_item() {
    if ($0 == "\003\002\005") {
        data_len -= 1
        print view_body()
        exit 0
    } else if ($0 == "\002") {
        CONSUMER_ITEM_COL = 0
        data_len += 1
    } else if ($0 == "\003") {
        consume_item_push()
    } else {
        CONSUMER_ITEM_STREAM = ( CONSUMER_ITEM_STREAM == "\001" ) ? $0 : CONSUMER_ITEM_STREAM "\n" $0
    }
}

function consume_header(){
    data_col_num = split($0, data_header_arr, "\t")
    for (i=1; i<=data_col_num; i++) {
        elem = str_trim(data_header_arr[i])
        elem_wlen = wcswidth( elem )
        col_max[ i ] = data_header_arr_wlen [ i ] = elem_wlen
    }
    data_len = 1
}

NR==1 {     update_width_height( $2, $3 );      }
NR==2 {     consume_header();                   }
NR>2 {      consumer_item();                    }
