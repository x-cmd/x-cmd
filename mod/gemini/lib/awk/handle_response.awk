
END{

    _current_kp = Q2_1 SUBSEP "\""obj[ Q2_1 L ]"\""
    if ( obj[ _current_kp, "\"error\"" ] != "" ) {
        o_error[ L ] = 1
        jmerge_force___value( o_error, Q2_1, obj, _current_kp )
    }


    if (GEMINI_HAS_RESPONSE_CONTENT == 0) {
        msg_str = "The response content is empty"
        log_error("gemini", msg_str)
        print ""                                    > (GEMINI_CONTENT_DIR "/chat.error.yml")
        exit(1)
    }

    if (o_error[ L ] == 1) {
        msg_str = jstr(o_error)
        log_error("gemini", log_mul_msg( msg_str ))
        print msg_str                               > (GEMINI_CONTENT_DIR "/chat.error.yml")
        _exitcode = o_error[ Q2_1 SUBSEP "\"error\"" SUBSEP "\"code\"" ]
        if (_exitcode ~ "^4") exit(2) # retry abort
        exit(1)
    } else {
        o_response[ L ] = 1
        jmerge_force___value( o_response, Q2_1, obj, _current_kp )
        o_response[ Q2_1 SUBSEP KP_CONTENT ] = jqu( GEMINI_RESPONSE_CONTENT )

        print jstr(o_response)                      > (GEMINI_CONTENT_DIR "/gemini.response.yml" )
        gemini_res_to_cres( o_response, cres_o , SUBSEP "cres"  )
        print cres_dump( cres_o, SUBSEP "cres" )    > (GEMINI_CONTENT_DIR "/chat.response.yml")
    }
}
