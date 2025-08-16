BEGIN{
    FS="\t"
    getline
    while (1) {
        if ($0 ~ /^USER/) {
            handle_unix()
        } else if ($0 ~ /WINPID/) {
            handle_windows()
        } else {
            if (!getline) break
        }
    }
}

function parse(){
    FS = " "
    $0 = $NF
    cmd = $1
    arg = substr($0, length(cmd)+2)

    FS = "\t"
}


# USER PID [TTY %CPU %MEM VSZ RSS STAT STARTED] TIME COMMAND

function str_limit( s, len ){
    if (length(s) > len) {
        return substr(s, 1, len)
    } else {
        return s
    }
}

function str_trim_1( s ){
    gsub( /(^[ ]+)|([ ]+)$/, "", s )
    return s
}

function str_trim_tty( ttys ){
    ttys = str_trim_1( ttys )

    if (ttys ~ /^tty/) {
        return substr( ttys, 4 )
    } else {
        return ttys
    }
}

function ps_printmem( vsz,  vsz_fmt ){
    # TB red    GB yellow    MB  green
    if ( vsz > 1000000000 ) {
        vsz_fmt = sprintf( " %3d", (vsz / 1000000000) )
        printf( "\033[31m" "%3s T "     "\033[0m",    vsz_fmt )
    } else if ( vsz > 1000000 ) {
        vsz_fmt = sprintf( " %3d", (vsz / 1000000) )
        printf( "\033[33m" "%3s G "     "\033[0m",    vsz_fmt )
    } else if ( vsz > 1000 ) {
        vsz_fmt = sprintf( "%3d", (vsz / 1000) )
        printf( "\033[32m" " %3s M "     "\033[0m",    vsz_fmt )
    } else {
        vsz_fmt = sprintf( "%3d", (vsz) )
        printf( "\033[36m" " %3s K "     "\033[0m",    vsz_fmt )
    }
}

function handle_unix(){
    while (getline) {
        printf( "\033[34m" "%-6s "     "\033[0m", str_limit( $1, 6 ) )      # user
        printf( "\033[34m" "%6d "     "\033[0m", $2 )                       # pid
        printf( "\033[34m" "%6d "     "\033[0m", $3 )                       # ppid


        printf( "\033[32m" "%5s "      "\033[0m", $4 )        # tty

        # cpu
        cpu = int($5)
        if ( cpu < 10 ) {
            printf( "\033[2;32m" "%5s "   "\033[0m",    cpu )
        } else if ( cpu < 40 ) {
            printf( "\033[34m" "%5s "     "\033[0m",    cpu )
        } else if ( cpu < 70 ) {
            printf( "\033[33m" "%5s "     "\033[0m",    cpu )
        } else {
            printf( "\033[31m" "%5s "     "\033[0m",    cpu )
        }

        # mem
        mem = int($6)
        if ( mem < 10 ) {
            printf( "\033[2;32m" "%5s "   "\033[0m",    mem )
        } else if ( mem < 40 ) {
            printf( "\033[34m" "%5s "     "\033[0m",    mem )
        } else if ( mem < 70 ) {
            printf( "\033[33m" "%5s "     "\033[0m",    mem )
        } else {
            printf( "\033[31m" "%5s "     "\033[0m",    mem )
        }

        # vsz and rss
        ps_printmem( int($7) )
        ps_printmem( int($8) )

        printf( "\033[33m" "%5s"     "\033[0m", $9 )       # stat
        # printf( "\033[33m" "%6d |"     "\033[0m", $9 )   # started

        time = $(NF-1)
        split(time, timea, ":")
        time_h = int( timea[1] )
        time_m = int( timea[2] )

        if (time_h > 0) {
            printf( "\033[35m" "%12s "     "\033[0m", time )   # time
        } else if (time_m > 20) {
            printf( "\033[33m" "%12s "     "\033[0m", time )   # time
        } else if (time_m > 5) {
            printf( "\033[32m" "%12s "     "\033[0m", time )   # time
        } else if (time_m > 1) {
            printf( "\033[36m" "%12s "     "\033[0m", time )   # time
        } else {
            printf( "\033[2;36m" "%12s "     "\033[0m", time )   # time
        }

        parse()

        printf( "\033[36m" "%-10s  "    "\033[0m", cmd )
        printf( "\033[0m" "%s\n"        "\033[0m", arg )
    }
}

function handle_windows(){
    while (getline) {
        printf( "\033[34m" "%-6d "    "\033[0m", str_limit( $1, 6 ) )       # pid
        printf( "\033[34m" "%6d "     "\033[0m", $2 )                       # ppid
        printf( "\033[34m" "%6d "     "\033[0m", $3 )                       # pgid
        printf( "\033[34m" "%8d "     "\033[0m", $4 )                       # winpid


        printf( "\033[32m" "%8s "      "\033[0m", $5 )                      # tty
        printf( "\033[34m" "%8d "      "\033[0m", $6 )                      # uid

        time = $(NF-1)
        split(time, timea, ":")
        time_h = int( timea[1] )
        time_m = int( timea[2] )

        if (time_h > 0) {
            printf( "\033[35m" "%12s "     "\033[0m", time )   # time
        } else if (time_m > 20) {
            printf( "\033[33m" "%12s "     "\033[0m", time )   # time
        } else if (time_m > 5) {
            printf( "\033[32m" "%12s "     "\033[0m", time )   # time
        } else if (time_m > 1) {
            printf( "\033[36m" "%12s "     "\033[0m", time )   # time
        } else {
            printf( "\033[2;36m" "%12s "     "\033[0m", time )   # time
        }

        parse()

        printf( "\033[36m" "%-10s  "    "\033[0m", cmd )
        printf( "\033[0m" "%s\n"        "\033[0m", arg )
    }
}
