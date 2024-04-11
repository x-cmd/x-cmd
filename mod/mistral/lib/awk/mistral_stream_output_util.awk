function mistral_dsiplay_response_text_stream(s,       o, item, finish_reason){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    jiparse_after_tokenize(o, s)
    JITER_LEVEL = JITER_CURLEN = 0
    item = sprintf("%s", juq(o[ KP_CONTENT ]))
    MISTRAL_RESPONSE_CONTENT = MISTRAL_RESPONSE_CONTENT item
    printf item
    fflush()
    finish_reason = o[ KP_FINISH_REASON ]
    if ( finish_reason != "null" ) {
        o_response[ KP_FINISH_REASON ] = finish_reason
        o_response[ KP_CONTENT ] = jqu(MISTRAL_RESPONSE_CONTENT)
        exit(0)
    }
}

BEGIN{
    KP_CONTENT = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"delta\"" S "\"content\""
    KP_FINISH_REASON = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"finish_reason\""
    MISTRAL_RESPONSE_CONTENT = ""
    MISTRAL_HAS_RESPONSE_CONTENT = 0
}
( NR==1 ){
    MISTRAL_HAS_RESPONSE_CONTENT = 1
    if ($0 ~ "^{"){
        MISTRAL_RESPONESE_IS_ERROR_CONTENT=1
        jiparse_after_tokenize( o_error, $0 )
        JITER_LEVEL = JITER_CURLEN = 0
    } else {
        $1 = ""
        jiparse_after_tokenize( o_response, $0 )
        JITER_LEVEL = JITER_CURLEN = 0
    }
}
( NR>1 && $0 != "" ){
    MISTRAL_HAS_RESPONSE_CONTENT = 1;
    if (MISTRAL_RESPONESE_IS_ERROR_CONTENT==1) jiparse_after_tokenize( o_error, $0 )
    else {
        $1 = ""
        mistral_dsiplay_response_text_stream( $0 )
    }
}
