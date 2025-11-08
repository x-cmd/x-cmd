
function cres_fragfile_unit___set( dir, name, str ) {
    if ( str != "" ) {
        print str > ( dir "/" name )
        fflush()
    }
    cres_obj[ dir, name, "loaded" ] = true
    cres_obj[ dir, name ] = str
}

function cres_fragfile_unit___get( dir, name,               str ) {
    if ( cres_obj[ dir, name, "loaded" ] == true ) return cres_obj[ dir, name ]
    cres_obj[ dir, name, "loaded" ] = true
    fp = ( dir "/" name )
    if ( (fp == "") || (fp == "/") ) return
    str = cat( fp )
    if ( cat_is_filenotfound() ) return
    cres_obj[ dir, name ] = str
    return str
}

function cres_dump_usage( session_dir, chatid,           cres_dir, creq_dir, total_token, obj_usage ){
    cres_dir = chat_get_cres_dir( session_dir, chatid )
    creq_dir = chat_get_creq_dir( session_dir, chatid )
    total_token       = int( cres_fragfile_unit___get( cres_dir, "usage_total_token" ) )
    if ( total_token <= 0 ) return

    jlist_put(obj_usage, "", "{" )
    jdict_put(obj_usage, Q2_1, "\"usage\"", "{" )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"", "\"input\"", "{" )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"token\"",           int( cres_fragfile_unit___get( cres_dir, "usage_input_token" ) ) )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"cache_token\"",     int( cres_fragfile_unit___get( cres_dir, "usage_input_cache_token" ) ) )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"charlen\"",         int( cres_fragfile_unit___get( creq_dir, "usage_input_charlen" ) ) )

    v = creq_fragfile_unit___get( creq_dir, "usage_input_ratio_system" )
    if ( v != "" ) jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"ratio_system\"",   v )
    v = creq_fragfile_unit___get( creq_dir, "usage_input_ratio_history" )
    if ( v != "" ) jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"ratio_history\"",  v )
    v = creq_fragfile_unit___get( creq_dir, "usage_input_ratio_other" )
    if ( v != "" ) jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"ratio_other\"",    v )
    v = creq_fragfile_unit___get( creq_dir, "usage_input_ratio_cache" )
    if ( v != "" ) jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"input\"", "\"ratio_cache\"",    v )

    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"", "\"output\"", "{" )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"output\"", "\"token\"",          int( cres_fragfile_unit___get( cres_dir, "usage_output_token" ) ) )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"output\"", "\"thought_token\"",  int( cres_fragfile_unit___get( cres_dir, "usage_output_thought_token" ) ) )


    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"", "\"total\"", "{" )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"total\"", "\"token\"",           total_token )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"total\"", "\"price\"",           cres_fragfile_unit___get( cres_dir, "usage_total_price" ) )

    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"", "\"session\"", "{" )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"session\"", "\"token\"",         int( cres_fragfile_unit___get( cres_dir, "usage_session_total_token" ) ) )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"session\"", "\"price\"",         cres_fragfile_unit___get( cres_dir, "usage_session_total_price" ) )

    jdict_put(obj_usage, Q2_1, "\"model\"",     jqu(cres_fragfile_unit___get( creq_dir, "model" )) )
    jdict_put(obj_usage, Q2_1, "\"provider\"",  jqu(cres_fragfile_unit___get( creq_dir, "provider" )) )
    return jstr0( obj_usage, Q2_1, " ")
}
