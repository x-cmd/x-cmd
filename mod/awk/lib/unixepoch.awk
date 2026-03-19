
# since 1970 - 2270

function unixepoch_init_add( unix_month, start, days_2, s           ){
    UNIXEPOC_DAYS[ unix_month +  0 ] = ( s = start )
    UNIXEPOC_DAYS[ unix_month +  1 ] = ( s = s + 31 )
    UNIXEPOC_DAYS[ unix_month +  2 ] = ( s = s + days_2 )
    UNIXEPOC_DAYS[ unix_month +  3 ] = ( s = s + 31 )
    UNIXEPOC_DAYS[ unix_month +  4 ] = ( s = s + 30 )
    UNIXEPOC_DAYS[ unix_month +  5 ] = ( s = s + 31 )
    UNIXEPOC_DAYS[ unix_month +  6 ] = ( s = s + 30 )
    UNIXEPOC_DAYS[ unix_month +  7 ] = ( s = s + 31 )
    UNIXEPOC_DAYS[ unix_month +  8 ] = ( s = s + 31 )
    UNIXEPOC_DAYS[ unix_month +  9 ] = ( s = s + 30 )
    UNIXEPOC_DAYS[ unix_month + 10 ] = ( s = s + 31 )
    UNIXEPOC_DAYS[ unix_month + 11 ] = ( s = s + 30 )
    return s + 31
}

function unixepoch_init( y, _y,     s  ){
    s = 0
    m = 0
    for (y=0; y<= UNIXEPOC_YEAR_TOTAL ; y+=4) {
        s = unixepoch_init_add( (m),    s, 28 )
        s = unixepoch_init_add( (m+12), s, 28 )

        _y = y + 1970 + 2
        s = unixepoch_init_add( (m+24),  s, (( _y % 100 == 0 ) && ( _y % 400 != 0 )) ? 28 : 29 )

        s = unixepoch_init_add( (m+36),  s, 28 )

        m = m + 48
    }
}

function unixepoch_cal_unixmonth( days,     s, e, m, _days ){
    if ( (s = UNIXEPOC_DAYS_CACHE[ days ]) != "" ) return s

    s = int( days / 31 ) # 0
    e = int( days / 28 ) + 1
    if (e > UNIXEPOC_YEAR_MONTH_TOTAL ) e = UNIXEPOC_YEAR_MONTH_TOTAL

    m = (s + e) / 2
    while ( s< (e-1) ) {
        m = int( ( s + e ) / 2 )

        _days = UNIXEPOC_DAYS[ m ]

        if (_days == days) return m

        if (_days < days ) s = m
        else    e = m
    }

    return UNIXEPOC_DAYS_CACHE[ days ] = s
}

# 2013-12-03 12:34:56
function unixepoch_cal_date( seconds, fmt,      um, y, m, d, h ){
    if (fmt == "" )  fmt = "%4d-%02d-%02d %02d:%02d:%02d"

    d = seconds / SECOND_OF_DAY

    um = unixepoch_cal_unixmonth( d )
    y = int(um / 12) + 1970
    m = (um % 12) + 1

    d = d - UNIXEPOC_DAYS[ um ] + 1

    seconds = seconds % SECOND_OF_DAY

    h = int(seconds / 3600)
    seconds = seconds % 3600

    return sprintf( fmt, y, m, d, h, int(seconds / 60), seconds % 60 )
}

BEGIN {
    UNIXEPOC_YEAR_TOTAL = 300
    UNIXEPOC_YEAR_MONTH_TOTAL = UNIXEPOC_YEAR_TOTAL * 12

    UNIXEPOC_DAYS_CACHE[ 0 ] = 0

    UNIXEPOC_DAYS[ 1970 ] = 0
    SECOND_OF_DAY       = 24 * 60 * 60

    unixepoch_init()

    # testcase: awk -f 'lib/unixepoch.awk'  <<<""
    # print( unixepoch_cal_date( 0 ) )
    # print( unixepoch_cal_date( 1 ) )

    # First implemenatation finished at : 2025-09-07 18:04:53+0800
    # print( unixepoch_cal_date( 1757239493 ) )

    # seconds -> date optimization to cache easily : 2025-09-08 12:24:41+0800
    # print( unixepoch_cal_date(1757305481) )

}

