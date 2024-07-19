
BEGIN{
    INTERACTIVE = ENVIRON[ "interative" ]
    GEMINI_CONTENT_DIR  = ENVIRON[ "content_dir" ]
    GEMINI_RESPONSE_CONTENT = ""
    GEMINI_HAS_RESPONSE_CONTENT = 0

    KP_CONTENT = "\"candidates\"" SUBSEP "\"1\"" SUBSEP "\"content\"" SUBSEP "\"parts\"" SUBSEP "\"1\"" SUBSEP "\"text\""
    Q2_1 = SUBSEP "\"1\""
}

function gemini_parse_response_data( text, obj, o_error,       _arr, _arrl, i, _current_kp){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse( obj, _arr[i] )
        # debug(  ( JITER_LEVEL != 1 ) ":" ( JITER_CURLEN <= 0) ":" ( _arr[i] !~ "^[,:]?$") "\tJITER_CURLEN:" JITER_CURLEN "\titem:" _arr[i] )
        if (( JITER_LEVEL != 1 ) || ( JITER_CURLEN <= 0) || ( _arr[i] ~ "^[,:]?$")) continue

        _current_kp = Q2_1 SUBSEP "\""JITER_CURLEN"\""
        if (( JITER_CURLEN == 1 ) && ( obj[ _current_kp, "\"error\"" ] != "" )) {
            o_error[ L ] = 1
            cp( o_error, Q2_1, obj, _current_kp )
            continue
        }
        gemini_dsiplay_response_text_stream( obj, _current_kp )
    }
}

function gemini_dsiplay_response_text_stream( obj, kp,      _kp, str ){
    _kp = kp SUBSEP KP_CONTENT

    str =  juq(obj[ _kp ])
    GEMINI_RESPONSE_CONTENT = GEMINI_RESPONSE_CONTENT str
    printf( "%s", str )
    fflush()
}

($0 != ""){
    GEMINI_HAS_RESPONSE_CONTENT = 1
    gemini_parse_response_data( $0, obj, o_error )
    print $0                                        > (GEMINI_CONTENT_DIR "/gemini.response.yml" )
}

END{

    _current_kp = Q2_1 SUBSEP "\""obj[ Q2_1 L ]"\""
    if ( obj[ _current_kp, "\"error\"" ] != "" ) {
        o_error[ L ] = 1
        cp( o_error, Q2_1, obj, _current_kp )
    }


    if (GEMINI_HAS_RESPONSE_CONTENT == 0) {
        msg_str = "The response content is empty"
        log_error("gemini", msg_str)
        print ""                                    > (GEMINI_CONTENT_DIR "/chat.error.yml")
        exit(1)
    }

    if (o_error[ L ] == 1) {
        msg_str = jstr(o_error)
        log_error("gemini", log_mul_msg( msg_str ))
        print msg_str                               > (GEMINI_CONTENT_DIR "/chat.error.yml")
        _exitcode = o_error[ Q2_1 SUBSEP "\"error\"" SUBSEP "\"code\"" ]
        if (_exitcode ~ "^4") exit(2) # retry abort
        exit(1)
    } else {
        o_response[ L ] = 1
        cp( o_response, Q2_1, obj, _current_kp )
        o_response[ Q2_1 SUBSEP KP_CONTENT ] = jqu( GEMINI_RESPONSE_CONTENT )
        gemini_res_to_cres( o_response, cres_o , SUBSEP "cres"  )
        print cres_dump( cres_o, SUBSEP "cres" )    > (GEMINI_CONTENT_DIR "/chat.response.yml")
    }
}
