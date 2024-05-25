
BEGIN{
    msg = ( msg != "" ) ? msg : "Select the command statement you want to execute"
    _selectcmd = "___x_cmd ui select ,_cmd " qu1(msg) " "
}

{
    _cmd = $0
    if ( _cmd ~ "^\"" ) _cmd = juq(_cmd)
    _selectcmd = _selectcmd qu1(_cmd) " "
}

END{
    print _selectcmd "\"return 1\""
}
