BEGIN{
    start_line = ENVIRON["start_line"] + 0
    end_line = ENVIRON["end_line"] + 0
    if ( end_line == 0 ) is_recent = 1
    if ( start_line == 0 ) start_line = 1
}

NR >= start_line && ( is_recent || (NR <= end_line) ){
    parse_msg($0, 0, SUBSEP "\"1\"" SUBSEP "\"body\"")
}

function parse_msg( s, is_ref, kp,        o, kp2, msg_type, msg_time, msg_text, msg_from, msg_chatid,
           img_url, img_aeskey, video_url, video_aeskey,
           file_url, file_aeskey, file_name, voice_url, voice_aeskey,
           mi, arrlen, mixed_kp, mixed_item_type, mixed_item_text, mixed_item_key,
           ref_kp, ref_msgtype, ref_text){
    jiparse_after_tokenize(o, s)
    JITER_LEVEL = JITER_CURLEN = 0

    ref_kp = kp SUBSEP "\"quote\""
    if (o[ ref_kp ] == "{"){
        ref_msgtype = juq(o[ ref_kp SUBSEP "\"msgtype\"" ])
        ref_text = juq(o[ ref_kp SUBSEP "\"text\"" SUBSEP "\"content\""])
        if (ref_text != ""){
            ref_text = parse_tsv_esc(ref_text)
        }
        print 1
        print ref_msgtype
        print ref_text
        print ""
        print ""
        print ""
        print ""
        print ""
        print ""
        print ""
        print ""
        print ""
        print ""
        print ""
    }

    msg_type = juq(o[ kp SUBSEP "\"msgtype\"" ])

    msg_from = juq(o[ kp SUBSEP "\"from\"" SUBSEP "\"userid\"" ])
    msg_chatid = juq(o[kp SUBSEP "\"chatid\""])

    if (index(msg_type, "text") > 0 && index(msg_type, "mixed") == 0){
        msg_text = juq(o[kp SUBSEP "\"text\"" SUBSEP "\"content\""])
    } else if (index(msg_type, "image") > 0){
        img_url = juq(o[kp SUBSEP "\"image\"" SUBSEP "\"url\""])
        img_aeskey = juq(o[kp SUBSEP "\"image\"" SUBSEP "\"aeskey\""])
    } else if (index(msg_type, "video") > 0){
        video_url = juq(o[kp SUBSEP "\"video\"" SUBSEP "\"url\""])
        video_aeskey = juq(o[kp SUBSEP "\"video\"" SUBSEP "\"aeskey\""])
    } else if (index(msg_type, "file") > 0){
        file_url = juq(o[kp SUBSEP "\"file\"" SUBSEP "\"url\""])
        file_aeskey = juq(o[kp SUBSEP "\"file\"" SUBSEP "\"aeskey\""])
        file_name = juq(o[kp SUBSEP "\"file\"" SUBSEP "\"file_name\""])
    } else if (index(msg_type, "voice") > 0){
        voice_url = juq(o[kp SUBSEP "\"voice\"" SUBSEP "\"url\""])
        voice_aeskey = juq(o[kp SUBSEP "\"voice\"" SUBSEP "\"aeskey\""])
    } else if (index(msg_type, "mixed") > 0){
        mixed_kp = kp SUBSEP "\"mixed\"" SUBSEP "\"msg_item\""
        mixed_len_key = mixed_kp L
        arrlen = o[mixed_len_key] + 0
        for (mi = 1; mi <= arrlen; mi++){
            mixed_item_key = mixed_kp SUBSEP "\"" mi "\""
            mixed_item_type = juq(o[mixed_item_key SUBSEP "\"msgtype\""])
            if (index(mixed_item_type, "text") > 0){
                if (msg_text != "") msg_text = msg_text " "
                msg_text = msg_text juq(o[mixed_item_key SUBSEP "\"text\"" SUBSEP "\"content\""])
            } else if (index(mixed_item_type, "image") > 0){
                img_url = juq(o[mixed_item_key SUBSEP "\"image\"" SUBSEP "\"url\""])
                img_aeskey = juq(o[mixed_item_key SUBSEP "\"image\"" SUBSEP "\"aeskey\""])
            } else if (index(mixed_item_type, "video") > 0){
                video_url = juq(o[mixed_item_key SUBSEP "\"video\"" SUBSEP "\"url\""])
                video_aeskey = juq(o[mixed_item_key SUBSEP "\"video\"" SUBSEP "\"aeskey\""])
            } else if (index(mixed_item_type, "file") > 0){
                file_url = juq(o[mixed_item_key SUBSEP "\"file\"" SUBSEP "\"url\""])
                file_aeskey = juq(o[mixed_item_key SUBSEP "\"file\"" SUBSEP "\"aeskey\""])
                file_name = juq(o[mixed_item_key SUBSEP "\"file\"" SUBSEP "\"file_name\""])
            } else if (index(mixed_item_type, "voice") > 0){
                voice_url = juq(o[mixed_item_key SUBSEP "\"voice\"" SUBSEP "\"url\""])
                voice_aeskey = juq(o[mixed_item_key SUBSEP "\"voice\"" SUBSEP "\"aeskey\""])
            }
        }
    }

    if (msg_text != ""){
        msg_text = parse_tsv_esc(msg_text)
    }

    print is_ref
    print msg_type
    print msg_text
    print msg_from
    print msg_chatid
    print img_url
    print img_aeskey
    print video_url
    print video_aeskey
    print file_url
    print file_aeskey
    print file_name
    print voice_url
    print voice_aeskey
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
