
function comp_probar_init( o, kp ) {
    o[ kp ] = ""
    o[ kp, "TYPE" ] = "probar"
}

function comp_probar_handle( o, kp, char_value, char_name, char_type,       d ) {}

# performace problem
function comp_probar_paint( o, kp, x1, y1, y2,       _title, _pctg, _tl, _col, _spacel, _str1, _str2 ){
    o[ kp, "ISCHANGED" ] = false

    _title = comp_probar_title_get( o, kp )
    _pctg = comp_probar_pctg_get( o, kp )

    _tl = wcswidth( _title )
    _col = y2 - y1 + 1
    _spacel = _col - _tl - 3  # Make sure _col < _tl
    if (_spacel < 0) panic( sprintf("Please make sure _col > _tl + 3: %s %s", "_col=" _col, "_tl=" _tl) )

    _str = _title space_rep( _spacel ) sprintf("%2d", _pctg) "%"
    _str1 = wcstruncate(_str, _pctg * _col / 100 )
    _str2 = substr(_str, length(_str1) + 1)

    return painter_goto_rel(x1, y1) "\033[41m" _str1 "\033[47m" _str2 "\033[0m"
}

function comp_probar_title_set( o, kp, title ){
    o[ kp, "ISCHANGED" ] = true
    o[ kp , "title" ] = title
}

function comp_probar_title_get( o, kp, title ){
    o[ kp, "ISCHANGED" ] = true
    return o[ kp , "title" ]
}

function comp_probar_pctg_set( o, kp, pctg ){
    o[ kp, "ISCHANGED" ] = true
    o[ kp , "pctg" ] = pctg
}

function comp_probar_pctg_get( o, kp, pctg ){
    o[ kp, "ISCHANGED" ] = true
    return o[ kp , "pctg" ] = pctg
}
