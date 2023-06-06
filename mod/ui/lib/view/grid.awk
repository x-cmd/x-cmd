BEGIN{
    VIEW_GRID_COL = "\006"
    VIEW_GRID_ROW = "\007"
}


function view_grid_col( obj, col ){
    if (col == "") return obj[ VIEW_GRID_COL L ]
    obj[ VIEW_GRID_COL L ] = col
}

function view_grid_row( obj, row ){
    if (row == "") return obj[ VIEW_GRID_ROW L ]
    obj[ VIEW_GRID_ROW L ] = row
}

function view_grid_generate_buffer( obj,  _buf, _row, _col, _bufarr, _sep ){

    _buf = ""
    _col = obj[ VIEW_GRID_COL ]
    _row = obj[ VIEW_GRID_ROW ]

    for (j=1; j<=_row; ++j) _bufarr[j] = _sep

    for (i=1; i<=_col; ++i) {
        for (j=1; j<=_row; ++j) {
            _buf = _buffer[ j, i ]
            if (i>1) _buf = _buf "\r" "\033["  "C" _sep # GO TO POSITION
        }
    }

    return _buf
}


