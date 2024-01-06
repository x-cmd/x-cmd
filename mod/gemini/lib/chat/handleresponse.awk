
BEGIN{
    INTERACTIVE = ENVIRON[ "interative" ]
    GEMINI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    GEMINI_HAS_RESPONSE_CONTENT = 0
}

{
    GEMINI_HAS_RESPONSE_CONTENT = 1
    jiparse_after_tokenize( gemini_resp_o, $0 )
    print $0                                    > (GEMINI_CONTENT_DIR "/gemini.response.yml" )
}

END{
    gemini_parse_response(gemini_resp_o, ret_o)

    # TODO: errorcode
    if (GEMINI_HAS_RESPONSE_CONTENT == 0) {
        log_error("gemini", "The response content is empty")
        print                                   > (GEMINI_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else if (ret_o[ "code" ] != "") {
        msg_str = jstr(gemini_resp_o)
        log_error("gemini", log_mul_msg( msg_str ))
        print msg_str                           > (GEMINI_CONTENT_DIR "/chat.error.yml")
        exit(2)
    }
    else {
        print ret_o[ "text" ]

        gemini_res_to_cres( gemini_resp_o, cres_o , SUBSEP "cres"  )
        print cres_dump( cres_o, SUBSEP "cres" ) > (GEMINI_CONTENT_DIR "/chat.response.yml")
    }
}
