END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    OPENAI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    MINION_KP           = SUBSEP "\"1\""

    if ( OPENAI_HAS_RESPONSE_CONTENT == 0 ) {
        msg_str = "The response content is empty"
        log_error("openai", msg_str)
        print ""                                    > (OPENAI_CONTENT_DIR "/chat.error.yml")
        exit(1)
    }
    else if (OPENAI_RESPONESE_IS_ERROR_CONTENT == 1) {
        msg_str = jstr(o_error)
        log_error("openai", log_mul_msg(msg_str))
        print msg_str                               > (OPENAI_CONTENT_DIR "/chat.error.yml")

        type = juq(o_error[ SUBSEP "\"1\"" SUBSEP "\"error\"" SUBSEP "\"type\"" ])
        if (type ~ "^(insufficient_quota|invalid_request_error)$") exit(2)
        exit(1)
    }
    else {
        printf "\n"
        #
        print jstr(o_response)                      > (OPENAI_CONTENT_DIR "/openai.response.yml")

        openai_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (OPENAI_CONTENT_DIR "/chat.response.yml")
    }
}
