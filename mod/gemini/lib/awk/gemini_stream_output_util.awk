
BEGIN{
    GEMINI_RESPONSE_CONTENT = ""
    GEMINI_HAS_RESPONSE_CONTENT = 0

    KP_PART = "\"candidates\"" SUBSEP "\"1\"" SUBSEP "\"content\"" SUBSEP "\"parts\""
    KP_CONTENT = KP_PART SUBSEP "\"1\"" SUBSEP "\"text\""
    Q2_1 = SUBSEP "\"1\""
}

function gemini_parse_response_data( text, obj,       _arr, _arrl, i, _current_kp, j, _part_l, _kp_part_idx, _kp_part_text, _kp_part_func){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse( obj, _arr[i] )
        # debug(  ( JITER_LEVEL != 1 ) ":" ( JITER_CURLEN <= 0) ":" ( _arr[i] !~ "^[,:]?$") "\tJITER_CURLEN:" JITER_CURLEN "\titem:" _arr[i] )
        if (( JITER_LEVEL != 1 ) || ( JITER_CURLEN <= 0) || ( _arr[i] ~ "^[,:]?$")) continue

        _current_kp = Q2_1 SUBSEP "\""JITER_CURLEN"\""
        if (( JITER_CURLEN == 1 ) && ( obj[ _current_kp, "\"error\"" ] != "" )) {
            o_error[ L ] = 1
            jmerge_force___value( o_error, Q2_1, obj, _current_kp )
            continue
        } else if ( JITER_CURLEN != 1 ) {
            jmerge_force___value( o_response, Q2_1 SUBSEP "\"1\"", o_response, Q2_1 SUBSEP "\""JITER_CURLEN"\"" )
        }

        _part_l = obj[ _current_kp, KP_PART L ]
        for (j=1; j<=_part_l; ++j){
            _kp_part_idx    = _current_kp SUBSEP KP_PART SUBSEP "\""j"\""
            _kp_part_text   = _kp_part_idx SUBSEP "\"text\""
            if ( obj[ _kp_part_text ] != "" ) {
                gemini_display_response_text_stream( obj, _kp_part_text )
            }
            _kp_part_func   = _kp_part_idx SUBSEP "\"functionCall\""
            if ( obj[ _kp_part_func ] != "" ) {
                gemini_stream_parse_tool_function_call( obj, _kp_part_func )
            }
        }
    }
}

function gemini_display_response_text_stream( obj, kp,          str ){
    str =  juq(obj[ kp ])
    if ( str == "" ) return
    GEMINI_RESPONSE_CONTENT = GEMINI_RESPONSE_CONTENT str
    chat_record_str_to_drawfile( str, DRAW_PREFIX )
}

function gemini_stream_parse_tool_function_call( obj, kp,        name, args, dir, idx){

    name = juq( obj[ kp, "\"name\"" ] )
    args = jstr0( obj, kp SUBSEP "\"args\"", " " )
    if ( name == "" ) return

    o_tool[ Q2_1 ] = "["
    jlist_put( o_tool, Q2_1, "{" )
    idx = o_tool[ Q2_1 L ]
    jdict_put( o_tool, Q2_1 SUBSEP "\""idx"\"", "\"index\"", idx)
    jdict_put( o_tool, Q2_1 SUBSEP "\""idx"\"", "\"name\"", jqu(name))
    jdict_put( o_tool, Q2_1 SUBSEP "\""idx"\"", "\"arguments\"", jqu(args))

    if ( GEMINI_CONTENT_DIR != "" ) {
        dir = (GEMINI_CONTENT_DIR "/function-call/" idx)
        mkdirp( dir )
        print name > (dir "/name")
        print args > (dir "/arg")
        print "[FUNCTION-CALL] " idx >> XCMD_CHAT_LOGFILE
    }

    fflush()
}

($0 != ""){
    GEMINI_HAS_RESPONSE_CONTENT = 1
    gemini_parse_response_data( $0, obj )
}
