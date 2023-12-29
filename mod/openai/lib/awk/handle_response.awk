END{
    INTERACTIVE         = ENVIRON[ "interative" ]
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    SESSIONDIR          = ENVIRON[ "___X_CMD_CHAT_SESSION_DIR" ]
    MINION_KP           = SUBSEP "\"1\""

    if (OPENAI_RESPONESE_IS_ERROR_CONTENT == 1) {
        print log_error("openai", log_mul_msg(jstr(o_error)))
        exit(2)
    } else {
        printf "\n"

        minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE, "openai" )
        SESSIONDIR      = SESSIONDIR "/" minion_session( minion_obj, MINION_KP )
        mkdirp( SESSIONDIR "/" CHATID )

        #
        print jstr(o_response)                      > (SESSIONDIR "/" CHATID "/openai.response.yml")

        openai_res_to_cres( o_response, cres_o, SUBSEP "cres" )
        print cres_dump( cres_o, SUBSEP "cres" )    > (SESSIONDIR "/" CHATID "/chat.response.yml")
    }
}
