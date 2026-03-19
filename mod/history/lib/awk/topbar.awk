
BEGIN{
    BARLEN = 50
    if ( TOP <= 0 ) TOP = 16
}

{
    count = $1
    $1 = ""
    cmd = str_trim($0)

    cmdlist[ ++ cmdlistl ] = cmd
    cmdc [ cmd ] = count
    if (cmdlistl <= TOP) {
        w = length(cmd)
        if (max_w < w) max_w = w
    }

    TOTAL += count
}

END{
    if ( TOP > cmdlistl ) TOP = cmdlistl
    while (1) {
        if (id++ >= TOP)  exit(0)

        cmd = cmdlist[ id ]
        count = cmdc[ cmd ]

        if (MAX == "")  MAX = count

        if ( id <= 10 ) {
            printf("\033[0;35m%5d ",    count)
            printf("\033[1;32m%4s ",    int(count/TOTAL * 100) "%")
            printf("\033[0m\t%-"max_w"s  ",   cmd)
            printf("\033[0;1m%s\n",     drawbar( BARLEN * count / MAX, BARLEN, "\033[46m") )
        } else {
            printf("\033[2;35m%5d ",    count)
            printf("\033[2;32m%4s ",    int(count/TOTAL * 100) "%")
            printf("\033[0;2m\t%-"max_w"s  ", cmd)
            printf("\033[0;2m%s\n",     drawbar( BARLEN * count / MAX, BARLEN, "\033[2;42m") )
        }
    }
}

function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
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
