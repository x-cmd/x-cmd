BEGIN{
    start_line = ENVIRON[ "start_line" ]
    end_line = ENVIRON[ "end_line" ]
    is_recent = false
    if ( end_line == "" ) is_recent = true

    Q2_1 = SUBSEP "\"1\""
}

(NR >= start_line) && ( is_recent || (NR <= end_line) ) {
    Qresult = Q2_1 SUBSEP "\"result\"" SUBSEP "\"1\"" SUBSEP "\"message\""
    parse_item($0, Qresult, 0)
}

function parse_item( s, kp, is_ref,        o, ref_kp, msg_text, msg_photo_id, msg_document_id, msg_video_id, msg_voice_id, msg_audio_id, msg_from_id, msg_chat_id, msg_message_id, msg_date){
    jiparse_after_tokenize(o, s)
    JITER_LEVEL = JITER_CURLEN = 0

    msg_date = o[ kp SUBSEP "\"date\"" ]
    msg_text = juq( o[ kp SUBSEP "\"text\"" ] )
    msg_photo_id = juq( o[ kp SUBSEP "\"photo\"" SUBSEP "\"3\"" SUBSEP "\"file_id\"" ] )
    msg_document_id = juq( o[ kp SUBSEP "\"document\"" SUBSEP "\"file_id\"" ] )
    msg_video_id = juq( o[ kp SUBSEP "\"video\"" SUBSEP "\"file_id\"" ] )
    msg_voice_id = juq( o[ kp SUBSEP "\"voice\"" SUBSEP "\"file_id\"" ] )
    msg_audio_id = juq( o[ kp SUBSEP "\"audio\"" SUBSEP "\"file_id\"" ] )
    msg_from_id = o[ kp SUBSEP "\"from\"" SUBSEP "\"id\"" ]
    msg_chat_id = o[ kp SUBSEP "\"chat\"" SUBSEP "\"id\"" ]
    msg_message_id = o[ kp SUBSEP "\"message_id\"" ]

    ref_kp = kp SUBSEP "\"reply_to_message\""
    if ( o[ ref_kp ] == "{" ){
        parse_item(s, ref_kp, 1)
    }

    if ( msg_text != "" ){
        msg_text = parse_tsv_esc( msg_text )
    }

    print is_ref
    print msg_date
    print msg_text
    print msg_photo_id
    print msg_document_id
    print msg_video_id
    print msg_voice_id
    print msg_audio_id
    print msg_from_id
    print msg_chat_id
    print msg_message_id
}

function parse_tsv_esc( v ){
    if (v ~ /[\r\n\t\\]/) {
        gsub( "\\\\", "&\\", v )
        gsub( "\r", "\\r",  v )
        gsub( "\n", "\\n",  v )
        gsub( "\t", "\\t",  v )
    }
    return v
}
