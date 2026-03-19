function cp_merge(o, obj,       l, i, kp){
    l = obj[L]
    for (i=1; i<=l; ++i){
        kp = SUBSEP jqu(i)
        cp(o, kp, obj, kp)
    }
    if (o[L] < l) o[L] = l
}

function cp(o, kp1, obj, kp2){
    if ( o[ kp1 ] == "" ) {
        o[ kp1 ] = obj[ kp2 ]
        if ( o[ kp1] == "[" ) return cp_list(o, kp1, obj, kp2)
    }
    if ( o[ kp1 ] == "{" ) return cp_dict(o, kp1, obj, kp2)
}

function cp_dict(o, kp1, obj, kp2,          l, i, k, _l){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) {
        k = obj[ kp2, i ]
        if ( o[ kp1, k ] == "") {
            o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
            o[ kp1, _l ] = k
        }
        cp(o, kp1 SUBSEP k, obj, kp2 SUBSEP k)
    }
}

function cp_list(o, kp1, obj, kp2,          l, i) {
    o[ kp1 L ] = l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) cp(o, kp1 SUBSEP "\"" i "\"", obj, kp2 SUBSEP "\"" i "\"")
}

function cp_cover_merge(o, obj,       l, i, kp){
    l = obj[L]
    for (i=1; i<=l; ++i){
        kp = SUBSEP jqu(i)
        cp_cover(o, kp, obj, kp)
    }
    if (o[L] < l) o[L] = l
}

function cp_cover(o, kp1, obj, kp2){
    o[ kp1 ] = obj[ kp2 ]
    if ( o[ kp1] == "[" )  return cp_list_cover(o, kp1, obj, kp2)
    if ( o[ kp1 ] == "{" ) return cp_dict_cover(o, kp1, obj, kp2)
}

function cp_dict_cover(o, kp1, obj, kp2,          l, i, k, _l){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) {
        k = obj[ kp2, i ]
        if ( o[ kp1, k ] == "") {
            o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
            o[ kp1, _l ] = k
        }
        cp_cover(o, kp1 SUBSEP k, obj, kp2 SUBSEP k)
    }
}

function cp_list_cover(o, kp1, obj, kp2,          l1, l2, i) {
    l1 = o[ kp1 L ]
    l2 = obj[ kp2 L ]
    for (i=1; i<=l2; ++i) cp_cover(o, kp1 SUBSEP "\"" int(i+l1) "\"", obj, kp2 SUBSEP "\"" i "\"")
    o[ kp1 L ] = int(l1 + l2)
}

# Section: jmerge
# llm
function jmerge_force(o, obj,       l, i, kp){
    l = obj[L]
    for (i=1; i<=l; ++i){
        kp = SUBSEP jqu(i)
        jmerge_force___value(o, kp, obj, kp)
    }
    if (o[L] < l) o[L] = l
}

function jmerge_force___value(o, kp1, obj, kp2){
    o[ kp1 ] = obj[ kp2 ]
    if ( o[ kp1] == "[" )  return jmerge_force___list(o, kp1, obj, kp2)
    if ( o[ kp1 ] == "{" ) return jmerge_force___dict(o, kp1, obj, kp2)
}

function jmerge_force___dict(o, kp1, obj, kp2,          l, i, k, _l){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) {
        k = obj[ kp2, i ]
        if ( o[ kp1, k ] == "") {
            o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
            o[ kp1, _l ] = k
        }
        jmerge_force___value(o, kp1 SUBSEP k, obj, kp2 SUBSEP k)
    }
}

function jmerge_force___list(o, kp1, obj, kp2,          l, i) {
    l = obj[ kp2 L ]
    if (l <= 0) return
    o[ kp1 L ] = l
    for (i=1; i<=l; ++i) jmerge_force___value(o, kp1 SUBSEP "\"" i "\"", obj, kp2 SUBSEP "\"" i "\"")
}

# advise llm.minion
function jmerge_soft(o, obj,       l, i, kp){
    l = obj[L]
    for (i=1; i<=l; ++i){
        kp = SUBSEP jqu(i)
        jmerge_soft___value(o, kp, obj, kp)
    }
    if (o[L] < l) o[L] = l
}

function jmerge_soft___value(o, kp1, obj, kp2){
    o[ kp1 ] = obj[ kp2 ]
    if ( o[ kp1] == "[" )  return jmerge_soft___list(o, kp1, obj, kp2)
    if ( o[ kp1 ] == "{" ) return jmerge_soft___dict(o, kp1, obj, kp2)
}

function jmerge_soft___dict(o, kp1, obj, kp2,          l, i, k, _l){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) {
        k = obj[ kp2, i ]
        if ( o[ kp1, k ] == "") {
            o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
            o[ kp1, _l ] = k
        }
        jmerge_soft___value(o, kp1 SUBSEP k, obj, kp2 SUBSEP k)
    }
}

function jmerge_soft___list(o, kp1, obj, kp2,          l1, l2, i) {
    l1 = o[ kp1 L ]
    l2 = obj[ kp2 L ]
    for (i=1; i<=l2; ++i) jmerge_soft___value(o, kp1 SUBSEP "\"" int(i+l1) "\"", obj, kp2 SUBSEP "\"" i "\"")
    o[ kp1 L ] = int(l1 + l2)
}

function jmerge_copy(o, obj,            i){
    delete o
    for ( i in obj ) o[i] = obj[i]
}

# EndSection
