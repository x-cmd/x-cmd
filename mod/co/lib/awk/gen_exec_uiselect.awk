
{ jiparse_after_tokenize(o, $0); }
END{
    _selectcmd = "___x_cmd ui select ,_cmd \"Select the command statement you want to execute\" "

    kp = SUBSEP "\"1\"" SUBSEP "\"answer\""
    l = o[ kp L ]
    for (i=1; i<=l; ++i){
        cmd = o[ kp, "\""i"\"", "\"cmd\"" ]
        cmd = qu1( juq(cmd) )
        _selectcmd = _selectcmd cmd " "
    }
    print _selectcmd "\"return 0\""
}
