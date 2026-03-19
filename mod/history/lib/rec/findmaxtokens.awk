# {  print }



BEGIN{
    L = "\001"
    QTOKEN_MAP = "\006"
    QTOKEN_COUNT = "\007"
}

function tokenize(){
    PAT="\""
    # split
    # remove space
}

function qtokenidx_build( o,    l ){
    l = o[ L ]
    for (i=1; i<=l; ++i) {
        v = o[i]
        o[ QTOKEN_MAP, v ] = i
    }
}

function qtokenidx_reset( o,    l ){
    l = o[ L ]
    for (i=1; i<=l; ++i) {
        v = o[i]
        o[ QTOKEN_COUNT, i ] = 0
    }
}

function qtokenidx_count( o,   o1,  l, n ){
    l = o1[ L ]
    n = 0
    for (i=1; i<=l1; ++i) {
        v = o1[i]
        if (o[ QTOKEN_MAP, v ] > 0) { n += 1; }
    }
    return n
}

BEGIN{
    tokenize_map = 0

    tokenize( q, qtokenarr )
    qtokenidx_build( qtokenarr )

    maxn = 0
    maxmd5 = ""
    maxcmd = ""
}

{
    md5sum = $1
    $1 = ""
    gsub("^[ ]+", "", $0)

    delete o
    o[ L ] = 0

    tokenize( $0, o )
    n = qtokenidx_count( qtokenarr, o )
    if (n1 > n) {
        maxn = n
        maxmd5 = md5sum
        maxcmd = $0
    }
}

END {
    print maxmd5
    print maxcmd
}
