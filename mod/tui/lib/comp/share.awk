BEGIN{
    IS_TH_NO_COLOR = ENVIRON[ "NO_COLOR" ]
    if (IS_TH_NO_COLOR != 1) {
        IS_TH_CUSTOM            = ENVIRON[ "___X_CMD_TUI_IS_TH_CUSTOM" ]
        TH_THEME_COLOR          = ENVIRON[ "___X_CMD_THEME_COLOR_CODE" ]
        TH_THEME_MINOR_COLOR    = ENVIRON[ "___X_CMD_THEME_MINOR_COLOR_CODE" ]
        TH_THEME_COLOR          = (TH_THEME_COLOR) ? "\033[" TH_THEME_COLOR "m" : UI_FG_CYAN
        TH_THEME_MINOR_COLOR    = (TH_THEME_MINOR_COLOR) ? "\033[" TH_THEME_MINOR_COLOR "m" : TH_THEME_COLOR
    }

    TH_CURSOR = TH_THEME_COLOR UI_TEXT_REV UI_TEXT_BLINK
    HAS_CHANGED = SUBSEP "ISCHANGED"
    TYPE = SUBSEP "TYPE"
}

# Section: HAS_CHANGED

function change_set( o, k1, k2, k3, k4, k5, k6  ){
    o[ ks(k1, k2, k3, k4, k5, k6), "\001CHANGED" ] = 1
}

function change_unset( o, k1, k2, k3, k4, k5, k6  ){
    o[ ks(k1, k2, k3, k4, k5, k6), "\001CHANGED" ] = 0
}

function change_chainset( o, k1, k2, k3, k4, k5, k6,        kp ){
    change_set(o, kp = k1)
    if (k2 != "") change_set(o, kp = kp SUBSEP k2); else return
    if (k3 != "") change_set(o, kp = kp SUBSEP k3); else return
    if (k4 != "") change_set(o, kp = kp SUBSEP k4); else return
    if (k5 != "") change_set(o, kp = kp SUBSEP k5); else return
    if (k6 != "") change_set(o, kp = kp SUBSEP k6); else return
}

function change_chainunset( o, k1, k2, k3, k4, k5, k6,      kp ){
    change_unset(o, kp = k1)
    if (k2 != "") change_unset(o, kp = kp SUBSEP k2); else return
    if (k3 != "") change_unset(o, kp = kp SUBSEP k3); else return
    if (k4 != "") change_unset(o, kp = kp SUBSEP k4); else return
    if (k5 != "") change_unset(o, kp = kp SUBSEP k5); else return
    if (k6 != "") change_unset(o, kp = kp SUBSEP k6); else return
}

function change_is( o, k1, k2, k3, k4, k5, k6 ){
    return (o[ ks(k1, k2, k3, k4, k5, k6), "\001CHANGED" ] == 1)
}

# EndSection

# Section: space
function space_rep( size,   t ){
    if (size > 200) return str_rep( " ", size )
    if ( (t = SPACE_CACHE_ARR[ size ]) != "") return t
    return SPACE_CACHE_ARR[ size ] = str_rep( " ", size )
}

function space_screen( rows, cols, _next_line, t, r, j ){
    if ((rows == SPACE_LAST_ROWS) && (cols == SPACE_LAST_COLS) && (_next_line == SPACE_LAST_NEXTLINE)) return SPACE_LAST_RESULT
    SPACE_LAST_ROWS = rows
    SPACE_LAST_COLS = cols
    SPACE_LAST_NEXTLINE = _next_line = ( _next_line != "" ) ? _next_line : "\r\n"
    r = t = space_rep(cols)
    for (j=2; j<=rows; ++j) r = r _next_line t
    return SPACE_LAST_RESULT = r
}

function space_restrict_or_pad( str, l,     _strl ){
    if (l <= (_strl = length(str)))     return substr(str, 1, l)
    else                                return str space_rep( l - _strl )
}

function space_restrict_or_pad_utf8( str, l,     _strl, s ){
    if (str == (s = wcstruncate_cache( str, l)))     return s space_rep( l - wcswidth_cache( s ) )
    else return s
}

function space_restrict_or_pad_utf8_esc( str, l,    s, _ ){
    if ( (s = CACHEUTF8[ "utf8-cache", "space_restrict_or_pad_utf8_esc", str, l ]) != "" ) return s
    utf8tt_init(str, _, "")
    utf8tt_refresh(_, "", 1, l)
    return CACHEUTF8[ "utf8-cache", "space_restrict_or_pad_utf8_esc", str, l ] = _[ SUBSEP "VIEW", 1 ]
}

# EndSection

# Section: multiline utf8 text

function ml_to_arr( str, col, arr,       a, l, i, k, e, el, _e1, _e1l ){
    l = split(str, a, "\r?\n")
    for (i=1; i<=l; ++i)
        for (el = length( e = a[i] ); el>0; el = length( e = substr(e, _e1l+1) ))
            if ( col > (_e1l = (length( _e1 = arr[ ++k ] = wcstruncate_cache( e, col) )) ) )  break
    return arr[ L ] = k
}

