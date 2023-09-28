
BEGIN{
    M = "\007"
}

# Section: pagable
function ctrl_pagable_init( o, kp ){
    # ctrl_pagable_set( row, pagerow, current )
    o[ kp, "loop" ] = false
}

function ctrl_pagable_set( o, kp, row, pagerow, current ){
    o[ kp, "row" ] = row
    o[ kp, "pagerow" ] = pagerow
    current = (current == "" ? 1 : current)
    o[ kp, "current" ] = int((current - 1) / pagerow) * pagerow + 1
}

function ctrl_pagable_loop( o, kp,      loop_mod ){
    if (loop_mod == "")  return o[ kp, "loop" ]
    o[ kp, "loop" ] = (loop_mod == true) ? true : false
}

function ctrl_pagable_next( o, kp,          _cur, _pagerow, _row ){
    _cur = o[ kp, "current" ]
    _pagerow = o[ kp, "pagerow"]
    _row = o[ kp, "row" ]

    if (_cur + _pagerow <= _row) {
        o[ kp, "current" ] = _cur + _pagerow
        return true
    }

    if (o[ kp, "loop" ]) {
        # TODO: In loop mode. should be other ways
        o[ kp, "current" ] = 1
        return true
    }
    return false
}


function ctrl_pagable_prev( o, kp,          _cur, _pagerow, _row ){
    _cur = o[ kp, "current" ]
    _pagerow = o[kp, "pagerow"]
    _row = o[ kp, "row" ]

    if (_cur - _pagerow >= 1) {
        o[ kp, "current" ] = _cur - _pagerow
        return true
    }

    if (o[ kp, "loop" ]) {
        # TODO: In loop mode. should be other ways
        o[ kp, "current" ] = int((_row - 1 )  / _pagerow) * _pagerow + 1
        return true
    }
    return false
}

# EndSection

# Section: str with cursor

# EndSection

# Section: num
function ctrl_num_init( o, kp, min, max, val ) {
    kp = kp SUBSEP "ctrl-num" SUBSEP
    o[ kp "min" ] = min
    o[ kp "max" ] = max
    if ( val == "" ) val = o[ kp "val" ]
    o[ kp "val" ] = ( val != "" ) ? val : min
}

function ctrl_num_inc( o, kp,   m, v ){
    kp = kp SUBSEP "ctrl-num" SUBSEP
    v = o[ kp "val" ]
    m = o[ kp "max" ]
    if (v < m) o[ kp "val" ] = ++v
    return v
}

function ctrl_num_dec( o, kp,  m, v ){
    kp = kp SUBSEP "ctrl-num" SUBSEP
    v = o[ kp "val" ]
    m = o[ kp "min" ]
    if (v > m) o[ kp "val" ] = --v
    return v
}

function ctrl_num_rinc( o, kp,   m, v ){
    kp = kp SUBSEP "ctrl-num" SUBSEP
    v = o[ kp "val" ]
    m = o[ kp "max" ]
    if (v < m) return o[ kp "val" ] = ++v
    return o[ kp "val" ] = o[ kp "min" ]
}

function ctrl_num_rdec( o, kp,  m, v ){
    kp = kp SUBSEP "ctrl-num" SUBSEP
    v = o[ kp "val" ]
    m = o[ kp "min" ]
    if (v > m) return o[ kp "val" ] = --v
    return o[ kp "val" ] = o[ kp "max" ]
}
# TODO: check
function ctrl_num_add( o, kp, val,      mi, ma, mr, v ){
    kp = kp SUBSEP "ctrl-num" SUBSEP
    v = o[ kp "val" ]
    ma = o[ kp "max" ]
    mi = o[ kp "min" ]
    v += val
    if (v < mi) v = mi
    else if (v > ma) v = ma
    o[ kp "val" ] = v
    return v
}

function ctrl_num_set( o, kp, val ){    return o[ kp, "ctrl-num", "val" ] = val;  }
function ctrl_num_set_max(o, kp, ma){   return o[ kp, "ctrl-num", "max" ] = ma;    }
function ctrl_num_get( o, kp ){     return o[ kp, "ctrl-num", "val" ];     }
function ctrl_num_get_max(o, kp){   return o[ kp, "ctrl-num", "max" ];     }
function ctrl_num_get_min(o, kp){   return o[ kp, "ctrl-num", "min" ];     }

# EndSection

# Section: ctrl sw
function ctrl_sw_init( o, kp, val, num ) {
    if (num <= 1) num = 1
    ctrl_num_init( o, kp SUBSEP "ctrl-sw" SUBSEP, 0, int(num), int(val))
}

function ctrl_sw_toggle( o, kp ) {
    return ctrl_num_rinc( o, kp SUBSEP "ctrl-sw" SUBSEP )
}

