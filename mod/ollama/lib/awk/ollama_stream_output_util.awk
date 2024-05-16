BEGIN{
    KEYPATH = SUBSEP "\"1\""
    KP_DONE = KEYPATH SUBSEP "\"done\""
    KP_CONTENT = KEYPATH SUBSEP "\"message\"" SUBSEP "\"content\""
    KP_TOTAL_DURATION = KEYPATH SUBSEP "\"total_duration\""
    KP_LOAD_DURATION = KEYPATH SUBSEP "\"load_duration\""
    OLLAMA_RESPONSE_CONTENT = ""
    OLLAMA_RESPONESE_IS_ERROR_CONTENT = 0
}

function ollama_dsiplay_response_text_stream(s, o_response,      item, finish_reason, finish_status){
    jiparse_after_tokenize(o_response, s)
    JITER_LEVEL = JITER_CURLEN = 0
    item = sprintf("%s", juq(o_response[ KP_CONTENT ]))
    OLLAMA_RESPONSE_CONTENT = OLLAMA_RESPONSE_CONTENT item
    printf( "%s", item )
    fflush()
    finish_status = o_response[ KP_DONE ]
    if ( finish_status != "false" ) {
        o_response[ KP_DONE ] = finish_status
        o_response[ KP_CONTENT ] = jqu(OLLAMA_RESPONSE_CONTENT)
        exit(0)
    }
}

( NR==1 ){
    OLLAMA_HAS_RESPONSE_CONTENT = 1
    if ($0 ~ "^{\"error\""){
        OLLAMA_RESPONESE_IS_ERROR_CONTENT=1
        jiparse_after_tokenize( o_error, $0 )
        JITER_LEVEL = JITER_CURLEN = 0
    } else {
        jiparse_after_tokenize( o_response, $0 )
        JITER_LEVEL = JITER_CURLEN = 0
    }
}

( NR>=1 && $0 != "" ){
    OLLAMA_HAS_RESPONSE_CONTENT = 1;
    if (OLLAMA_RESPONESE_IS_ERROR_CONTENT==1) jiparse_after_tokenize( o_error, $0 )
    else ollama_dsiplay_response_text_stream( $0, o_response )
}
