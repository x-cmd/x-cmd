


BEGIN{
    PROVIDER_NAME       = "gemini"
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    SESSIONDIR          = ENVIRON[ "XCMD_CHAT_SESSION_DIR" ]
    HIST_SESSIONDIR     = ENVIRON[ "XCMD_CHAT_HISTORY_SESSION_DIR" ]
    HIST_SESSIONDIR     = ( HIST_SESSIONDIR != "" ) ? HIST_SESSIONDIR : SESSIONDIR
    QUESTION            = ""
    IMAGELIST           = ""
    IS_IMAGE_DATA       = 0
    # IS_REASONING

    Q2_1                = SUBSEP "\"1\""
    MINION_KP           = Q2_1
    CREQ_KP             = Q2_1
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
    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE , "gemini")
    MODEL               = minion_model( minion_obj, MINION_KP )
    IS_STREAM           = minion_is_stream( minion_obj, MINION_KP, MODEL )
    IS_REASONING        = minion_is_reasoning( minion_obj, MINION_KP )
    mkdirp( SESSIONDIR "/" CHATID )

    creq_create( creq_obj, SUBSEP "creq", minion_obj, MINION_KP, PROVIDER_NAME, MODEL, QUESTION, CHATID, IMAGELIST, IS_STREAM, IS_REASONING )

    gemini_request_body_json            = gemini_req_from_creq( creq_obj, SUBSEP "creq", CHATID, HIST_SESSIONDIR )    # Notice: it's must before creq_create
    print gemini_request_body_json      > (SESSIONDIR "/" CHATID "/gemini.request.body.yml")
    chat_request_json                   = creq_dump( creq_obj, SUBSEP "creq")
    print chat_request_json             > (SESSIONDIR "/" CHATID "/chat.request.yml")

    print SESSIONDIR "/" CHATID
    print MODEL
    print IS_STREAM
    print IS_REASONING
}


# {
#   "contents": [
#     {
#       text:
#       role:
#     }
#   ],

# {"contents":[{"parts":[{"text":"Write a story about a magic backpack"}]}]}
