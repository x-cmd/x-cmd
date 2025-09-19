{
    jiparse_after_tokenize(o, $0)
}

function parse_trim_args(str,       i){
    if ((i = index(str, "\n")) > 0 ){
        str = substr(str, 1, i - 1) "..."
    }
    return str
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
        _res = _res " --" juq(key) " " shqu1(val)

        _res_log = _res_log " --" juq(key) " " shqu1( parse_trim_args(val) )
    }
    print sh_varset_val( "cmdarg", _res, true )
    print sh_varset_val( "cmdarglog", _res_log, true )

}
