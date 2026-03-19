{ jiparse_after_tokenize(o, $0); }
END{
    print sh_varset_val( "_karma", int(o[ SUBSEP "\"1\"", "\"karma\"" ]) )

    _kp = SUBSEP "\"1\"" SUBSEP "\"submitted\""
    l = o[ _kp L ]
    for (i=1; i<=l; ++i) _submitted = _submitted o[ _kp, "\""i"\"" ] " "
    print sh_varset_val( "_submitted_L", int(l) )
    print sh_varset_val( "_submitted", _submitted )
}
