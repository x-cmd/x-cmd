


BEGIN{

    CHATID            = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE = ENVIRON[ "minion_json_cache" ]
    SESSIONDIR        = ENVIRON[ "___X_CMD_CHAT_SESSION_DIR" ]
    QUESTION          = ""
    IMAGELIST         = ""
    IS_IMAGE_DATA     = 0

    Q2_1               = SUBSEP "\"1\""
    MINION_KP          = Q2_1
    CREQ_KP            = Q2_1
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
    TYPE                = minion_type( minion_obj, MINION_KP )
    MODEL               = minion_model( minion_obj, MINION_KP )
    HISTORY_NUM         = minion_history_num( minion_obj, MINION_KP )
    SESSIONDIR          = SESSIONDIR "/" minion_session( minion_obj, MINION_KP )
    TOOL_JSTR           = minion_tool_jstr( minion_obj, MINION_KP )
    mkdirp( SESSIONDIR "/" CHATID )

    chat_history_load( history_obj, SESSIONDIR, HISTORY_NUM, CHATID)

    creq_create( creq_obj, minion_obj, MINION_KP,     TYPE, MODEL, QUESTION, CHATID, HISTORY_NUM, IMAGELIST, TOOL_JSTR)
    chat_request_json                   = chat_str_replaceall( creq_dump( creq_obj))

    gemini_request_body_json            = gemini_req_from_creq( history_obj, minion_obj,  QUESTION, creq_obj, CREQ_KP)    # Notice: it's must before creq_create
    gemini_request_body_json            = chat_str_replaceall(  gemini_request_body_json)


    print chat_request_json             > (SESSIONDIR "/" CHATID "/chat.request.yml")

    print gemini_request_body_json      > (SESSIONDIR "/" CHATID "/gemini.request.body.yml")

    print SESSIONDIR "/" CHATID
    print MODEL
}


# {
#   "contents": [
#     {
#       text:
#       role:
#     }
#   ],

# {"contents":[{"parts":[{"text":"Write a story about a magic backpack"}]}]}
