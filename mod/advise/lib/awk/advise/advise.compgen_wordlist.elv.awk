function comp_advise_str_style_elv( v, d, sep,      _res ){
    if ( v == "" ) return
    if ((d != "") && ( ADVISE_WITHOUT_DESC != 1 )) {
        if (NO_COLOR == 1 ) _res = qu1(sprintf("%-"MAX_W"s", v) " -- (" d ")")
        else                _res = "( styled "qu1(sprintf("%-"MAX_W"s", v))" cyan )" qu1("  -- " d)
    } else {
        if (NO_COLOR == 1 ) _res = qu1(v)
        else                _res = "( styled "qu1(v)" green )"
    }
    _res = sprintf("edit:complex-candidate %s &display=%s &code-suffix=%s", qu1(v), _res, qu1(sep))
    return _res
}

BEGIN{
    NO_COLOR = ENVIRON[ "NO_COLOR" ]
}

( arr[ $1 ] != 1 ){
    end_sep = $1
    v = candidate_prefix $2
    d = $3
    if (( v == "" ) || ( arr[ v ] == 1 ) || ((current != "") && index(v, current) <= 0)) next

    NUM ++
    w = length(v)
    arr[ NUM, "VAL" ] = v
    arr[ NUM, "DESC" ] = d
    arr[ NUM, "END_SEP" ] = end_sep

    if (MAX_W < w) MAX_W = w
    if ( NUM >= maxitem ) exit(0)
}

END{
    for (i=1; i<=NUM; ++i){
        print comp_advise_str_style_elv( arr[i, "VAL"], arr[i, "DESC"], arr[i, "END_SEP"] )
    }
}
