function openai_dsiplay_response_text_stream(s,       o, item, response_item, finish_reason){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    if (s !~ "^ *\\{") return
    jiparse_after_tokenize(o, s)

    if ( JITER_LEVEL != 0 ){
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        OPENAI_RESPONESE_ERROR_CONTENT = s
        OPENAI_RESPONESE_ERROR_MSG = "The response output format is incorrect"
        exit(1)
    }

    JITER_LEVEL = JITER_CURLEN = 0

    item = o[ KP_CONTENT ]
    response_item = o[ KP_REASONING_CONTENT ]

    if (( item == "null" ) && ( response_item != "null" )) {
        if ( OPENAI_RESPONSE_HAS_REASONING  == 0 ) {
            print "---------- REASONING BEGIN ----------"
        }
        OPENAI_RESPONSE_HAS_REASONING = 1
        response_item = juq(o[ KP_REASONING_CONTENT ])
        OPENAI_RESPONSE_REASONING_CONTENT = OPENAI_RESPONSE_REASONING_CONTENT response_item
        printf( "%s", response_item )
        fflush()

    } else if (OPENAI_RESPONSE_HAS_REASONING == 1){
        OPENAI_RESPONSE_HAS_REASONING = 0
        print "\n---------- REASONING END ----------"
    }

    if (( item != "null" ) && (item != "\"\"")) {
        item = juq(o[ KP_CONTENT ])
        OPENAI_RESPONSE_CONTENT = OPENAI_RESPONSE_CONTENT item
        printf( "%s", item )
        fflush()
    }

    finish_reason = o[ KP_FINISH_REASON ]
    cp_merge( o_response, o )
    if (( finish_reason != "" ) && ( finish_reason != "null" )) {
        o_response[ KP_FINISH_REASON ] = finish_reason
        o_response[ KP_CONTENT ] = jqu(OPENAI_RESPONSE_CONTENT)
        o_response[ KP_REASONING_CONTENT ] = jqu(OPENAI_RESPONSE_REASONING_CONTENT)
        exit(0)
    }
    delete o
}

BEGIN{
    KP_DELTA = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"delta\""
    KP_CONTENT = KP_DELTA S "\"content\""
    KP_REASONING_CONTENT = KP_DELTA S "\"reasoning_content\""
    KP_FINISH_REASON = S "\"1\"" S "\"choices\"" S "\"1\"" S "\"finish_reason\""
    OPENAI_RESPONSE_CONTENT = ""
    OPENAI_RESPONSE_REASONING_CONTENT = ""
    OPENAI_RESPONSE_HAS_REASONING = 0
    OPENAI_HAS_RESPONSE_CONTENT = 0
}

{
    if (($0 != "") && ($0 !~ "^:")){
        if ( OPENAI_HAS_RESPONSE_CONTENT != 0 ) {
            if (OPENAI_RESPONESE_IS_ERROR_CONTENT==1) jiparse_after_tokenize( o_error, $0 )
            else {
                $1 = ""
                openai_dsiplay_response_text_stream( $0 )
            }
        } else {
            OPENAI_HAS_RESPONSE_CONTENT = 1
            if ($0 ~ "^{"){
                OPENAI_RESPONESE_IS_ERROR_CONTENT=1
                jiparse_after_tokenize( o_error, $0 )
                JITER_LEVEL = JITER_CURLEN = 0
            } else {
                $1 = ""
                openai_dsiplay_response_text_stream( $0 )
                JITER_LEVEL = JITER_CURLEN = 0
            }
        }
    }
}
