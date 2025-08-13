function openai_record_response_text_stream( s,       o ){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    if (s !~ "^ *\\{") return
    jiparse_after_tokenize(o, s)

    if ( JITER_LEVEL != 0 ){
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        OPENAI_RESPONESE_ERROR_CONTENT = s
        OPENAI_RESPONESE_ERROR_MSG = "The response output format is incorrect"
        exit(1)
    }

    openai_record_response___text_content(o)
}

function openai_record_response_text_nonstream( o, s ) {
    jiparse_after_tokenize(o, s)
    if ( JITER_LEVEL != 0 ) return
    openai_record_response___text_content(o)
}

function openai_record_response___text_content( o,        item, response_item, finish_reason, choices_l, tool_l, tool_index, tool_last_index, kp_i, kp_tool_name, kp_tool_args, kp_tool_id, call_id, i, idx ){
    if (( o[ KP_ERROR ] != "" ) || ( o[ KP_OBJECT ] == "\"error\"") || (( PROVIDER_NAME != "ollama" ) && ( o[ KP_OLLAMA_MESSAGE ] != "" ))) {
        OPENAI_RESPONESE_IS_ERROR_CONTENT = 1
        jmerge_force(o_error, o)
        exit(1)
    }

    JITER_LEVEL = JITER_CURLEN = 0

    if ( PROVIDER_NAME == "ollama" ) {
        openai_record_response___text_content_ollama_format(o)
        return
    }

    if ( o[ KP_MESSAGE ] == "{" ) {
        jdict_put(o, KP_CHOICES SUBSEP "\"1\"", "\"delta\"", "{" )
        jmerge_force___value(o, KP_DELTA, o, KP_MESSAGE)
        jdict_rm( o, KP_CHOICES SUBSEP "\"1\"", "\"message\"" )
    }

    item = o[ KP_DELTA_CONTENT ]
    response_item = o[ KP_DELTA_REASONING_CONTENT ]

    if (( item == "null" ) && ( ! chat_str_is_null(response_item) )) {
        if ( OPENAI_RESPONSE_HAS_REASONING  == 0 ) {
            if ( IS_REASONING == true ) chat_record_str_to_drawfile( "---------- REASONING BEGIN ----------\n", DRAW_PREFIX )
        }
        OPENAI_RESPONSE_HAS_REASONING = 1
        response_item = juq(o[ KP_DELTA_REASONING_CONTENT ])
        OPENAI_RESPONSE_REASONING_CONTENT = OPENAI_RESPONSE_REASONING_CONTENT response_item
        if ( IS_REASONING == true ) chat_record_str_to_drawfile( response_item, DRAW_PREFIX )

    } else if (OPENAI_RESPONSE_HAS_REASONING == 1){
        OPENAI_RESPONSE_HAS_REASONING = 0
        if ( IS_REASONING == true ) chat_record_str_to_drawfile( "\n---------- REASONING END ----------\n", DRAW_PREFIX )
    }

    if ( ! chat_str_is_null(item) ) {
        item = juq(item)
        OPENAI_RESPONSE_CONTENT = OPENAI_RESPONSE_CONTENT item
        chat_record_str_to_drawfile( item, DRAW_PREFIX )
    }

    tool_l = o[ KP_DELTA_TOOL L ]
    if (tool_l > 0) {
        for (i = 1; i <= tool_l; i++) {
            kp_i            = KP_DELTA_TOOL SUBSEP "\""i"\""
            # TODO: type: function web_search_preview mcp ...
            kp_tool_name    = kp_i SUBSEP "\"function\"" SUBSEP "\"name\""
            kp_tool_args    = kp_i SUBSEP "\"function\"" SUBSEP "\"arguments\""
            kp_tool_id      = kp_i SUBSEP "\"id\""

            call_id         = o[ kp_tool_id ]

            if ( call_id != "" ) {
                if ( tool_arr[ call_id, "HAS_CHECK" ] == "" ) {
                    openai_record_response___tool_call( o_tool, tool_arr )
                    tool_arr[ call_id, "HAS_CHECK" ] = "1"
                    ++ tool_arr[ "tool_l" ]
                }
            }

            o_tool[ Q2_1 ] = "["
            o_tool[ Q2_1 L ] = (idx = tool_arr[ "tool_l" ])
            jmerge_force___value( o_tool, Q2_1 SUBSEP "\""idx"\"", o, kp_i )
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
        o_response[ KP_DELTA_CONTENT ] = jqu(OPENAI_RESPONSE_CONTENT)
        o_response[ KP_DELTA_REASONING_CONTENT ] = jqu(OPENAI_RESPONSE_REASONING_CONTENT)
        openai_record_response___tool_call( o_tool, tool_arr )
        jmerge_force___value(o_response, KP_DELTA_TOOL, o_tool, Q2_1)
        exit(0)
    }
    delete o
}

function openai_record_response___tool_call(o_tool, tool_arr,             idx, name, args, dir){
    idx = o_tool[ Q2_1 L ]
    if ( idx <= 0 ) return
    name = tool_arr[ idx, "name" ]
    args = tool_arr[ idx, "args" ]
    o_tool[ Q2_1 SUBSEP "\""idx"\"" SUBSEP "\"function\"" SUBSEP "\"name\"" ] = jqu(name)
    o_tool[ Q2_1 SUBSEP "\""idx"\"" SUBSEP "\"function\"" SUBSEP "\"arguments\"" ] = jqu(args)

    if ( XCMD_CHAT_LOGFILE != "" ) {
        dir = (OPENAI_CONTENT_DIR "/function-call/" idx)
        mkdirp( dir )
        print name > (dir "/name")
        print args > (dir "/arg")

        print "[FUNCTION-CALL] " idx >> XCMD_CHAT_LOGFILE
    }

    fflush()
}

function openai_record_response___text_content_ollama_format(o,             item, finish_status, choices_l, tool_l, i, kp_i, kp_tool_name, kp_tool_args, call_id){
    item = o[ KP_OLLAMA_CONTENT ]
    if ( ! chat_str_is_null(item) ) {
        item = juq(item)
        OPENAI_RESPONSE_CONTENT = OPENAI_RESPONSE_CONTENT item
        chat_record_str_to_drawfile( item, DRAW_PREFIX )
    }

    tool_l = o[ KP_OLLAMA_TOOL L ]
    if (tool_l > 0) {
        for (i = 1; i <= tool_l; i++) {
            kp_i            = KP_OLLAMA_TOOL SUBSEP "\""i"\""
            kp_tool_name    = kp_i SUBSEP "\"function\"" SUBSEP "\"name\""
            kp_tool_args    = kp_i SUBSEP "\"function\"" SUBSEP "\"arguments\""
            call_id         = i
            ++ tool_arr[ "tool_l" ]
            o_tool[ Q2_1 ] = "["
            o_tool[ Q2_1 L ] = call_id
            jmerge_force___value( o_tool, Q2_1 SUBSEP "\""call_id"\"", o, kp_i )
            tool_arr[ call_id, "name" ] = juq(o[ kp_tool_name ])
            if ( o[ kp_tool_args ] == "{" ) tool_arr[ call_id, "args" ] = jstr0(o, kp_tool_args, " ")
            openai_record_response___tool_call( o_tool, tool_arr )
        }
    }

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

    KP_DELTA                        = KP_CHOICES SUBSEP "\"1\"" SUBSEP "\"delta\""
    KP_MESSAGE                      = KP_CHOICES SUBSEP "\"1\"" SUBSEP "\"message\""
    KP_DELTA_CONTENT                = KP_DELTA SUBSEP "\"content\""
    KP_DELTA_REASONING_CONTENT      = KP_DELTA SUBSEP "\"reasoning_content\""
    KP_DELTA_TOOL                   = KP_DELTA SUBSEP "\"tool_calls\""

    KP_ERROR                = Q2_1 SUBSEP "\"error\""
    KP_OBJECT               = Q2_1 SUBSEP "\"object\""
    KP_CREATED              = Q2_1 SUBSEP "\"created\""
    KP_FINISH_REASON        = KP_CHOICES SUBSEP "\"1\"" SUBSEP "\"finish_reason\""

    KP_OLLAMA_DONE          = Q2_1 SUBSEP "\"done\""
    KP_OLLAMA_MESSAGE       = Q2_1 SUBSEP "\"message\""
    KP_OLLAMA_CONTENT       = KP_OLLAMA_MESSAGE SUBSEP "\"content\""
    KP_OLLAMA_TOOL          = KP_OLLAMA_MESSAGE SUBSEP "\"tool_calls\""
    # KP_OLLAMA_TOTAL_DURATION = Q2_1 SUBSEP "\"total_duration\""
    # KP_OLLAMA_LOAD_DURATION = Q2_1 SUBSEP "\"load_duration\""

    # stream

    OPENAI_RESPONSE_CONTENT = ""
    OPENAI_RESPONSE_REASONING_CONTENT = ""
    OPENAI_RESPONSE_HAS_REASONING = 0
    OPENAI_HAS_RESPONSE_CONTENT = 0
}

# { print $0 >> (OPENAI_CONTENT_DIR "/chat.running.yml"); }
($0 != ""){
    if ( IS_STREAM == true ) {
        if ($0 !~ "^:"){
            if ( OPENAI_HAS_RESPONSE_CONTENT != 0 ) {
                if (OPENAI_RESPONESE_IS_ERROR_CONTENT==1) {
                    jiparse_after_tokenize( o_error, $0 )
                    next
                } else {
                    if ($0 !~ "^ *\\{") $1 = ""
                    openai_record_response_text_stream( $0 )
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
                    openai_record_response_text_stream( $0 )
                }
            }
        }
    } else {
        openai_record_response_text_nonstream( o, $0 )
        OPENAI_HAS_RESPONSE_CONTENT = 1
    }
}
