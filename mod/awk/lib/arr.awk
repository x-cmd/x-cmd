BEGIN {
    NULL = "\001"
}

function arr_len(arr, kp,   l){
    return int(arr[ kp L ] + 0)
}

function arr_seq( arr, s, delta, e,        i, c ){
    for (i=0; s<=e; s+=delta) arr[++i] = s
    arr[ L ] = i
    return i
}

function arr_eq( a1, a2,            i, l ){
    if ((l = arr_len(a1)) != arr_len(a2))       return false
    for (i=1; i<=l; i++) if (a1[i] != a2[i])    return false
    return true
}

function arr_get( a, i ){
    return a[i]
}

# arr[ ++arr[ L ] ] = elem
function arr_push(arr, elem,        l){
    arr[ L ] = l = arr[ L ] + 1
    arr[ l ] = elem
    return l
}

# arr[ arr[ L ] -- ]
function arr_pop(arr,   l){
    if ((l = arr[ L ]) < 1)     return NULL
    arr[ L ] = l - 1
    return arr[ l ]
}

# arr[ arr[ L ] ]
function arr_top(arr,   l) {
    if ((l = arr[ L ]) < 1)     return NULL
    return arr[ l ]
}

function arr_join(arr,              _sep, _start, l,              _i, _result) {
    if (_sep == "")             _sep = "\n"
    if (_start == "")           _start = 1
    if (l == "")                l = arr[ L ]

    if (l < 1) return ""

    _result = arr[1]
    for (_i=2; _i<=l; ++_i)      _result = _result _sep arr[_i]
    return _result
}

# arr[ L ] = split(str, arr, sep)
function arr_cut(arr, str, sep,       l){
    l = split(str, arr, sep)
    return arr[ L ] = l
}

function arr_clone( src, dst,   l, i ){
    l = src[ L ]
    for (i=1; i<=l; ++i)  dst[i] = src[i]
    return dst[ L ] = l
}

# function arr_clone( src, dst, kp,       l, i ){
#     dst[ L ] = l = src[ kp L ]
#     for (i=1; i<=l; ++i)  dst[i] = src[ ( (kp != "") ? kp SUBSEP : kp ) i]
#     return l
# }

function arr_shift( arr, offset,        l, i ){
    l = arr[ L ] - offset
    for (i=1; i<=l; ++i) arr[i] = arr[i+offset]
    arr[ L ] = l
    return l
}

function arr_unshift( arr, v,        l, i ){
    arr[ L ] = l = arr[ L ] + 1
    for (i=l; i>=1; --i) arr[i] = arr[i-1]
    arr[1] = v
    return l
}

function arr_rev( arr,      l, i, l2, t ){
    l2 = (l = arr[ L ]) / 2
    for (i=1; i<=l2; ++i) {
        t = arr[i]
        arr[i] = arr[l-i+1]
        arr[l-i+1] = t
    }
    return l
}

function arr_print( arr, s, l,  i, l2, t ){
    l = (l=="") ? arr[L] : l
    for (i= (s=="") ? 1 : s ; i<=l; ++i) print arr[i]
}

function arr_pr( arr, sep, start, step, end ){
    if (sep == "")  sep = "\n"
    if (step == "") {
        seq_parse( start )
        start   = SEQ_START
        step    = SEQ_STEP
        end     = SEQ_END
    } else {
        if (end == "")  end = arr[L]
    }

    if (end < 0)    for (i=start; i<=end; i+=step) printf("%s%s", arr[i], sep)
    else            for (i=start; i>=end; i+=step) printf("%s%s", arr[i], sep)
}

function arr_pl( arr, start, step, end ){
    return arr_pr( arr, "\n", start, step, end )
}

function arr_gc( arr, gcl,      i, j ){
    if ( (l = arr[ L ]) <= gcl ) return
    j = l - gcl
    for (i=1; i<=gcl; ++i) arr[i] = arr[j+i]
    arr[ L ] = gcl
}

# tgtl == 10 * gcl
function arr_gcwhen( arr, tgtl, gcl,      i, j ){
    if ( (l = arr[ L ]) <= tgtl ) return false
    arr_gc(arr, gcl)
    return true
}

function arr_uniq( arr,         l, i, j ) {
    l = arr[ L ]
    j = 1
    for (i=2; i<=l; ++i) {
        if (arr[i] != arr[i-1]) arr[++j] = arr[i]
    }
    return arr[ L ] = j
}

