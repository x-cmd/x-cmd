BEGIN{
    PROVIDER_NAME       = ENVIRON[ "provider_name" ]
    CHATID              = ENVIRON[ "chatid" ]
    MINION_JSON_CACHE   = ENVIRON[ "minion_json_cache" ]
    def_model           = ENVIRON[ "def_model" ]
    Q2_1                = SUBSEP "\"1\""
    MINION_KP           = Q2_1

    ITEMNAME            = ENVIRON[ "itemname" ]

    minion_load_from_jsonfile( minion_obj, MINION_KP, MINION_JSON_CACHE, PROVIDER_NAME )

    if ( ITEMNAME == "name" ) {
        print minion_name( minion_obj, MINION_KP )
    } else if ( ITEMNAME == "session" ) {
        print minion_session( minion_obj, MINION_KP )
    } else if ( ITEMNAME == "maxtoken" ) {
        print minion_maxtoken( minion_obj, MINION_KP )
    } else if ( ITEMNAME == "history_num" ) {
        print minion_history_num( minion_obj, MINION_KP )
    }
}
