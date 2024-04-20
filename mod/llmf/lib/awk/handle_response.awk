END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    LLMF_CONTENT_DIR    = ENVIRON[ "content_dir" ]
    MINION_KP           = SUBSEP "\"1\""

    if ( LLMF_HAS_RESPONSE_CONTENT == 0 ) {
        log_error("llmf", "The response content is empty")
        print                                       > (LLMF_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else if (LLMF_RESPONESE_IS_ERROR_CONTENT == 1) {
        msg_str = jstr(o_error)
        log_error("llmf", log_mul_msg(jstr(o_error)))
        print msg_str                               > (LLMF_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else {
        printf "\n"
        #
        print jstr(o_response)                      > (LLMF_CONTENT_DIR "/llmf.response.yml")

        llmf_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (LLMF_CONTENT_DIR "/chat.response.yml")
    }
}
