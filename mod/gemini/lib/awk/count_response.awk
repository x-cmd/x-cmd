function gemini_parse_count_response(gemini_resp_count_o, ret_o,        _kp, str, code){
    _kp = SUBSEP "\"1\"" S "\"totalTokens\""
    str =  gemini_resp_count_o[ _kp ]
    code = gemini_resp_o[ Q2_1 S "\"error\"" S "\"code\"" ]
    ret_o[ "text" ] = str
    ret_o[ "code" ] = code
}

BEGIN{
    GEMINI_HAS_RESPONSE_CONTENT = 0
}

{
   GEMINI_HAS_RESPONSE_CONTENT = 1
   jiparse_after_tokenize( gemini_resp_count_o, $0 )
}


END{
    gemini_parse_count_response(gemini_resp_count_o, ret_o)

    if (GEMINI_HAS_RESPONSE_CONTENT == 0) {
    log_error("gemini", "The response content is empty")
    exit(2)
    }
    else if (ret_o[ "code" ] != "") {
        msg_str = jstr(gemini_resp_count_o)
        log_error("gemini", log_mul_msg( msg_str ))
        exit(2)
    }
    else {
        print "Total tokens: "ret_o[ "text" ]
    }
}