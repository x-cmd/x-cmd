BEGIN{
    PROVIDER_NAME       = ENVIRON[ "provider_name" ]
    PROVIDER_NAME       = (PROVIDER_NAME != "") ? PROVIDER_NAME : "openai"
    XCMD_CHAT_LOGFILE   = ENVIRON[ "XCMD_CHAT_LOGFILE" ]
    XCMD_CHAT_DRAWFILE  = ENVIRON[ "XCMD_CHAT_DRAWFILE" ]
    OPENAI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    IS_STREAM           = ENVIRON[ "is_stream" ]
    IS_REASONING        = ENVIRON[ "is_reasoning" ]
    DRAW_PREFIX         = "    "
    printf("%s\n", "[START]") >> XCMD_CHAT_DRAWFILE
    printf("%s", DRAW_PREFIX) >> XCMD_CHAT_DRAWFILE
}

END{
    _exitcode = 0
    print "\n---"                                   >> XCMD_CHAT_DRAWFILE

    if ( OPENAI_HAS_RESPONSE_CONTENT == 0 ) {
        msg_str = "The response content is empty"
        log_error(PROVIDER_NAME, msg_str)
        print ""                                    > (OPENAI_CONTENT_DIR "/chat.error.yml")
        _exitcode = 1
    }
    else if (OPENAI_RESPONESE_IS_ERROR_CONTENT == 1) {
        if ( OPENAI_RESPONESE_ERROR_MSG != "" ) {
            log_error(PROVIDER_NAME, log_mul_msg(OPENAI_RESPONESE_ERROR_MSG))
            msg_str = OPENAI_RESPONESE_ERROR_MSG "\n" OPENAI_RESPONESE_ERROR_CONTENT
            print msg_str                           > (OPENAI_CONTENT_DIR "/chat.error.yml")
            if ( OPENAI_RESPONESE_EXITCODE != "" ) _exitcode = OPENAI_RESPONESE_EXITCODE
            else _exitcode = 1
        } else {
            msg_str = jstr(o_error)
            log_error(PROVIDER_NAME, log_mul_msg(msg_str))
            print msg_str                           > (OPENAI_CONTENT_DIR "/chat.error.yml")

            if (( PROVIDER_NAME == "openai" ) && ( PROVIDER_NAME == "deepseek" )){
                type = juq(o_error[ SUBSEP "\"1\"" SUBSEP "\"error\"" SUBSEP "\"type\"" ])
                if (type ~ "^(insufficient_quota|invalid_request_error)$") _exitcode = 2
                else _exitcode = 1
            } else {
                _exitcode = 2
            }
        }
    }
    else {
        printf "\n"
        #
        print jstr(o_response)                      > (OPENAI_CONTENT_DIR "/" PROVIDER_NAME ".response.yml")

        openai_res_to_cres( o_response, cres_o, SUBSEP "cres", o_tool, Q2_1 )
        print cres_dump( cres_o, SUBSEP "cres" )    > (OPENAI_CONTENT_DIR "/chat.response.yml")

        usage_str = cres_dump_usage( cres_o, SUBSEP "cres" )
        print "[USAGE] " usage_str                              >> XCMD_CHAT_DRAWFILE
        print "[FUNCTION-CALL-COUNT] " int(o_tool[ Q2_1 L ])    >> XCMD_CHAT_LOGFILE
    }

    # print "[EXITCODE] " _exitcode >> XCMD_CHAT_DRAWFILE
    # print "[EXITCODE] " _exitcode >> XCMD_CHAT_LOGFILE
    exit( _exitcode )
}
