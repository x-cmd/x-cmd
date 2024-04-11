END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    MISTRAL_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    MINION_KP           = SUBSEP "\"1\""

    if ( MISTRAL_HAS_RESPONSE_CONTENT == 0 ) {
        log_error("mistral", "The response content is empty")
        print                                       > (MISTRAL_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else if (MISTRAL_RESPONESE_IS_ERROR_CONTENT == 1) {
        msg_str = jstr(o_error)
        log_error("mistral", log_mul_msg(jstr(o_error)))
        print msg_str                               > (MISTRAL_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else {
        printf "\n"
        #
        print jstr(o_response)                      > (MISTRAL_CONTENT_DIR "/mistral.response.yml")

        mistral_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (MISTRAL_CONTENT_DIR "/chat.response.yml")
    }
}
