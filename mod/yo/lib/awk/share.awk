
# 1/abc/cde/aad
function normalize_kp( kp,      _rooti, i, e, _sep, _tmp, _tmpl ) {
    _rooti = 0
    if (kp ~ "^" RE_DIGITS) {
        _rooti = kp
        gsub("^" RE_DIGITS, "", kp)
        _rooti = substr(_rooti, 1, length(_rooti) - length(kp))       # This is a number
    }

    _rooti = S "\"" _rooti "\""

    _sep = substr(kp, 1, 1)
    _tmpl = split( kp, _tmp, _sep )        # Make sure the _sep is not some special characters
    for (i=2; i<=_tmpl; ++i) {
        e = _tmp[ i ]
        _rooti = _rooti S jqu( e )
    }

    return _rooti
}

function set_obj_data_structure_of_keypath(o, key, kp,        arr, _kp, i, j, l, _l, _has) {
    l = split( key, arr, S)
    for (i=2; i<=l; ++i){
        _has = 0
        _kp = arr[i]
        if (_kp ~ "^\""RE_DIGITS"\"$") {
            j = int(juq(_kp))
            if (o[ kp L ] < j) o[ kp L ] = j
            o[ kp ] = "["
            kp = kp S _kp
        } else {
            _l = o[ kp L ]
            for (j=1; j<=_l; ++j) if (o[ kp, j ] == _kp) _has = 1
            if (_has != 1 ) {
                o[ kp ] = "{"
                o[ kp L ] = j
                o[ kp, j ] = _kp
            }
            kp = kp S _kp
        }
    }
}
