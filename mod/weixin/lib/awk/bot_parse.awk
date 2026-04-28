BEGIN{
    start_line = ENVIRON[ "start_line" ]
    end_line = ENVIRON[ "end_line" ]
    is_recent = false
    if ( end_line == "" ) is_recent = true

    Q2_1 = SUBSEP "\"1\""
}

(NR >= start_line) && ( is_recent || (NR <= end_line) ){
    parse_item_list($0)
}

function parse_item_list( s,        o, kp, l, i, j, jl){
    jiparse_after_tokenize(o, s)
    JITER_LEVEL = JITER_CURLEN = 0

    l = o[ Q2_1 L ]
    for (i=1; i<=l; ++i){
        kp = Q2_1 SUBSEP "\""i"\"" SUBSEP "\"item_list\""
        jl = o[ kp L ]
        for (j=1; j<=jl; ++j){
            parse_item(o, kp SUBSEP "\""j"\"")
        }
    }

}

function parse_item(o, kp, is_ref,          msg_type, msg_text, msg_img_media_fullurl, msg_img_media_aeskey, msg_img_media_aeskey_64,
           msg_video_media_fullurl, msg_video_media_aeskey_64, msg_file_media_fullurl, msg_file_media_aeskey_64, msg_file_media_aeskey_name,
           msg_voice_media_fullurl, msg_voice_media_aeskey_64, ref_msg_kp){
    msg_type = o[ kp SUBSEP "\"type\"" ]
    msg_text = juq( o[ kp SUBSEP "\"text_item\"", "\"text\"" ] )
    msg_img_media_fullurl = juq( o[ kp SUBSEP "\"image_item\"", "\"media\"", "\"full_url\"" ] )
    msg_img_media_aeskey = juq( o[ kp SUBSEP "\"image_item\"", "\"aeskey\"" ] )
    msg_img_media_aeskey_64 = juq( o[ kp SUBSEP "\"image_item\"", "\"media\"", "\"aes_key\"" ] )
    msg_video_media_fullurl = juq( o[ kp SUBSEP "\"video_item\"", "\"media\"", "\"full_url\"" ] )
    msg_video_media_aeskey_64 = juq( o[ kp SUBSEP "\"video_item\"", "\"media\"", "\"aes_key\"" ] )
    msg_file_media_fullurl = juq( o[ kp SUBSEP "\"file_item\"", "\"media\"", "\"full_url\"" ] )
    msg_file_media_aeskey_64 = juq( o[ kp SUBSEP "\"file_item\"", "\"media\"", "\"aes_key\"" ] )
    msg_file_media_aeskey_name = juq( o[ kp SUBSEP "\"file_item\"", "\"file_name\"" ] )
    msg_voice_media_fullurl = juq( o[ kp SUBSEP "\"voice_item\"", "\"media\"", "\"full_url\"" ] )
    msg_voice_media_aeskey_64 = juq( o[ kp SUBSEP "\"voice_item\"", "\"media\"", "\"aes_key\"" ] )

    ref_msg_kp  = kp SUBSEP "\"ref_msg\"" SUBSEP "\"message_item\""
    if (o[ ref_msg_kp ] == "{" ){
        parse_item(o, ref_msg_kp, 1)
    }

    if ( msg_text != "" ){
        msg_text = parse_tsv_esc( msg_text )
    }

    print is_ref
    print msg_type
    print msg_text
    print msg_img_media_fullurl
    print msg_img_media_aeskey
    print msg_img_media_aeskey_64
    print msg_video_media_fullurl
    print msg_video_media_aeskey_64
    print msg_file_media_fullurl
    print msg_file_media_aeskey_64
    print msg_file_media_aeskey_name
    print msg_voice_media_fullurl
    print msg_voice_media_aeskey_64
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
