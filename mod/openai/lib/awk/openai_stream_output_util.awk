function openai_display_response_text_stream(s,       o, item, response_item, finish_reason){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    if (s !~ "^ *\\{") return
    jiparse_after_tokenize(o, s)

    if ( JITER_LEVEL != 0 ){
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        OPENAI_RESPONESE_ERROR_CONTENT = s
        OPENAI_RESPONESE_ERROR_MSG = "The response output format is incorrect"
        exit(1)
    } else if ( o[ KP_ERROR ] != "" ) {
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        cp_cover_merge(o_error, o)
        exit(1)
    }

    JITER_LEVEL = JITER_CURLEN = 0

    if ( PROVIDER_NAME == "ollama" ) {
        openai_display_response_text_stream___ollama_format(o)
        return
    }

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
    cp_cover_merge( o_response, o )
    if (( finish_reason != "" ) && ( finish_reason != "null" )) {
        o_response[ KP_FINISH_REASON ] = finish_reason
        o_response[ KP_CONTENT ] = jqu(OPENAI_RESPONSE_CONTENT)
        o_response[ KP_REASONING_CONTENT ] = jqu(OPENAI_RESPONSE_REASONING_CONTENT)
        exit(0)
    }
    delete o
}

function openai_display_response_text_stream___ollama_format(o,             item, finish_reason, finish_status){
    item = juq(o[ KP_OLLAMA_CONTENT ])
    OPENAI_RESPONSE_CONTENT = OPENAI_RESPONSE_CONTENT item
    printf( "%s", item )
    fflush()
    cp_cover_merge( o_response, o )
    finish_status = o_response[ KP_OLLAMA_DONE ]
    if ( finish_status != "false" ) {
        o_response[ KP_OLLAMA_DONE ] = finish_status
        o_response[ KP_OLLAMA_CONTENT ] = jqu(OPENAI_RESPONSE_CONTENT)
        exit(0)
    }
    delete o
}

BEGIN{
    Q2_1                    = SUBSEP "\"1\""
    KP_DELTA                = Q2_1 SUBSEP "\"choices\"" SUBSEP "\"1\"" SUBSEP "\"delta\""
    KP_CONTENT              = KP_DELTA SUBSEP "\"content\""
    KP_ERROR                = Q2_1 SUBSEP "\"error\""
    KP_REASONING_CONTENT    = KP_DELTA SUBSEP "\"reasoning_content\""
    KP_FINISH_REASON        = Q2_1 SUBSEP "\"choices\"" SUBSEP "\"1\"" SUBSEP "\"finish_reason\""

    KP_OLLAMA_DONE          = Q2_1 SUBSEP "\"done\""
    KP_OLLAMA_CONTENT       = Q2_1 SUBSEP "\"message\"" SUBSEP "\"content\""
    # KP_OLLAMA_TOTAL_DURATION = Q2_1 SUBSEP "\"total_duration\""
    # KP_OLLAMA_LOAD_DURATION = Q2_1 SUBSEP "\"load_duration\""

    PROVIDER_NAME           = ENVIRON[ "provider_name" ]

    OPENAI_RESPONSE_CONTENT = ""
    OPENAI_RESPONSE_REASONING_CONTENT = ""
    OPENAI_RESPONSE_HAS_REASONING = 0
    OPENAI_HAS_RESPONSE_CONTENT = 0
}

{
    if (($0 != "") && ($0 !~ "^:")){
        if ( OPENAI_HAS_RESPONSE_CONTENT != 0 ) {
            if (OPENAI_RESPONESE_IS_ERROR_CONTENT==1) {
                jiparse_after_tokenize( o_error, $0 )
                next
            } else {
                if ($0 !~ "^ *\\{") $1 = ""
                openai_display_response_text_stream( $0 )
            }
        } else {
            OPENAI_HAS_RESPONSE_CONTENT = 1
            if ($0 == "{") {
                OPENAI_RESPONESE_IS_ERROR_CONTENT=1
                jiparse_after_tokenize( o_error, $0 )
                next
            } else {
                if ($0 !~ "^ *\\{") $1 = ""
                openai_display_response_text_stream( $0 )
            }
        }
    }
}
