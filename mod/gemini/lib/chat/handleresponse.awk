
BEGIN{
    INTERACTIVE = ENVIRON[ "interative" ]
    CHATID      = ENVIRON[ "chatid" ]
    CACHE_FILE  = ENVIRON[ "cache_file" ]

}

{
    jiparse_after_tokenize( gemini_resp_o, $0 )
    print $0 > CACHE_FILE
    if(INTERACTIVE == "") print $0
}

END{
    SESSIONDIR      =  ENVIRON[ "___X_CMD_CHAT_SESSION_DIR" ]
    CHATID          =  ENVIRON[ "chatid" ]

    SESSIONDIR      = SESSIONDIR "/" minion_session( minion_obj, MINION_KP )
    if(INTERACTIVE == 1) print gemini_display_response_text(gemini_resp_o)

    gemini_res_to_cres( gemini_resp_o, cres_o , SUBSEP "cres" , SESSIONDIR, CHATID )
    print cres_dump( cres_o, SUBSEP "cres" ) > (SESSIONDIR "/" CHATID "/chat.response.yml")
}
