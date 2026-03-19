function print_binpath( binpath ){
    print binpath
    exit(0)
}

END {
    prefix = jqu(PKG_NAME) SUBSEP jqu("xbin")

    if ( "{" != table[ prefix ] ) {
        print print_binpath( table_eval(table, PKG_NAME, table[ prefix ] ) )
    }

    l = table[ prefix L ]
    for (i=1; i<=l; ++i) {

        k = table[ prefix, i ]
        v = table[ prefix, k ]
        k = juq(k)

        if (( k == BIN_MOD_NAME ) && ( "{" != v ) && ( "\"\"" != v )) {
            print print_binpath( table_eval(table, PKG_NAME, v ) )
            continue
        }
    }

    exit(1)
}
