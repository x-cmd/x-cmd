{ jiparse_after_tokenize(o, $0); }
END{
    tmpdir = ENVIRON[ "tmpdir" ]
    run_kp = SUBSEP "\"1\"" SUBSEP "\"runs\""

    run_kp = SUBSEP "\"1\"" SUBSEP "\"runs\""
    l = o[ run_kp L ]
    for (i=1; i<=l; ++i){
        rule_kp = run_kp SUBSEP "\""i"\"" SUBSEP "\"tool\"" SUBSEP "\"driver\"" SUBSEP "\"rules\""
        jl = o[ rule_kp L ]
        for (j=1; j<=jl; ++j){
            id = o[ rule_kp SUBSEP "\""j"\"" SUBSEP "\"id\"" ]

            short_desc_kp = rule_kp SUBSEP "\""j"\"" SUBSEP "\"shortDescription\"" SUBSEP "\"text\""
            full_desc_kp = rule_kp SUBSEP "\""j"\"" SUBSEP "\"fullDescription\"" SUBSEP "\"text\""
            RULE_ARR[ id, "sdesc" ] = o[ short_desc_kp ]
            RULE_ARR[ id, "fdesc" ] = o[ full_desc_kp ]

            help_kp = rule_kp SUBSEP "\""j"\"" SUBSEP "\"help\"" SUBSEP "\"text\""
            help_doc = o[ help_kp ]
            if ( match(help_doc, "If you believe these vulnerabilities do not affect your code and wish to ignore them") ){
                help_doc = substr(help_doc, 1, RSTART)
            }

            RULE_ARR[ id, "help" ] = help_doc

        }
    }


    print "Id,Level,Message,shortDescription,fullDescription,Help"
    l = o[ run_kp L ]
    for (i=1; i<=l; ++i){
        result_kp = run_kp SUBSEP "\""i"\"" SUBSEP "\"results\""
        jl = o[ result_kp L ]
        for (j=1; j<=jl; ++j){
            id = o[ result_kp SUBSEP "\""j"\"" SUBSEP "\"ruleId\"" ]
            level = o[ result_kp SUBSEP "\""j"\"" SUBSEP "\"level\"" ]
            msg = o[ result_kp SUBSEP "\""j"\"" SUBSEP "\"message\"" SUBSEP "\"text\"" ]
            fdesc = RULE_ARR[ id, "fdesc" ]
            sdesc = RULE_ARR[ id, "sdesc" ]
            help = RULE_ARR[ id, "help" ]
            print parse_item(id) "," parse_item(level) "," parse_item(msg) "," parse_item(sdesc) "," parse_item(fdesc) "," parse_item(help)
        }
    }
}

function parse_item(s){
    if ( s ~ "\"" ) s = juq(s)
    return csv_quote_ifmust(s)
}
