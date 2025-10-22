BEGIN{
    XCMD_CHAT_ENACTALL_LOGFILE   = ENVIRON[ "XCMD_CHAT_ENACTALL_LOGFILE" ]
    XCMD_CHAT_ENACTALL_DRAWFILE  = ENVIRON[ "XCMD_CHAT_ENACTALL_DRAWFILE" ]
    GEMINI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    IS_STREAM           = ENVIRON[ "is_stream" ]
    IS_REASONING        = ENVIRON[ "is_reasoning" ]
    IS_DEBUG            = ENVIRON[ "is_debug" ]
    DRAW_PREFIX         = "    "
    printf("%s\n", "[MODEL-RES-START]") >> XCMD_CHAT_ENACTALL_DRAWFILE
    printf("%s", DRAW_PREFIX) >> XCMD_CHAT_ENACTALL_DRAWFILE
}

END{
    _exitcode = 0
    print "\n---"       >> XCMD_CHAT_ENACTALL_DRAWFILE

    if (GEMINI_HAS_RESPONSE_CONTENT == 0) {
        msg_str = "The response content is empty"
        log_error("gemini", msg_str)
        print ""                                    > (GEMINI_CONTENT_DIR "/chat.error.yml")
        _exitcode = 1
    } else if ( GEMINI_RESPONSE_IS_ERROR_CONTENT == 1 ) {
        if ( GEMINI_RESPONSE_ERROR_MSG != "" ) {
            log_error("gemini", log_mul_msg( GEMINI_RESPONSE_ERROR_MSG ))
            msg_str = GEMINI_RESPONSE_ERROR_MSG "\n" GEMINI_RESPONSE_ERROR_CONTENT
            print msg_str                           > (GEMINI_CONTENT_DIR "/chat.error.yml")
            if ( GEMINI_RESPONSE_EXITCODE != "" ) _exitcode = GEMINI_RESPONSE_EXITCODE
            else _exitcode = 1
        } else {
            msg_str = jstr(o_error)
            log_error("gemini", log_mul_msg( msg_str ))
            print msg_str                           > (GEMINI_CONTENT_DIR "/chat.error.yml")
            if ( o_error[ Q2_1 SUBSEP "\"error\"" SUBSEP "\"code\"" ] ~ "^4" ) _exitcode = 2 # retry abort
            else _exitcode = 1
        }
    } else {
        _current_kp = Q2_1
        if ( IS_STREAM == true ) _current_kp = _current_kp SUBSEP "\""JITER_CURLEN"\""

        o_response[ L ] = 1
        jmerge_force___value( o_response, Q2_1, obj, _current_kp )

        o_response[ Q2_1 SUBSEP KP_PART SUBSEP "\"1\"" SUBSEP "\"text\"" ] = jqu( GEMINI_RESPONSE_CONTENT )
        if ( GEMINI_RESPONSE_REASONING_CONTENT != "" ) {
            jdict_rm(  o_response, Q2_1 SUBSEP KP_PART SUBSEP "\"1\"", "\"thought\"" )
            jlist_put( o_response, Q2_1 SUBSEP KP_PART, "{" )
            jdict_put( o_response, Q2_1 SUBSEP KP_PART SUBSEP "\"2\"", "\"text\"", jqu(GEMINI_RESPONSE_REASONING_CONTENT) )
            jdict_put( o_response, Q2_1 SUBSEP KP_PART SUBSEP "\"2\"", "\"thought\"", "true" )
        }

        print jstr(o_response)                      > (GEMINI_CONTENT_DIR "/gemini.response.yml" )

        cres_dir = (GEMINI_CONTENT_DIR "/chat.response")
        creq_dir = (GEMINI_CONTENT_DIR "/chat.request")
        gemini_res_to_cres( o_response, cres_dir, creq_dir, o_tool, Q2_1 )

        usage_str = cres_dump_usage( cres_dir, creq_dir )
        print "[MODEL-USAGE] " usage_str                        >> XCMD_CHAT_ENACTALL_DRAWFILE
        print "[FUNCTION-CALL-COUNT] " int(o_tool[ Q2_1 L ])    >> XCMD_CHAT_ENACTALL_LOGFILE
    }

    exit( _exitcode )
}
