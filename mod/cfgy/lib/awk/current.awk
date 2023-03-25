{
    jiparse( o, $0 )
}

END{
    root = SUBSEP jqu(1)

    current_jqu = jqu(ENVIRON["current"])

    root = root SUBSEP "\"profile\""
    if (( l = o[ root L ] ) == "") l = 0
    for (i=1; i<=l; ++i) {
        if (o[ root, jqu(i), jqu("name") ] == current_jqu) {
            jdict_put( o, SUBSEP jqu(1), jqu("current"), current_jqu )
            print jstr( o )
            exit( 0 )
        }
    }

    exit(1)
}
