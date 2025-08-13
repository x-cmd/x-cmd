BEGIN{
    XCMD_CHAT_LOGFILE   = ENVIRON[ "XCMD_CHAT_LOGFILE" ]
    XCMD_CHAT_DRAWFILE  = ENVIRON[ "XCMD_CHAT_DRAWFILE" ]
    GEMINI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    IS_REASONING        = ENVIRON[ "is_reasoning" ]
    DRAW_PREFIX         = "    "
    printf("%s\n", "[START]") >> XCMD_CHAT_DRAWFILE
    printf("%s", DRAW_PREFIX) >> XCMD_CHAT_DRAWFILE
}

END{
    _exitcode = 0
    print "\n---"                                           >> XCMD_CHAT_DRAWFILE

    _current_kp = Q2_1 SUBSEP "\""obj[ Q2_1 L ]"\""
    if ( obj[ _current_kp, "\"error\"" ] != "" ) {
        o_error[ L ] = 1
        jmerge_force___value( o_error, Q2_1, obj, _current_kp )
    }

    if (GEMINI_HAS_RESPONSE_CONTENT == 0) {
        msg_str = "The response content is empty"
        log_error("gemini", msg_str)
        print ""                                    > (GEMINI_CONTENT_DIR "/chat.error.yml")
        _exitcode = 1
    } else if (o_error[ L ] == 1) {
        msg_str = jstr(o_error)
        log_error("gemini", log_mul_msg( msg_str ))
        print msg_str                               > (GEMINI_CONTENT_DIR "/chat.error.yml")
        _exitcode = o_error[ Q2_1 SUBSEP "\"error\"" SUBSEP "\"code\"" ]
        if (_exitcode ~ "^4") _exitcode = 2 # retry abort
        else _exitcode = 1
    } else {
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
        gemini_res_to_cres( o_response, cres_o , SUBSEP "cres", o_tool, Q2_1 )
        print cres_dump( cres_o, SUBSEP "cres" )    > (GEMINI_CONTENT_DIR "/chat.response.yml")

        usage_str = cres_dump_usage( cres_o, SUBSEP "cres" )
        print "[USAGE] " usage_str                              >> XCMD_CHAT_DRAWFILE
        print "[FUNCTION-CALL-COUNT] " int(o_tool[ Q2_1 L ])    >> XCMD_CHAT_LOGFILE
    }

    # print "[EXITCODE] " _exitcode >> XCMD_CHAT_DRAWFILE
    # print "[EXITCODE] " _exitcode >> XCMD_CHAT_LOGFILE
    exit( _exitcode )
}
