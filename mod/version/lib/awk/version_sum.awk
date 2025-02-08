{ jiparse(o, $0); }
END{
    x_version = ENVIRON[ "x_version" ]
    Q2_1 = SUBSEP "\"1\""
    if ( x_version !~ "^(latest|alpha|beta)$" ) {
        # e.g. v0.5.1
        sum = o[ Q2_1, jqu(x_version), "\"sum\"" ]
    } else {
        # e.g. latest/alpha/beta
        l = o[ Q2_1 L ]
        for (i=1; i<=l; ++i){
            v = o[ Q2_1, i ]
            if ( o[ Q2_1, v, jqu(x_version) ] == "true" ) {
                sum = o[ Q2_1, v, "\"sum\"" ]
                break
            }
        }
    }

    if (sum != "") {
        print juq(sum)
    } else {
        exit(1)
    }
}