function ctrl_sw_get( o, kp ) {
    return ctrl_num_get( o, kp SUBSEP "ctrl-sw" SUBSEP )
}

function ctrl_sw_set( o, kp, v ) {
    return ctrl_num_set( o, kp SUBSEP "ctrl-sw" SUBSEP, v )
}

# EndSection

# Section: ctrl numstr
function ctrl_numstr_init( o, kp, min, max ) {
    o[ kp "val" ] = min
    o[ kp "min" ] = min
    o[ kp "max" ] = max
}

function ctrl_numstr_inc( o, kp,             m ){
    v = o[ kp "val" ]
    m = o[ kp "max" ]
    if (v < m) {
        v += 1
    } else {
        v = o[ kp "min" ]
    }
    o[ kp "val" ] = v
    return v
}


# BEGIN{
#     ctrl_numstr_init(a, 3, 10)
#     print ctrl_numstr_add(a, 12)
#     print ctrl_numstr_add(a, -12)
#     print ctrl_numstr_add(a, -3)
#     print ctrl_numstr_add(a, +3)
# }


function ctrl_numstr_add( o, kp, val,     mi, ma, mr, v ){
    v = ctrl_numstr_get( o, kp )
    ma = o[ kp "max" ]
    mi = o[ kp "min" ]
    v += val - mi
    mr = ma - mi + 1
    v = v % mr
    if (v < 0) v = v + mr
    v += mi
    o[ kp "val" ] = v
    return v
}

function ctrl_numstr_dec( o, kp,           m, v ){
    v = ctrl_numstr_get( o, kp )
    m = o[ kp "min" ]
    if (v > m) {
        v -= 1
    } else {
        v = o[ kp "max" ]
    }
    o[ kp "val" ] = v
    return v
}

function ctrl_numstr_get( o, kp ){
    # if (( o[ "val" ] == "" )       o[ "val" ] = o[ "min" ]
    return o[ kp "val" ]
}

function ctrl_numstr_set( o, kp, val ){
    o[ kp "val" ] = val
}

function ctrl_numstr_addchar( o, kp, val ) {
    v = o[ kp "val" ] val
    if ( ( int(v) >= int(o[ kp "min" ]) ) && ( int(v) <= int(o[ kp "max" ] )) ) {
        ctrl_numstr_set( o,  v )
    }
}

function ctrl_numstr_delchar( o, kp ) {
    v = o[ kp "val" ]
    ctrl_numstr_set( o, substr(v, 1, length(v) - 1), kp )
}

function ctrl_numstr_handle_char( o, kp, char_type, char_value ) {
    if (char_type == "ascii-delete") {
        ctrl_numstr_delchar( o, kp )
    } else if (index("0123456789", char_value) > 0) {
        ctrl_numstr_addchar( o, char_value, kp )
    } else {
        return false
    }
    return true
}

# EndSection

# Section: ctrl windows movement old

function ctrl_win_init(  o, kp, min, max, size,         _val ){
    kp = kp SUBSEP "ctrl-win" SUBSEP

    o[ kp "min" ]    = min
    o[ kp "size" ]   = size = ( size != "" ) ? size : min
    o[ kp "max" ]    = ( max != "" ) ? max : size
    o[ kp "off" ]    = min

    _val = o[ kp "val" ]
    if (_val == "") {
        o[ kp "val" ]    = min
    } else {
        o[ kp "off" ]    = int((_val-1)/size)*size + 1
    }
}

function ctrl_win_inc( o, kp,  _val, _max, _off, _size ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP

    _val = o[ kp "val" ]
    _max = o[ kp "max" ]
    _off = o[ kp "off" ]
    _size = o[ kp "size" ]
    _val += 1
    if (_val > _max)                    _val = _max
    if (_val >= _off+_size)             o[ kp "off" ] = _off + _size
    o[ kp "val" ] = _val
    return _val
}

function ctrl_win_dec( o, kp,  _val, _min, _off, _size ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP

    _val = o[ kp "val" ]
    _min = o[ kp "min" ]
    _off = o[ kp "off" ]
    _size = o[ kp "size" ]
    _val -= 1
    if (_val < _min)             _val = _min
    if (_val < _off)             o[ kp "off" ] = _off - _size
    o[ kp "val" ] = _val
    return _val
}

function ctrl_win_rinc( o, kp,  _val, _max, _min, _off, _size ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP

    _val = o[ kp "val" ]
    _min = o[ kp "min" ]
    _max = o[ kp "max" ]
    _off = o[ kp "off" ]
    _size = o[ kp "size" ]
    _val += 1
    if (_val > _max) {
        _val = _min
        if (_val < _off)  o[ kp "off" ] = _min
    }
    else if (_val >= _off+_size)             o[ kp "off" ] = _off + _size
    o[ kp "val" ] = _val
    return _val
}

