
NR==1{
    # analyse_header( attr )
    # if (row ~ "(auto)|-") {
    #     row = attr[ L ] - 1
    # }

    # for (i=1; i<attr[ L ]-1; i++) {
    #     printf("%s,", csv_quote_ifmust(substr($0, attr[i], attr[i+1]-attr[i])))
    # }
    # printf("%s\n", csv_quote_ifmust( substr($0, attr[attr[L]-1]) ))

    row = NR
    next
}

NR<5{
    for (i=1; i<row; ++i) {
        printf("%s,", csv_quote_ifmust($i))
        $i=0
    }
    printf("%s\n", csv_quote_ifmust($0))
    printf("\n")
}
