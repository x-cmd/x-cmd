{jiparse_after_tokenize( O, $0 )}
END{
    l = split(ARGS, arr, " ")
    _kp = SUBSEP "\"1\""
    for (i=1; i<=l; ++i) _kp = _kp SUBSEP jqu(arr[i])
    l = O[ _kp L ]
    for (i=1; i<=l; ++i){
        key = O[ _kp,  i ]
        print  juq(key) " " jstr1(O, _kp S key S "\"<info>\"")
    }
}
