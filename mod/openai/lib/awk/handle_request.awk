BEGIN{
    PROVIDER_NAME       = ENVIRON[ "provider_name" ]
    PROVIDER_NAME       = (PROVIDER_NAME != "") ? PROVIDER_NAME : "openai"
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    def_model           = ENVIRON[ "def_model" ]
    SESSIONDIR          = ENVIRON[ "XCMD_CHAT_SESSION_DIR" ]
    HIST_SESSIONDIR     = ENVIRON[ "XCMD_CHAT_HISTSESSION_DIR" ]
    HIST_SESSIONDIR     = ( HIST_SESSIONDIR != "" ) ? HIST_SESSIONDIR : SESSIONDIR
    ATTACH_TEXT         = ENVIRON[ "attach_text" ]
    ATTACH_FILELIST     = ENVIRON[ "attach_filelist" ]
    CONTEXT_FILELIST    = ENVIRON[ "context_filelist" ]
    QUESTION            = ""

    Q2_1                = SUBSEP "\"1\""
    MINION_KP           = Q2_1
}
{
    QUESTION = QUESTION $0 "\n"
}
END{
    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE, PROVIDER_NAME )
    mkdirp( SESSIONDIR "/" CHATID )

    creq_fragfile_create( SESSIONDIR, CHATID, HIST_SESSIONDIR, minion_obj, MINION_KP, PROVIDER_NAME, def_model, QUESTION, ATTACH_TEXT, ATTACH_FILELIST, CONTEXT_FILELIST )

    creq_dir = (SESSIONDIR "/" CHATID "/chat.request")
    MODEL               = creq_fragfile_unit___get( creq_dir, "model" )
    IS_STREAM           = creq_fragfile_unit___get( creq_dir, "is_stream" )
    IS_REASONING        = creq_fragfile_unit___get( creq_dir, "is_reasoning" )
    IS_STREAM           = chat_tf_bit( IS_STREAM )
    IS_REASONING        = chat_tf_bit( IS_REASONING )

    openai_request_body_json            = openai_req_from_creq( SESSIONDIR, CHATID, HIST_SESSIONDIR )
    print openai_request_body_json      > (SESSIONDIR "/" CHATID "/" PROVIDER_NAME ".request.body.yml")

    print SESSIONDIR
    print CHATID
    print MODEL
    print IS_STREAM
    print IS_REASONING
}
