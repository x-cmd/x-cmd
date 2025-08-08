{
    jiparse_after_tokenize(o, $0)
}

END{
    format = ENVIRON[ "format" ]
    Q2_1 = SUBSEP "\"1\""
    l = o[ Q2_1 L ]

    for (i=1; i<=l; ++i){
        key = o[ Q2_1, i ]
        val = o[ Q2_1, key ]
        val = (val ~ "^\"") ? juq(val) : val
        print sh_varset_val( "arg_" juq(key), val, true )

        if ( key != "\"desc\"" ) _res = _res " --" juq(key) " " shqu1(val)
    }
    print sh_varset_val( "cmdarg", _res, true )

}
