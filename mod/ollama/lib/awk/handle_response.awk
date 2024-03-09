END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    OLLAMA_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    MINION_KP           = SUBSEP "\"1\""

    if ( OLLAMA_HAS_RESPONSE_CONTENT == 0 ) {
        log_error("ollama", "The response content is empty")
        print                                       > (OLLAMA_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else if (OLLAMA_RESPONESE_IS_ERROR_CONTENT == 1) {
        msg_str = jstr(o_error)
        log_error("ollama", log_mul_msg(jstr(o_error)))
        print msg_str                               > (OLLAMA_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else {
        printf "\n"
        print jstr(o_response)                      > (OLLAMA_CONTENT_DIR "/ollama.response.yml")

        ollama_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (OLLAMA_CONTENT_DIR "/chat.response.yml")
    }
}