function ctrl_win_rdec( o, kp,  _val, _min, _max, _off, _size ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP

    _val = o[ kp "val" ]
    _min = o[ kp "min" ]
    _max = o[ kp "max" ]
    _off = o[ kp "off" ]
    _size = o[ kp "size" ]
    _val -= 1
    if (_val < _min) {
        _val = _max
        if (_val >= _off+_size)  o[ kp "off" ] = _max - _size + 1
    }
    if (_val < _off)        o[ kp "off" ] = ((_off = _off - _size) >= _min) ? _off : _min
    o[ kp "val" ] = _val
    return _val
}

function ctrl_win_val( o, kp ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return o[ kp "val" ]
}

function ctrl_win_begin( o, kp ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return o[ kp "off" ]
}

function ctrl_win_end( o, kp,       v, max ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    v = o[ kp "off" ] + o[ kp "size" ] - 1
    max = o[ kp "max" ]
    if (v > max) v = max
    return v
}

function ctrl_win_set( o, kp, val,      size ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    o[ kp "val" ] = val
    size = o[ kp "size" ]
    o[ kp "off" ] = int( ( val - 1 ) / size ) * size + 1
}

function ctrl_win_max_set( o, kp, max){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    o[ kp "max"]  = max
}

function ctrl_win_size_set( o, kp, size){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    o[ kp "size"] = size
}

function ctrl_win_size_get( o, kp ){    return o[ kp, "ctrl-win", "size" ];  }
function ctrl_win_max_get( o, kp ){     return o[ kp, "ctrl-win", "max" ];  }

function ctrl_win_next( o, kp,          _val, _max, _off, _size ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    _val = o[ kp "val" ]
    _max = o[ kp "max" ]
    _off = o[ kp "off" ]
    _size = o[ kp "size" ]

    if (_val + _size <= _max){
        o[ kp "val" ] = _val + _size
        o[ kp "off" ] = _off + _size
        return true
    }
}

function ctrl_win_prev( o, kp,          _val, _off, _size ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    _val = o[ kp "val" ]
    _off = o[ kp "off" ]
    _size = o[ kp "size" ]

    if (_val - _size >= 1){
        o[ kp "val" ] = _val - _size
        _off = _off - _size
        o[ kp "off" ] = (_off >= 1) ? _off : 1
        return true
    }
}


# EndSection

# Section: ctrl windows movement

function ctrl_page_init(  o, kp, min, max, val, pagesize, rowsize ){
    kp = kp SUBSEP "ctrl-win" SUBSEP

    min = ( min != "" ) ? min : 1
    o[ kp "pagesize" ] = ( pagesize != "" ) ? pagesize : min
    o[ kp "rowsize" ]  = ( rowsize != "" ) ? rowsize : pagesize

    ctrl_num_init( o, kp, min, max, val )
}

function ctrl_page_set( o, kp, val ){
    kp =  kp SUBSEP "ctrl-win" SUBSEP
    return ctrl_num_set( o, kp, val )
}

function ctrl_page_pagesize_set( o, kp, pagesize ){ o[ kp, "ctrl-win", "pagesize" ] = pagesize ; }
function ctrl_page_rowsize_set( o, kp, rowsize ){   o[ kp, "ctrl-win", "rowsize" ] = rowsize; }
function ctrl_page_pagesize_get( o, kp ){   return o[ kp, "ctrl-win", "pagesize" ];     }
function ctrl_page_rowsize_get( o, kp ){   return o[ kp, "ctrl-win", "rowsize" ];     }

function ctrl_page_max_get( o, kp ){   return ctrl_num_get_max( o, kp SUBSEP "ctrl-win" SUBSEP );   }

function ctrl_page_max_set( o, kp, v ){
    return ctrl_num_set_max(o, kp SUBSEP "ctrl-win" SUBSEP, v)
}

function ctrl_page_inc( o, kp ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return ctrl_num_inc( o, kp )
}

function ctrl_page_dec( o, kp ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return ctrl_num_dec( o, kp )
}

function ctrl_page_rinc( o, kp ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return ctrl_num_rinc( o, kp )
}

function ctrl_page_rdec( o, kp ) {
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return ctrl_num_rdec( o, kp )
}

function ctrl_page_val( o, kp ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    return ctrl_num_get( o, kp )
}

function ctrl_page_begin( o, kp,           v, s ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    v = ctrl_num_get( o, kp )
    s = o[ kp "pagesize" ]
    return ( int((v-1) / s) * s ) + 1
}

function ctrl_page_end( o, kp,           v, max ){
    v = ctrl_page_begin( o, kp )
    kp = kp SUBSEP "ctrl-win" SUBSEP
    v = v + o[ kp "pagesize" ] - 1
    max = ctrl_num_get_max(o, kp)
    if (v > max) v = max
    return v
}

