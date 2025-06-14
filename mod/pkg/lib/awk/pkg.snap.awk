function pkg_snap_check_value(v){
    (( v != "{" ) && ( v != "\"\"" ) && ( v != "null" ) && (v != ""))
}
END {
    prefix = jqu(PKG_NAME) SUBSEP jqu("xbin")

    v = table[ prefix ]
    if ( pkg_snap_check_value(v) ) {
        print PKG_NAME
        print TGTDIR "/" table_eval(table, PKG_NAME, v )
        exit(0)
    }

    l = table[ prefix L ]
    for (i=1; i<=l; ++i) {

        k = table[ prefix, i ]
        v = table[ prefix, k ]
        k = juq(k)

        if (pkg_snap_check_value(v)) {
            print k
            print TGTDIR "/" table_eval(table, PKG_NAME, v )
        }
    }

    exit(1)
}
