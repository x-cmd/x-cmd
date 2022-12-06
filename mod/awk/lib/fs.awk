
function cat( filepath,    r, c ){
    CAT_FILENOTFOUND = false
    while ((c=(getline <filepath))==1) {
        r = (r == "") ? $0 : r RS $0
    }
    if (c == -1)    CAT_FILENOTFOUND = true
    close( filepath )
    return r
}

function cat_is_filenotfound(){
    return CAT_FILENOTFOUND
}


function bcat_oct_init(){
    if (BCAT_INIT == 1) return
    BCAT_INIT = 1
    for (i=1; i<=256; ++i) OCTARR[ sprintf("%03o", i) ] = sprintf("%c", i)
}

function bcat( filepath, a,     _tmprs, _cmd ){
    _tmprs = RS
    _cmd = "hexdump -v -b " filepath " 2>/dev/null"

    i = 0; while (_cmd | getline) {
        a[ ++i ] = OCTARR[$2]
        a[ ++i ] = OCTARR[$3]
        a[ ++i ] = OCTARR[$4]
        a[ ++i ] = OCTARR[$5]
        a[ ++i ] = OCTARR[$6]
        a[ ++i ] = OCTARR[$7]
        a[ ++i ] = OCTARR[$8]
        a[ ++i ] = OCTARR[$9]
        a[ ++i ] = OCTARR[$10]
        a[ ++i ] = OCTARR[$11]
        a[ ++i ] = OCTARR[$12]
        a[ ++i ] = OCTARR[$13]
        a[ ++i ] = OCTARR[$14]
        a[ ++i ] = OCTARR[$15]
        a[ ++i ] = OCTARR[$16]
        a[ ++i ] = OCTARR[$17]
    }

    RS = _tmprs
    return a[ L ] = i
}

