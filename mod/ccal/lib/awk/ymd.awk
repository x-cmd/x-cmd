

function ymd_parse( o, kp,  str,   a ){
    split(str, a, "[-/]")
    ymd_new( o, kp,     a[1], a[2], a[3] )
}

function ymd_new( o, kp,  y, m, d ){
    o[ kp, 1 ] = int(y)
    o[ kp, 2 ] = int(m)
    o[ kp, 3 ] = int(d)

    o[ kp, 4 ] = int(y) SUBSEP int(m) SUBSEP int(d)
}

function ymd_kp( o, kp ){
    return o[ kp, 4 ]
}

function ymd_kp_ym( o, kp ){
    return o[ kp, 1 ] SUBSEP o[ kp, 2 ]
}

function ymd_y( o, kp ){
    return o[ kp, 1 ]
}

function ymd_m( o, kp ){
    return o[ kp, 2 ]
}

function ymd_d( o, kp ){
    return o[ kp, 3 ]
}

function ymd_tostr( o, kp ){
    return o[ kp, 1 ] "-" o[ kp, 2 ] "-" o[ kp, 3 ]
}

function ymd_eq( o, kp,     b, kp2 ){
    return ymd_eqymd( o, kp, b[kp2, 1], b[kp2, 2], b[kp2, 3] )
}

function ymd_eqymd( o, kp, y, m, d ){
    return ( (o[kp, 1] == y) && (o[kp, 2] == m) && (o[kp, 3] == d))
}

function ymd_eqym( o, kp, y, m ){
    return ( (o[kp, 1] == y) && (o[kp, 2] == m) )
}

function ymd_is_same_month( o, kp, o1, kp1 ){
    return ymd_eqym( o, kp,  o1[kp1, 1], o1[kp1, 2] )
}
