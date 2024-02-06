
BEGIN{
    BARLEN = 50
    TOP = int( ENVIRON[ "top" ] )
    if ( TOP <= 0 ) TOP = 16
}


{
    if ($2 ~ "^[\\[\\{\\(_]")   next
    if ($2 ~ "^[^\\(]+\\(\\)")  next
    if ($2 ~ "^\\\\n")          next
}

{
    count = $1
    $1 = ""
    cmd = $0
    gsub( "^ *", "", cmd )

    cmdlist[ ++ cmdlistl ] = cmd
    cmdc [ cmd ] = count

    TOTAL += count
}

END{
    while (1) {
        if (id++ >= TOP)  exit(0)

        cmd = cmdlist[ id ]
        count = cmdc[ cmd ]

        # if (cmd ~ "^[\\[\\{\\(_]")  continue
        # if (cmd ~ "^[^\\(]+\\(\\)") continue
        # if (cmd ~ "^\\\\n")         continue

        if (MAX == "")  MAX = count

        if ( id <= 10 ) {
            printf("\033[0;35m%5d ",    count)
            printf("\033[1;32m%4s ",    int(count/TOTAL * 100) "%")
            printf("\033[0m\t%-10s ",   cmd)
            printf("\033[0;1m%s\n",     drawbar( BARLEN * count / MAX, BARLEN, "\033[46m") )
        } else {
            printf("\033[2;35m%5d ",    count)
            printf("\033[2;32m%4s ",    int(count/TOTAL * 100) "%")
            printf("\033[0;2m\t%-10s ", cmd)
            printf("\033[0;2m%s\n",     drawbar( BARLEN * count / MAX, BARLEN, "\033[2;42m") )
        }


        # printf("\033[35m%5d \033[32m%4s \033[0;1m\t%-10s  %s\n",  \
        #     count,                                      \
        #     int(count/TOTAL * 100) "%",                 \
        #     cmd,                                        \
        #     drawbar( BARLEN * count / MAX, BARLEN))
        # printf("\033[31m%5d  \033[0m%s\n", count, drawbar_str( int(BARLEN * count / MAX), BARLEN, cmd))
    }
}

function drawbar( num, n, positive_style,       i, a ){
    a = positive_style # "\033[46m"
    if (num < 1) num = 1
    for (i=1; i<=num; ++i)  a = a " "
    a = a "\033[40m"
    for (; i<=n; ++i)  a = a " "
    return a "\033[0m"
}

function drawbar_str( num, n, str,         i, a, _arr ){
    split( str, _arr, "" )
    a = "\033[46m"
    if (num < 1) num = 1
    for (i=1; i<=num; ++i) {
        if (_arr[i] == "") _arr[i] = " "
        a = a _arr[i]
    }
    a = a "\033[40m"
    for (; i<=n; ++i) {
        if (_arr[i] == "") _arr[i] = " "
        a = a _arr[i]
    }
    return a "\033[0m"
}
