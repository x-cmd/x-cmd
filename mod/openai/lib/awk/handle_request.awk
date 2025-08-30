BEGIN{
    PROVIDER_NAME       = ENVIRON[ "provider_name" ]
    PROVIDER_NAME       = (PROVIDER_NAME != "") ? PROVIDER_NAME : "openai"
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    def_model           = ENVIRON[ "def_model" ]
    SESSIONDIR          = ENVIRON[ "XCMD_CHAT_SESSION_DIR" ]
    HIST_SESSIONDIR     = ENVIRON[ "XCMD_CHAT_HISTORY_SESSION_DIR" ]
    HIST_SESSIONDIR     = ( HIST_SESSIONDIR != "" ) ? HIST_SESSIONDIR : SESSIONDIR
    QUESTION            = ""
    IMAGELIST           = ""
    Q2_1                = SUBSEP "\"1\""
    MINION_KP           = Q2_1
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
    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE, PROVIDER_NAME )
    MODEL               = minion_model( minion_obj, MINION_KP, def_model )
    IS_STREAM           = minion_is_stream( minion_obj, MINION_KP, MODEL )
    IS_REASONING        = minion_is_reasoning( minion_obj, MINION_KP )
    mkdirp( SESSIONDIR "/" CHATID )

    creq_create( creq_obj, SUBSEP "creq", minion_obj, MINION_KP, PROVIDER_NAME, MODEL, QUESTION, CHATID, IMAGELIST, IS_STREAM, IS_REASONING )

    openai_request_body_json            = openai_req_from_creq( creq_obj, SUBSEP "creq", CHATID, HIST_SESSIONDIR )
    print openai_request_body_json      > (SESSIONDIR "/" CHATID "/" PROVIDER_NAME ".request.body.yml")
    chat_request_json                   = creq_dump( creq_obj, SUBSEP "creq" )
    print chat_request_json             > (SESSIONDIR "/" CHATID "/chat.request.yml")

    print SESSIONDIR "/" CHATID
    print MODEL
    print IS_STREAM
    print IS_REASONING
}
