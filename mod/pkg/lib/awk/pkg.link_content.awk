END {
    prefix = jqu(PKG_NAME) SUBSEP jqu( EXPR )
    if(table[ prefix ] == ""){
        exit(1)
    }

    l = table[ prefix L ]
    for (i=1; i<=l; ++i) {
            k = table[ prefix, i ]
            if( table[ prefix, i ] != "" ) print juq(k)
    }
}