function ml_to_arr_jascii( str, col, arr,       v, a, l, i, k, e, el ){
    l = split(v, a, "\r?\n")
    for (i=1; i<=l; ++i) {
        for (el = length( e = a[i] ); el > column; e = substr(e, col+1))
            arr[ ++k ] = substr(e, 1, col)
        arr[ ++k ] = e
    }
    return arr[ L ] = k
}


# EndSection

# Section: utf8text

function utf8text_init( str, o, kp,     a, i, l ){
    o[ kp L ] = ((l = split(str, a, "\r?\n")) ? l : 1)
    for (i=1; i<=l; ++i) o[ kp, i ] = a[i]
}

function utf8text_len( o, kp, i ){
    return o[ kp, i L ]
}

function utf8text_refresh( o, kp, col ){
    if (o[kp, "LAST_COL"] == col) return
    o[kp, "LAST_COL"] = col
    utf8text_to_arr( o, kp, col, o, kp, "COL" )
}

function utf8text_to_arr( o, kp , col, arr, arrkp,      l, i, k, e, el, _e1, _e1l, _linel ){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        _linel = 0
        for (el = length( e = o[kp, i] ); el>0; el = length( e = substr(e, _e1l+1) )) {
            _linel += el
            if ( col > (_e1l = (length( _e1 = arr[ arrkp, ++k ] = wcstruncate_cache( e, col) )) ) )  break
        }
        o[ kp, i L ] = _linel
    }
    return arr[ arrkp L ] = k
}

# EndSection

# Section: utf8tt

BEGIN{
    TERMINAL_ESCAPE033 = "\033\\[([0-9]+;)*([0-9]+)?(m|dh|A|B|C|D)"
    TERMINAL_ESCAPE033_LIST = "(" TERMINAL_ESCAPE033 ")+"
}

function utf8tt_init( str, o, kp,     a, i, l, k, e ){
    change_set(o, kp, "utf8")
    o[ kp L ] = l = ((l = split(str, a, "\r?\n")) ? l : 1)
    for (i=1; i<=l; ++i) {
        e = a[ i ]
        k = 0
        while (match( e, TERMINAL_ESCAPE033_LIST)) {
            o[ kp, i, ++k ] = substr(e, 1, RSTART-1)
            o[ kp, i, k, "SEP" ] = substr(e, RSTART, RLENGTH)
            e = substr(e, RSTART+RLENGTH)
        }
        o[ kp, i, ++k ] = e; o[ kp, i, k, "SEP" ] = ""
        o[ kp, i L ] = k
    }
}

function utf8tt_len( o, kp, i ){
    return o[ kp, i L ]
}

function utf8tt_refresh( o, kp, row, col ){
    if ( ( ! change_is(o, kp, "utf8") ) && ( o[kp, "LAST_COL"] == col ) ) return
    change_unset(o, kp, "utf8")
    o[kp, "LAST_COL"] = col
    o[kp, "LAST_ROW"] = row
    utf8tt_to_arr( o, kp, col, o, kp SUBSEP "VIEW" )
}

function utf8tt_to_arr( o, kp, col, arr, arrkp,      _null, a, l, _l, i, j, k, e, el, _e1, _rest, _restl, _sep ){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        _l = o[ kp, i L ]
        _rest = ""
        _restl = 0
        _null = 1
        for (j=1; j<=_l; ++j) {
            e = o[ kp, i, j ]
            if (length(e) == 0) _rest = _rest (_sep = o[ kp, i, j, "SEP"])
            while (length(e) != 0) {
                _e1 = wcstruncate_cache( e, col - _restl )
                _rest = _rest _e1
                _restl = _restl + wcswidth_cache( _e1 )
                if (_e1 == e) {
                    _rest = _sep _rest (_sep = o[ kp, i, j, "SEP"])
                    if (_restl == col) {
                        _null = 0
                        arr[ arrkp, ++k ] = _rest
                        _rest = ""
                        _restl = 0
                    }
                    e = ""
                } else {
                    if (_restl == col-1) _rest = _rest " "
                    arr[ arrkp, ++k ] = _sep _rest
                    _rest = ""
                    _restl = 0
                    e = substr(e, length(_e1)+1)
                }
            }
        }
        if ( _null == 1 ) arr[ arrkp, ++k ] = _rest str_rep( " ", col - _restl )
    }
    return arr[ arrkp L ] = k
}

# EndSection

# Section: exit detect
function exit_with_elegant(command){
    FINALCMD = command
    exit(0)
}

function exit_is_with_cmd(){
    return (FINALCMD == "") ? false : true
}
# EndSection

# Section: cache utf-8 width calculation

function wcswidth_cache(v,       w){
    if ( (w = CACHEUTF8[ "utf8-cache-wcswidth", v ]) != "" ) return w
    return CACHEUTF8[ "utf8-cache-wcswidth", v ] = wcswidth(v)
}

function wcstruncate_cache(v, l,     s){
    if ( (s = CACHEUTF8[ "utf8-cache-wcstruncate", v, l ]) != "" ) return s
    return CACHEUTF8[ "utf8-cache-wcstruncate", v, l ] = wcstruncate(v, l)
}

# EndSection
