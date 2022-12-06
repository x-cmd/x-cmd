

function sb_init( ){
    if (SB_LEN != "") delete SB_DATA
    SB_LEN = 0
}

# return ( (SB_DATA == "") ? "" : (SB_DATA SB_SEP) ) data
function sb_append( data,   l ) {
    SB_DATA[ (SB_LEN = l = SB_LEN + 1) ] = data
}

function sb_build( sep,   i, e ){
    if (SB_LEN == 0) return ""
    e = SB_DATA[ 1 ]
    for (i=2; i<=SB_LEN; ++i) e = e sep SB_DATA[ i ]
    return e
}


function sbi_append( arr, i, data,  l ) {
    SB_DATA[ i ] = data
    return i+1
}

function sbi_build( arr, l, sep,  i, e ){
    if (l == 0) return ""
    e = arr[ 1 ]
    for (i=2; i<=l; ++i) e = e sep arr[ i ]
    return e
}
