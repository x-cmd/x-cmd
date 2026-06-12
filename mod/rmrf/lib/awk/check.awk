
BEGIN{
    patharrl = split( ENVIRON["TARGET_LIST"], patharr, "\001" )
    rulelist = ENVIRON["RULE_LIST"]
    rule_arrl = 0
    n = split( rulelist, tmparr, "\n" )
    for (i=1; i<=n; ++i) {
        if (tmparr[i] == "") continue
        rule_arr[ ++rule_arrl ] = tmparr[i]
        r = tmparr[i]
        gsub(/\*\*/, ".+", r)
        gsub(/\*/, "[^/]+", r)
        regex_arr[ rule_arrl ] = "^" r
    }
}

END{
    for (i=1; i<=patharrl; ++i) {
        p = patharr[ i ]
        for (j=1; j<=rule_arrl; ++j) {
            if ( match( p, regex_arr[j] ) ) {
                printf("%s\n", rule_arr[j])
                printf("%s\n", p )
                exit(1)
            }
        }
    }
}
