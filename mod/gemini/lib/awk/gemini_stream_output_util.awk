
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
        } else if ( JITER_CURLEN != 1 ) {
            cp( o_response, Q2_1 SUBSEP "\"1\"", o_response, Q2_1 SUBSEP "\""JITER_CURLEN"\"" )
        }
        gemini_display_response_text_stream( obj, _current_kp )
    }
}

function gemini_display_response_text_stream( obj, kp,      _kp, str ){
    _kp = kp SUBSEP KP_CONTENT

    str =  juq(obj[ _kp ])
    GEMINI_RESPONSE_CONTENT = GEMINI_RESPONSE_CONTENT str
    printf( "%s", str )
    fflush()
}

($0 != ""){
    GEMINI_HAS_RESPONSE_CONTENT = 1
    gemini_parse_response_data( $0, obj, o_error )
}
