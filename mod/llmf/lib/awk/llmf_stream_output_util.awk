function llmf_display_response_text_stream(s,       o, item, finish_reason){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    jiparse_after_tokenize(o, s)
    JITER_LEVEL = JITER_CURLEN = 0
    item = juq(o[ KP_CONTENT ])
    LLMF_RESPONSE_CONTENT = LLMF_RESPONSE_CONTENT item
    printf item
    fflush()
    finish_reason = o[ KP_FINISH_REASON ]
    if ( finish_reason != "null" ) {
        o_response[ KP_FINISH_REASON ] = finish_reason
        o_response[ KP_CONTENT ] = jqu(LLMF_RESPONSE_CONTENT)
        exit(0)
    }
}

BEGIN{
    KP_CONTENT = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"delta\"" S "\"content\""
    KP_FINISH_REASON = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"finish_reason\""
    LLMF_RESPONSE_CONTENT = ""
    LLMF_HAS_RESPONSE_CONTENT = 0
}
( NR==1 ){
    LLMF_HAS_RESPONSE_CONTENT = 1
    if ($0 ~ "^{"){
        LLMF_RESPONESE_IS_ERROR_CONTENT=1
        jiparse_after_tokenize( o_error, $0 )
        JITER_LEVEL = JITER_CURLEN = 0
    } else {
        $1 = ""
        jiparse_after_tokenize( o_response, $0 )
        JITER_LEVEL = JITER_CURLEN = 0
    }
}
( NR>1 && $0 != "" ){
    LLMF_HAS_RESPONSE_CONTENT = 1;
    if (LLMF_RESPONESE_IS_ERROR_CONTENT==1) jiparse_after_tokenize( o_error, $0 )
    else {
        $1 = ""
        llmf_display_response_text_stream( $0 )
    }
}