function ctrl_page_next_page( o, kp,        s ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    s = o[ kp "pagesize" ]
    return ctrl_num_add(o, kp, s)
}

function ctrl_page_prev_page( o, kp,        s ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    s = o[ kp "pagesize" ]
    return ctrl_num_add(o, kp, -s)
}

function ctrl_page_next_col( o, kp,        s ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    s = o[ kp "rowsize" ]
    return ctrl_num_add(o, kp, s)
}

function ctrl_page_prev_col( o, kp,        s ){
    kp = kp SUBSEP "ctrl-win" SUBSEP
    s = o[ kp "rowsize" ]
    return ctrl_num_add(o, kp, -s)
}

# EndSection

# Section: stredit
function ctrl_stredit_init( o, kp, val, w,          i, l){
    o[ kp, "stredit-ctrl" ] = ""
    o[ kp, "stredit-ctrl", "value" ] = val
    o[ kp, "stredit-ctrl", "cursor-point" ] = i = length(val)

    o[ kp, "stredit-ctrl", "width" ] = w = ((w>0) ? w : int(o[ kp, "stredit-ctrl", "width" ]))
    if (( l=wcswidth_cache( val)-w+1 ) > 0) o[ kp, "stredit-ctrl", "start-point" ] = length( wcstruncate_cache( val, l ) )
    else o[ kp, "stredit-ctrl", "start-point" ] = 0
}
function ctrl_stredit_width_set( o, kp, w ){ o[ kp, "stredit-ctrl", "width" ] = w;     }
function ctrl_stredit_width_get( o, kp ){ return o[ kp, "stredit-ctrl", "width" ];     }

function ctrl_stredit_cursor_forward( o, kp,        i, e, l, b, w ){
    i = o[ kp, "stredit-ctrl", "cursor-point" ]
    e = substr( s = ctrl_stredit_value(o, kp), i + 1 )
    if (e == "") return false
    l = wcwidth_first_char_cache(e)
    o[ kp, "stredit-ctrl", "cursor-point" ] = (i = i + l)
    b = o[ kp, "stredit-ctrl", "start-point" ]
    w = o[ kp, "stredit-ctrl", "width" ]

    if ( ( l = wcswidth_cache( v = substr( s, b+1, i-b ) ) - w + 1  ) > 0 )
         o[ kp, "stredit-ctrl", "start-point" ] = b + length( wcstruncate_cache( v, l ) )
}

function ctrl_stredit_cursor_backward( o, kp,       i, l, e ){
    i = o[ kp, "stredit-ctrl", "cursor-point" ]
    if (i<=0) return false
    l = wcswidth_cache(  e = substr( ctrl_stredit_value(o, kp), 1, i ) )
    o[ kp, "stredit-ctrl", "cursor-point" ] = (i = length( wcstruncate_cache(  e, l-1 ) ))

    if ( o[ kp, "stredit-ctrl", "start-point" ] > i )
        o[ kp, "stredit-ctrl", "start-point" ] = i
}

function ctrl_stredit_start_pos(o, kp){
    return o[ kp, "stredit-ctrl", "start-point" ]
}

function ctrl_stredit_cursor_pos(o, kp){
    return o[ kp, "stredit-ctrl", "cursor-point" ]
}

# function ctrl_stredit_cursor_insert( o, kp, e ){
#     v = ctrl_stredit_value(o, kp)
#     p = ctrl_stredit_cursor_pos(o, kp)
#     o[ kp, "stredit-ctrl", "value" ] = substr(v, 1, p-1) e substr(v, p)
# }

function ctrl_stredit_value( o, kp ){
    return o[ kp, "stredit-ctrl", "value" ]
}

function ctrl_stredit_value_add(o, kp, val,     v, i, b, w, l, s){
    v = ctrl_stredit_value(o, kp)
    i = ctrl_stredit_cursor_pos(o, kp)
    o[ kp, "stredit-ctrl", "value" ] = (v =substr(v, 1, i) val substr(v, i+1))
    o[ kp, "stredit-ctrl", "cursor-point" ] = (i = i + length(val))
    b = o[ kp, "stredit-ctrl", "start-point" ]
    w = o[ kp, "stredit-ctrl", "width" ]

    if ((l = wcswidth_cache( s = substr( v, b+1, i-b )) - w + 1) > 0 )
        o[ kp, "stredit-ctrl", "start-point" ] = b + length( wcstruncate_cache( s, l ) )

}

function ctrl_stredit_value_del(o, kp,      v, p, l){
    v = ctrl_stredit_value(o, kp)
    l = ctrl_stredit_cursor_pos(o, kp)
    ctrl_stredit_cursor_backward(o, kp)
    p = ctrl_stredit_cursor_pos(o, kp)
    o[ kp, "stredit-ctrl", "value" ] = substr(v, 1, p) substr(v, l+1)
}

# EndSection
