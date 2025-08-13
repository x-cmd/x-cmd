function str_limit( s, len ){
    if (length(s) > len) {
        return substr(s, 1, len)
    } else {
        return s
    }
}

NR>1{
    printf( "\033[36m" "%-16s "    "\033[0m",   $2 " " str_limit( $1, 13 ) )       # command
    printf( "\033[34m" "%8s "      "\033[0m",   str_limit( $3, 8) )         # USER

    printf( "\033[31m" "%4s "      "\033[0m",   $4 )         # FD
    printf( "\033[32m" "%6s "      "\033[0m",   $5 )         # TYPE
    printf( "\033[33m" "%6s "      "\033[0m",   $6 )         # DEVICE
    printf( "\033[35m" "%10s "      "\033[0m",   $7 )        # SIZE/OFF
    # printf( "\033[34m" "%8s "      "\033[0m",   $8 )       # NODE

    $1 = $2 = $3 = $4 = $5 = $6 = $7 = ""
    printf( "\033[36m" "%s "      "\033[0m",   $0 )      # NAME

    printf( "\n" )

}
