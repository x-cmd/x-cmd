END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    MOONSHOT_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    MINION_KP           = SUBSEP "\"1\""

    if ( MOONSHOT_HAS_RESPONSE_CONTENT == 0 ) {
        log_error("moonshot", "The response content is empty")
        print                                       > (MOONSHOT_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else if (MOONSHOT_RESPONESE_IS_ERROR_CONTENT == 1) {
        msg_str = jstr(o_error)
        log_error("moonshot", log_mul_msg(jstr(o_error)))
        print msg_str                               > (MOONSHOT_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else {
        printf "\n"
        #
        print jstr(o_response)                      > (MOONSHOT_CONTENT_DIR "/moonshot.response.yml")

        moonshot_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (MOONSHOT_CONTENT_DIR "/chat.response.yml")
    }
}
