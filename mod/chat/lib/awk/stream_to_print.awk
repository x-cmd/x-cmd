function parse(s,       o){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    jiparse_after_tokenize(o, s)
    printf("%s", juq(o[ KP_CONTENT ]))
    if (o[ KP_FINISH_REASON ] == "\"stop\"") exit(0)
    JITER_LEVEL = JITER_CURLEN = 0
}

BEGIN{
    KP_CONTENT = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"delta\"" S "\"content\""
    KP_FINISH_REASON = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"finish_reason\""
}

( NR>1 && $0 != "" ){
    $1 = ""
    parse( $0 )
    fflush()
}

END{    printf "\n";    }

