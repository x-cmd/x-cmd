function openai_display_response_text_stream(s,       o, item, response_item, finish_reason, choices_l, tool_l, tool_index, tool_last_index, kp_i, kp_tool_name, kp_tool_args, kp_tool_id, call_id, i, idx ){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    if (s !~ "^ *\\{") return
    jiparse_after_tokenize(o, s)

    if ( JITER_LEVEL != 0 ){
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        OPENAI_RESPONESE_ERROR_CONTENT = s
        OPENAI_RESPONESE_ERROR_MSG = "The response output format is incorrect"
        exit(1)
    } else if (( o[ KP_ERROR ] != "" ) || ( o[ KP_OBJECT ] == "\"error\"") || ( o[ KP_MESSAGE ] != "" )) {
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        jmerge_force(o_error, o)
        exit(1)
    }

    JITER_LEVEL = JITER_CURLEN = 0

    if ( PROVIDER_NAME == "ollama" ) {
        openai_display_response_text_stream___ollama_format(o)
        return
    }

    item = o[ KP_CONTENT ]
    response_item = o[ KP_REASONING_CONTENT ]

    if (( item == "null" ) && ( ! chat_str_is_null(response_item) )) {
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

    tool_l = o[ KP_TOOL L ]
    if (tool_l > 0) {
        for (i = 1; i <= tool_l; i++) {
            kp_i            = KP_TOOL SUBSEP "\""i"\""
            # TODO: type: function web_search_preview mcp ...
            kp_tool_name    = kp_i SUBSEP "\"function\"" SUBSEP "\"name\""
            kp_tool_args    = kp_i SUBSEP "\"function\"" SUBSEP "\"arguments\""
            kp_tool_id      = kp_i SUBSEP "\"id\""

            call_id         = o[ kp_tool_id ]

            if ( call_id != "" ) {
                if ( tool_arr[ call_id, "HAS_CHECK" ] == "" ) {
                    openai_stream_parse_tool_function_call( o_tool, tool_arr )
                    tool_arr[ call_id, "HAS_CHECK" ] = "1"
                    ++ tool_arr[ "tool_l" ]
                }
            }

            o_tool[ KP_TOOL ] = "["
            o_tool[ KP_TOOL L ] = (idx = tool_arr[ "tool_l" ])
            jmerge_force___value( o_tool, KP_TOOL SUBSEP "\""idx"\"", o, kp_i )
            tool_arr[ idx, "name" ] = tool_arr[ idx, "name" ] juq(o[ kp_tool_name ])
            tool_arr[ idx, "args" ] = tool_arr[ idx, "args" ] juq(o[ kp_tool_args ])
        }
    }

    choices_l = o[ KP_CHOICES L ]
    created  = o[ KP_CREATED ] # For gh models
    finish_reason = o[ KP_FINISH_REASON ]
    jmerge_force( o_response, o )
    if (((choices_l <= 0) && (created != 0)) || (( finish_reason != "" ) && ( finish_reason != "null" ))) {
        o_response[ KP_FINISH_REASON ] = finish_reason
        o_response[ KP_CONTENT ] = jqu(OPENAI_RESPONSE_CONTENT)
        o_response[ KP_REASONING_CONTENT ] = jqu(OPENAI_RESPONSE_REASONING_CONTENT)
        openai_stream_parse_tool_function_call( o_tool, tool_arr )
        jmerge_force___value(o_response, KP_TOOL, o_tool, KP_TOOL)
        exit(0)
    }
    delete o
}

function openai_stream_parse_tool_function_call(o_tool, tool_arr,             idx, name, args, dir){
    idx = o_tool[ KP_TOOL L ]
    if ( idx <= 0 ) return
    name = tool_arr[ idx, "name" ]
    args = tool_arr[ idx, "args" ]
    o_tool[ KP_TOOL SUBSEP "\""idx"\"" SUBSEP "\"function\"" SUBSEP "\"name\"" ] = jqu(name)
    o_tool[ KP_TOOL SUBSEP "\""idx"\"" SUBSEP "\"function\"" SUBSEP "\"arguments\"" ] = jqu(args)

    if ( OPENAI_CONTENT_DIR != "" ) {
        dir = (OPENAI_CONTENT_DIR "/tool_function/" idx)
        mkdirp( dir )
        print name > (dir "/name")
        print args > (dir "/args")
        print ""   > (dir "/ready")
    }

    print "function: " name " " args
    fflush()
}

function openai_display_response_text_stream___ollama_format(o,             item, finish_status, choices_l){
    item = juq(o[ KP_OLLAMA_CONTENT ])
    OPENAI_RESPONSE_CONTENT = OPENAI_RESPONSE_CONTENT item
    printf( "%s", item )
    fflush()
    jmerge_force( o_response, o )
    choices_l = o[ KP_CHOICES L ]
    finish_status = o_response[ KP_OLLAMA_DONE ]
    if ((choices_l <= 0) || ( finish_status != "false" )) {
        o_response[ KP_OLLAMA_DONE ] = finish_status
        o_response[ KP_OLLAMA_CONTENT ] = jqu(OPENAI_RESPONSE_CONTENT)
        exit(0)
    }
    delete o
}

BEGIN{
    Q2_1                    = SUBSEP "\"1\""
    KP_CHOICES              = Q2_1 SUBSEP "\"choices\""
    KP_DELTA                = KP_CHOICES SUBSEP "\"1\"" SUBSEP "\"delta\""
    KP_CONTENT              = KP_DELTA SUBSEP "\"content\""
    KP_ERROR                = Q2_1 SUBSEP "\"error\""
    KP_OBJECT               = Q2_1 SUBSEP "\"object\""
    KP_MESSAGE              = Q2_1 SUBSEP "\"message\""
    KP_CREATED              = Q2_1 SUBSEP "\"created\""
    KP_REASONING_CONTENT    = KP_DELTA SUBSEP "\"reasoning_content\""
    KP_FINISH_REASON        = KP_CHOICES SUBSEP "\"1\"" SUBSEP "\"finish_reason\""

    KP_OLLAMA_DONE          = Q2_1 SUBSEP "\"done\""
    KP_OLLAMA_CONTENT       = Q2_1 SUBSEP "\"message\"" SUBSEP "\"content\""
    # KP_OLLAMA_TOTAL_DURATION = Q2_1 SUBSEP "\"total_duration\""
    # KP_OLLAMA_LOAD_DURATION = Q2_1 SUBSEP "\"load_duration\""

    KP_TOOL                 = KP_DELTA SUBSEP "\"tool_calls\""
    # stream

    PROVIDER_NAME           = ENVIRON[ "provider_name" ]
    OPENAI_CONTENT_DIR      = ENVIRON[ "content_dir" ]

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
            } else if ($0 ~ "^\"") {
                OPENAI_RESPONESE_IS_ERROR_CONTENT=1
                OPENAI_RESPONESE_EXITCODE=2
                OPENAI_RESPONESE_ERROR_CONTENT = OPENAI_RESPONESE_ERROR_MSG = $0
            } else {
                if ($0 !~ "^ *\\{") $1 = ""
                openai_display_response_text_stream( $0 )
            }
        }
    }
}
