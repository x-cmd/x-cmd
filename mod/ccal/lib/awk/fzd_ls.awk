BEGIN{
    FS = "\t"
}

function rep( s, n,     i, r ){
    r = ""
    for (i=1; i<=n; ++i)  r = r s
    return r
}

{
    kp = ccal_add( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13 )
}

{
    if ( ccal_val( kp ) < ( year * 10000 + month * 100 + day) ){
        BSTYLE = "\033[2m"
    } else {
        BSTYLE = ""
    }

    xiuxi = ccal_xiuxi( kp )

    if (xiuxi == "休") {
        style = "\033[31m"
        emoji = " 🏄‍♂️ "
    } else if (xiuxi == "工") {
        style = "\033[0;1;7;36m"
        emoji = " 💻 "
    } else if ( ccal_is_weekend( kp )) {
        style = "\033[31m"
        # emoji = " 🏖️ "
        emoji = " 🏄‍♂️ "
    } else {
        style = "\033[0;36m"
        emoji = " 💻 "
        # emoji = " 🚀 "
    }

    printf( style BSTYLE )
    printf("%10s  " ,      ccal_ymd( kp ) )

    # printf(" %s ", emoji )
    printf("%-5s  ",     $5 )

    printf("\033[0m" BSTYLE)

    printf("%-10s ",     $2 )

    if ( $4 == "无") {
        printf("%-3s  ",     " " )
    } else {
        printf("%-3s  ",     $4 )
    }

    if ( $7 == "无") {
        printf("%-5s  ",     " " )
    } else {
        printf("%-5s  ",     $7 )
    }

    if ( $9 == "无") {
        printf("%-7s\t",     " " )
    } else {
        printf("%-7s\t",     $9 )
    }
    printf("\033[0;35m" BSTYLE)
    printf("%s  ",       $12 )
    printf("\033[0;2;4m")
    printf("%s",         $13 )
    printf("\033[0m" "\n")
}
