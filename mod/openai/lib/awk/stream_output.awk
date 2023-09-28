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

( NR==1 && ($0 ~ "^{")){
    IS_ERROR_CONTENT=1
    jiparse_after_tokenize( o_error, $0 )
}
( NR>1 && $0 != "" ){
    if (IS_ERROR_CONTENT==1) jiparse_after_tokenize( o_error, $0 )
    else {
        $1 = ""
        parse( $0 )
        fflush()
    }
}

END{
    if (IS_ERROR_CONTENT != 1) printf "\n"
    else {
        print log_error("chat", log_mul_msg(jstr(o_error)))
    }
}

