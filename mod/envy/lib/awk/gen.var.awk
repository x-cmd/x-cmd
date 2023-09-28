{ if ($0 != "") jiparse_after_tokenize(o, $0); }
END{
    a_value(o, SUBSEP "\"1\"")
    l = ENV[L]
    for (i=1; i<=l; ++i){
        kp = ENV[ i ]
        name = gen_varname_ofkp(kp)
        val = ENV[ kp ]
        print var_set( name, val )
    }
}

function gen_varname_ofkp(kp,        p_kp, l, i, _res, a){
    p_kp = SUBSEP "\"1\"" SUBSEP
    kp = substr( kp, length(p_kp) + 1 )
    l = split(kp, a, SUBSEP)
    for (i=1; i<=l; ++i) _res = _res "_" juq(a[i])
    return _res
}

function a_value(o, kp,         v){
    v = o[ kp ]
    if (v == "{")   return a_dict(o, kp)
    if (v == "[")   return a_list(o, kp)
    arr_push( ENV, kp )
    if (v ~ "^\"") v = juq(v)
    ENV[ kp ] = v
}

function a_dict(o, kp,          i, l, k){
    l = o[ kp L ]
    for (i=1; i<=l; ++i){
        k = o[ kp, i ]
        a_value(o, kp SUBSEP k)
    }
}

function a_list(o, kp,          i, l, p, v, s, type){
    l = o[ kp L ]
    type = "# x-cmd env line"
    for (i=1; i<=l; ++i){
        p = kp SUBSEP "\""i"\""
        v = o[ p ]
        if ((v == "{") || (v == "[")) {
            type = "# x-cmd env yml"
            v = jstr(o, p)
        } #  if (v ~ "^\"") v = juq(v)
        s = s "\n" v
    }
    arr_push( ENV, kp )
    ENV[ kp ] = type s
}

