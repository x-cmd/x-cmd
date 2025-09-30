


BEGIN{
    PROVIDER_NAME       = "gemini"
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    SESSIONDIR          = ENVIRON[ "XCMD_CHAT_SESSION_DIR" ]
    HIST_SESSIONDIR     = ENVIRON[ "XCMD_CHAT_HISTSESSION_DIR" ]
    HIST_SESSIONDIR     = ( HIST_SESSIONDIR != "" ) ? HIST_SESSIONDIR : SESSIONDIR
    QUESTION            = ""
    IS_IMAGE_DATA       = 0
    # IS_REASONING

    Q2_1                = SUBSEP "\"1\""
    MINION_KP           = Q2_1
}
{
    QUESTION = QUESTION $0 "\n"
}

END{
    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE , "gemini")
    mkdirp( SESSIONDIR "/" CHATID )

    creq_dir = (SESSIONDIR "/" CHATID "/chat.request")
    creq_fragfile_create( creq_dir, minion_obj, MINION_KP, PROVIDER_NAME, def_model, QUESTION, CHATID )
    MODEL               = creq_fragfile_unit___get( creq_dir, "model" )
    IS_STREAM           = creq_fragfile_unit___get( creq_dir, "is_stream" )
    IS_REASONING        = creq_fragfile_unit___get( creq_dir, "is_reasoning" )
    IS_STREAM           = chat_tf_bit( IS_STREAM )
    IS_REASONING        = chat_tf_bit( IS_REASONING )

    gemini_request_body_json            = gemini_req_from_creq( creq_dir, CHATID, HIST_SESSIONDIR )
    print gemini_request_body_json      > (SESSIONDIR "/" CHATID "/gemini.request.body.yml")

    print SESSIONDIR "/" CHATID
    print MODEL
    print IS_STREAM
    print IS_REASONING
}
