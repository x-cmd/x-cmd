function k(){
    if (_k_reset == 1)  return _k
    _k_reset = 1;       return _k = juq( key )
}

function v(){
    if (_v_reset == 1)  return _v
    _v_reset = 1;       return _v = juq( $0 )
}

function o( k1, k2, k3, k4, k5, k6, k7, k8, k9 ){   return O[ kp( k1, k2, k3, k4, k5, k6, k7, k8, k9 ) ];       }
function r( k1, k2, k3, k4, k5, k6, k7, k8, k9 ){   return O[ KP S kp( k1, k2, k3, k4, k5, k6, k7, k8, k9 ) ];  }

function d( current_level, value ) {  return ( ( current_level != D ) || ( (value != "") && (value != O[D]) ) ) ? 0 : 1; }

function juq( str ){
    # if (str !~ /^".*"$/) return str         # TODO: remove in the future

    str = substr( str, 2, length(str)-2 )
    gsub( /\\\\/, "\001", str )
    gsub( /\\"/, "\"", str )
    gsub( "/\\n/", "\n", str )
    gsub( "/\\t/", "\t", str )
    gsub( "/\\v/", "\v", str )
    gsub( "/\\b/", "\b", str )
    gsub( "/\\r/", "\r", str )
    gsub( "\001", "\\", str )
    return str
}

function jqu( str ){
    # if (str ~ /^".*"$/) return str
    gsub( "\\\\", "\\\\", str )
    gsub( "\"", "\\\"", str )
    gsub( "\n", "\\n", str )
    gsub( "\t", "\\t", str )
    gsub( "\v", "\\v", str )
    gsub( "\b", "\\b", str )
    gsub( "\r", "\\r", str )
    return "\"" str "\""
}


function kp( k1, k2, k3, k4, k5, k6, k7, k8, k9,        _ret ){
    if ( k1 == "" ) return _ret;    _ret = _ret S jqu( k1 )
    if ( k2 == "" ) return _ret;    _ret = _ret S jqu( k2 )
    if ( k3 == "" ) return _ret;    _ret = _ret S jqu( k3 )
    if ( k4 == "" ) return _ret;    _ret = _ret S jqu( k4 )
    if ( k5 == "" ) return _ret;    _ret = _ret S jqu( k5 )
    if ( k6 == "" ) return _ret;    _ret = _ret S jqu( k6 )
    if ( k7 == "" ) return _ret;    _ret = _ret S jqu( k7 )
    if ( k8 == "" ) return _ret;    _ret = _ret S jqu( k8 )
    if ( k9 == "" ) return _ret;    _ret = _ret S jqu( k9 )
    return _ret
}

function kpmatch( k1, k2, k3, k4, k5, k6, k7, k8, k9 ){     return match(KP, kp( k1, k2, k3, k4, k5, k6, k7, k8, k9 ) "$" );     }
function kpglob( k1, k2, k3, k4, k5, k6, k7, k8, k9 ){      return match( KP, ___kp_glob_pattern(k1, k2, k3, k4, k5, k6, k7, k8, k9) "$" ); }

function ___kp_glob_patternitem( key ){     gsub(/\*/, "[^" S "]+", key);    return jqu(key);  }
function ___kp_glob_pattern( k1, k2, k3, k4, k5, k6, k7, k8, k9,    _ret ){
    if ( k1 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k1 )
    if ( k2 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k2 )
    if ( k3 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k3 )
    if ( k4 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k4 )
    if ( k5 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k5 )
    if ( k6 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k6 )
    if ( k7 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k7 )
    if ( k8 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k8 )
    if ( k9 == "" ) return _ret;    _ret = _ret S ___kp_glob_patternitem( k9 )
    return _ret
}

function p(kp,   i, l){
    l = O[ kp L ]
    for (i=1; i<=l; ++i) {
        if (i!=1)   print "\n"
        _p_value( O,  kp S "\"" i "\"")
    }
}

function _p_value(O, kp,     _t, _klist, i, _ret){
    _t = O[ kp ]
    if (_t == "{")           _p_dict(O, kp)
    else if (_t == "[")      _p_list(O, kp)
    else                        print _t
}

function _p_dict(O, kp,     _klist, l, i, _key){
    print "{";  l = O[ kp L ]
    for (i=1; i<=l; i++){
        if (i!=1) print ",";
        _key = O[ kp S "\""  i "\"" ]; print _key;  print ":"; _p_value( O, kp S _key )
    }
    print "}"
}

function _p_list(O, kp,     l, i, _ret){
    print "[";  l = O[ kp L ]
    for (i=1; i<=l; i++){
        if (i!=1) print ",";
        _p_value( O, kp S "\""  i "\"" )
    }
    print "]"
}
