
function ip_fromint( x,     x1, x2, x3, x4 ) {
    x1 = x % 256; x  = x / 256
    x2 = x % 256; x  = x / 256
    x3 = x % 256; x4 = x / 256
    return sprintf( "%d.%d.%d.%d", x4, x3, x2, x1 )
}

BEGIN{
    if ( ! pipe ) {
        for (i=s; i<e; i++) {
            print ip_fromint( i )
        }
        exit
    }
}

{
    print ip_fromint( $0 )
}


