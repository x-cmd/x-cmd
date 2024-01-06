END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    OPENAI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    MINION_KP           = SUBSEP "\"1\""

    if ( OPENAI_HAS_RESPONSE_CONTENT == 0 ) {
        log_error("openai", "The response content is empty")
        print                                       > (GEMINI_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else if (OPENAI_RESPONESE_IS_ERROR_CONTENT == 1) {
        msg_str = jstr(o_error)
        log_error("openai", log_mul_msg(jstr(o_error)))
        print msg_str                               > (OPENAI_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else {
        printf "\n"
        #
        print jstr(o_response)                      > (OPENAI_CONTENT_DIR "/openai.response.yml")

        openai_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (OPENAI_CONTENT_DIR "/chat.response.yml")
    }
}
