
BEGIN{
    task = (task == "yes") ? 1 : ""
}


function str_limit( s, len ){
    if (length(s) > len) {
        return substr(s, 1, len)
    } else {
        return s
    }
}

function parse_device( s1, s2 ){
    gsub("\"", "", s1)
    gsub("\"", "", s2)
    return s1 "," s2
}

NR==1{
    if ( $3 == "TID" )   LINUX_DATA = 1
}

NR>1{
    command = $2 " " str_limit( $1, 13 )
    user    = str_limit( (LINUX_DATA) ? $5 : $3, 8)
    if ( task ) {
        tid     = $3
        tname   = $4
    }
    fd      = (LINUX_DATA) ? $6 : $4
    type    = (LINUX_DATA) ? $7 : $5
    # device start
    i       = (LINUX_DATA) ? 8 : 6

    if ($i ~ "\"") {
        device          = parse_device($i, $(i+1))
        size_off        = $(i+2)
        fields_to_clear = i + 2
    } else {
        device          = $i
        size_off        = $(i+1)
        fields_to_clear = i + 1
    }

    for (j = 1; j <= fields_to_clear; j++) {
        $j = ""
    }

    name = $0
    print_auto( command, tid, tname, user, fd, type, device, size_off, name )
}

function print_auto( command, tid, tname, user, fd, type, device, size_off, name ){
    printf( "\033[36m" "%-16s "     "\033[0m",   command )
    if ( task ){
        printf( "\033[36m" "%7s "   "\033[0m",   tid )
        printf( "\033[34m" "%9s "   "\033[0m",   tname )
    }
    printf( "\033[34m" "%8s "       "\033[0m",   user )
    printf( "\033[31m" "%4s "      "\033[0m",   fd )
    printf( "\033[32m" "%9s "      "\033[0m",   type )
    printf( "\033[33m" "%19s "     "\033[0m",   device )
    printf( "\033[35m" "%10s "     "\033[0m",   size_off )
    printf( "\033[36m" "%s "       "\033[0m",   name )
    printf( "\n" )
}
