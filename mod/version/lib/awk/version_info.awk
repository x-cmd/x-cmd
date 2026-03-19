{ jiparse(o, $0); }
END{
    ___X_CMD_VERSION_SUM = ENVIRON[ "___X_CMD_VERSION_SUM" ]
    # print ""
    Q2_1 = SUBSEP "\"1\""
    l = o[  Q2_1 L ]
    for (i=1; i<=l; ++i){
        v = o[ Q2_1, i ]
        sum = juq( o[ Q2_1, v, "\"sum\"" ] )
        if (sum == ___X_CMD_VERSION_SUM) {
            printf( "%s: %s\n", "tag", juq(v) )
            printf( "%s: %s\n", "date", o[ Q2_1, v, "\"date\"" ] )
        }
    }
    printf( "%s: %s\n", "sum", ___X_CMD_VERSION_SUM )
}
