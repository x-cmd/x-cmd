function parse(s,       o){
    if (s ~ "^ *\\[DONE\\]$") { printf "\n"; exit(0); }
    jiparse_after_tokenize(o, s)
    printf("%s", juq(o[ S "\"1\"" S "\"choices\"" S "\"1\"" S "\"delta\"" S "\"content\"" ]))
    JITER_LEVEL = JITER_CURLEN = 0
}

( NR>1 && $0 != "" ){
    $1 = ""
    parse( $0 )
    fflush()
}
