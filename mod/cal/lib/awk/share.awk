
BEGIN{
    MONTH_DAY[1]    = 31
    MONTH_DAY[2]    = 28  #
    MONTH_DAY[3]    = 31
    MONTH_DAY[4]    = 30
    MONTH_DAY[5]    = 31
    MONTH_DAY[6]    = 30
    MONTH_DAY[7]    = 31
    MONTH_DAY[8]    = 31
    MONTH_DAY[9]    = 30
    MONTH_DAY[10]   = 31
    MONTH_DAY[11]   = 30
    MONTH_DAY[12]   = 31
}

function getlastdayofmonth( y, m ) {
    if (m == 2) {
        return ( (y % 100 != 0) && ( y % 4 == 0 ) || ( y % 400 == 0) ) ? 29 : 28
    } else {
        return MONTH_DAY[ m ]
    }
}

function gettoday( a, l ){
    if ( X_Y != "" ) {
        return 0
    }

    "date +\"%Y %m %d %w\"" | getline result
    l = split( result, a, " ")
    Y = int( a[1] )
    M = int( a[2] )
    D = int( a[3] )
    W = int( a[4] )
}

# TODO: Can be optmized if calculated in batch, or cached.
function backward(  ){
    __w = ( __w == 0 ) ? 6 : (__w-1)

    if (__d > 1) {
        __d = __d - 1
        return
    }

    __m = ( __m == 1 ) ? 12 : ( __m - 1 )
    if ( __m == 12)  __y = __y - 1

    __d = getlastdayofmonth( __y, __m )
}

function forward( _d ){
    __w = ( __w == 6 ) ? 0 : (__w+1)

    _d = getlastdayofmonth( __y, __m )

    if (__d != _d) {
        __d = __d + 1
        return
    }

    __d = 1
    if ( __m == 12 ) { __y = __y + 1; __m = 0;  }
    else { __m = __m + 1 }
}

function deduce_cache( i, y, m, d, w ){
    cache[ i, "y" ] = y
    cache[ i, "m" ] = m
    cache[ i, "d" ] = d
    cache[ i, "w" ] = w

    cache[ y, m, d ] = w
    cache[ cache[ i ] = sprintf("%0d%0d%0d", y, m, d )  ] = i

}

function deduce_cache_init( ){
    __y = Y
    __m = M
    __d = D
    __w = W
}

function deduce( default,       i ){
    if (default == "") { default = 360; }
    gettoday()

    deduce_cache_init()
    for (i=-1; i>=-default; --i) {
        backward()
        deduce_cache( i, __y, __m, __d, __w )
    }

    deduce_cache( 0, Y, M, D, W )

    deduce_cache_init()
    for (i=1; i<default; ++i) {
        forward()
        deduce_cache( i, __y, __m, __d, __w )
    }
}

BEGIN{
    TUI_RESET = "\033[0m"
}


function prettydate( y, m, d ){
    return  "\033[34m" substr(y, 3) ( TUI_RESET "-"  ) "\033[32m"  sprintf("%02d", m) ( TUI_RESET "-" ) "\033[31m"  sprintf("%02d", d) TUI_RESET
}

BEGIN{
    WEEKDAY[0] = "日"
    WEEKDAY[1] = "一"
    WEEKDAY[2] = "二"
    WEEKDAY[3] = "三"
    WEEKDAY[4] = "四"
    WEEKDAY[5] = "五"
    WEEKDAY[6] = "六"

    P_WEEKDAY[0] = "\033[31m" WEEKDAY[0] TUI_RESET
    P_WEEKDAY[1] = "\033[34m" WEEKDAY[1] TUI_RESET
    P_WEEKDAY[2] = "\033[34m" WEEKDAY[2] TUI_RESET
    P_WEEKDAY[3] = "\033[34m" WEEKDAY[3] TUI_RESET
    P_WEEKDAY[4] = "\033[34m" WEEKDAY[4] TUI_RESET
    P_WEEKDAY[5] = "\033[34m" WEEKDAY[5] TUI_RESET
    P_WEEKDAY[6] = "\033[31m" WEEKDAY[6] TUI_RESET
}

function showcal( y, m,                 d, w,   lastday ){
    printf("\n")
    lastday = getlastdayofmonth( y, m )
    for ( d=1; d<=lastday; ++d ) {
        w = cache[ y, m, d ]
        printf( "  %s " "%s: %d\n", P_WEEKDAY[ w ], prettydate( y, m, d ),  w )
    }
}

function showcal1( y, m,                d, w,    lastday ){
    printf("%s   ", y "-\033[34m" sprintf("%02d", m) )
    lastday = getlastdayofmonth( y, int(m) )

    w = cache[ y, m, 1 ]

    for (d=0; d<w; ++d) { printf("%s", "   "); }

    for ( d=1; d<=lastday; ++d ) {
        w = cache[ y, m, d ]
        if ( (w == 0) || (w == 6) ) {
            printf( TUI_RESET "\033[31m" "%2d" TUI_RESET " ", d )
        } else {
            printf( TUI_RESET "\033[34m" "%2d" TUI_RESET " ", d )
        }
    }

    printf("\033[0m\n")
}

BEGIN {
    deduce( 720 )

    # showcal( Y, M-1 )
    # showcal( Y, M )
    # showcal( Y, M+1 )

    printf("%s\n", "")
    for (i=1; i<=12; ++i){
        showcal1( Y, i )
    }
    # showcal1( Y, M )
    # showcal1( Y, M+1 )
    # showcal1( Y, M+2 )
}

