
function display( t,    i ) {
    for (i=1; i<=t[0]; ++i) {
        printf("%s,%s\t", t[i, 0], t[i, 1])
    }
    printf("\n")
}

function locatetoken( tokenarr, line,    l ){
    mask = line
    gsub("[^ ]", "-", mask)

    l = 0
    inc = 0
    left = 1
    while (1){
        right = index(mask, " ")

        tokenarr[ ++l, 0 ]  = inc + left
        tokenarr[ l, 1 ]    = inc + right - 1

        # print(inc + left, inc + right - 1)
        # print "inc\t" inc
        mask = substr(mask, right);    inc = inc + right - 1
        # print "inc\t" inc

        # print "maskaaaa\t|" mask
        if ( ((left = index(mask, "-")) < 1) )  break
        mask = substr(mask, left);     inc = inc + left - 1
        left = 1
    }

    tokenarr[ 0 ] = l
}


NR==1{
    name_left = index( $0, "NAME")
    line = substr( $0, 1, name_left-1 )
    locatetoken( title, line )

    # display( title )

    for (i=1; i<=title[0]; ++i) {
        ttt = substr( $0, title[i, 0], title[i, 1] - title[i, 0]+1)
        printf("%s\t", ttt)
    }

    printf("%s\n", "NAME")
}

NR>1{
    name = substr( $0, name_left )
    line = substr( $0, 1, name_left-1 )

    delete col
    delete token

    locatetoken( token, line )
    # print line

    k = 1
    for (i=1; i<=token[ 0 ]; ++i) {
        for (j=k; j<=title[ 0 ]; ++j) {
            if (( title[j, 0] == token[i, 0]) || ( title[j, 1] == token[i, 1])) {
                col[ j ] = substr( line, token[i, 0], token[i, 1] - token[i, 0]+1)
                k=j
                break
            }
        }
    }

    for (i=1; i<=title[0]; ++i) {
        printf("%s\t", col[i])
    }
    printf("%s\n", name)
}

