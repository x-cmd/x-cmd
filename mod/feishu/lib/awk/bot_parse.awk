BEGIN{
    start_line = ENVIRON[ "start_line" ]
    end_line = ENVIRON[ "end_line" ]
    is_recent = false
    if ( end_line == "" ) is_recent = true

    Q_RESULT = SUBSEP "\"result\""
}

(NR >= start_line) && ( is_recent || (NR <= end_line) ){
    parse_item_list($0)
}

function parse_item_list( s,         o, basekp, msg_text, msg_image_key, msg_file_key, msg_file_name, msg_chat_id, msg_message_id, msg_sender_id, msg_type, body_content, inner_json, msg_timestamp){
    jiparse_after_tokenize(o, s)
    JITER_LEVEL = JITER_CURLEN = 0

    # feishu: each line is a single message object
    basekp = SUBSEP "\"1\""

    msg_type = juq( o[ basekp SUBSEP "\"msg_type\"" ] )
    body_content = juq( o[ basekp SUBSEP "\"body\"" SUBSEP "\"content\"" ] )
    msg_chat_id = juq( o[ basekp SUBSEP "\"chat_id\"" ] )
    msg_message_id = juq( o[ basekp SUBSEP "\"message_id\"" ] )
    msg_sender_id = juq( o[ basekp SUBSEP "\"sender\"" SUBSEP "\"id\"" ] )
    msg_timestamp = juq( o[ basekp SUBSEP "\"create_time\"" ] )

    msg_text = ""
    msg_image_key = ""
    msg_file_key = ""
    msg_file_name = ""

    # Parse body.content JSON to extract text, image_key, or file_key
    if (body_content != "") {
        # Remove surrounding quotes and unescape
        inner_json = body_content
        gsub(/^"|"$/, "", inner_json)
        gsub(/\\"/, "\"", inner_json)

        if (msg_type == "text") {
            colon_pos = index(inner_json, "\"text\":")
            if (colon_pos > 0) {
                rest = substr(inner_json, colon_pos + 8)
                end_quote = index(rest, "\"")
                if (end_quote > 0) {
                    msg_text = parse_tsv_esc(substr(rest, 1, end_quote - 1))
                }
            }
        } else if (msg_type == "image") {
            key_str = "\"image_key\":\""
            pos = index(inner_json, key_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(key_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_image_key = substr(rest, 1, endq - 1)
                }
            }
        } else if (msg_type == "file") {
            key_str = "\"file_key\":\""
            pos = index(inner_json, key_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(key_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_file_key = substr(rest, 1, endq - 1)
                }
            }
            key_str = "\"file_name\":\""
            pos = index(inner_json, key_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(key_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_file_name = substr(rest, 1, endq - 1)
                }
            }
        } else if (msg_type == "media") {
            key_str = "\"image_key\":\""
            pos = index(inner_json, key_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(key_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_image_key = substr(rest, 1, endq - 1)
                }
            }

            key_str = "\"file_key\":\""
            pos = index(inner_json, key_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(key_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_file_key = substr(rest, 1, endq - 1)
                }
            }

            key_str = "\"file_name\":\""
            pos = index(inner_json, key_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(key_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_file_name = substr(rest, 1, endq - 1)
                }
            }
        }
    }

    print ""
    print msg_timestamp
    print msg_type
    print msg_text
    print msg_image_key
    print msg_file_key
    print msg_file_name
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
