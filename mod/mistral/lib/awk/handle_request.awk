BEGIN{
    QUESTION            = "" # ENVIRON[ "BODY" ]
    IMAGELIST           = ""
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    SESSIONDIR          = ENVIRON[ "___X_CMD_CHAT_SESSION_DIR" ]
    def_model           = ENVIRON[ "def_model" ]
    MINION_KP           = SUBSEP "\"1\""
}
{
    if ($0 == "\001\002\003:image") {
        while( getline ) {
            IMAGELIST = IMAGELIST $0 "\n"
        }
    } else {
        QUESTION = QUESTION $0 "\n"
    }
}
END{

    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE, "mistral" )
    TYPE                = minion_type( minion_obj, MINION_KP )
    MODEL               = minion_model( minion_obj, MINION_KP, def_model )
    HISTORY_NUM         = minion_history_num( minion_obj, MINION_KP )
    SESSIONDIR          = SESSIONDIR "/" minion_session( minion_obj, MINION_KP )
    mkdirp( SESSIONDIR "/" CHATID )

    chat_history_load( history_obj, SESSIONDIR, minion_history_num( minion_obj, MINION_KP ))


    #
    creq_create( creq_obj, minion_obj, MINION_KP, TYPE, MODEL, QUESTION, CHATID, HISTORY_NUM )
    chat_request_json                   = chat_str_replaceall( creq_dump( creq_obj ) )
    print chat_request_json             > (SESSIONDIR "/" CHATID "/chat.request.yml")

    mistral_request_body_json            = mistral_req_from_creq( history_obj, minion_obj, MINION_KP, def_model )
    mistral_request_body_json            = chat_str_replaceall( mistral_request_body_json )
    print mistral_request_body_json      > (SESSIONDIR "/" CHATID "/mistral.request.body.yml")

    print SESSIONDIR "/" CHATID
    print MODEL
    # print mistral_request_body_json
}
