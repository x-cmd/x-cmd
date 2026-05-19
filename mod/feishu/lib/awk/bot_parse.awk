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

function parse_item_list( s,         o, basekp, msg_text, msg_image_key, msg_file_key, msg_file_name, msg_chat_id, msg_message_id, msg_sender_id, msg_type, body_content, inner_json, msg_timestamp, parent_id, is_ref){
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
    parent_id = juq( o[ basekp SUBSEP "\"parent_id\"" ] )
    is_ref = (parent_id != "") ? "1" : "0"

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
        } else if (msg_type == "post") {
            # Parse post message: {"post":{"zh_cn":{"title":"...","content":[[{"tag":"text","text":"..."}]]}}}
            title_str = "\"title\":\""
            pos = index(inner_json, title_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(title_str))
                endq = index(rest, "\"")
                if (endq > 0) {
                    msg_text = substr(rest, 1, endq - 1)
                }
            }
            # Extract text content and image_key from content array
            content_str = "\"content\":"
            pos = index(inner_json, content_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(content_str))
                # Find the array start
                arr_start = index(rest, "[[")
                if (arr_start > 0) {
                    arr_rest = substr(rest, arr_start + 1)
                    arr_end = index(arr_rest, "]]")
                    if (arr_end > 0) {
                        arr_content = substr(arr_rest, 1, arr_end - 1)
                        # Extract image_key from {"tag":"img","image_key":"..."}
                        img_key_str = "\"tag\":\"img\",\"image_key\":\""
                        img_pos = index(arr_content, img_key_str)
                        if (img_pos > 0) {
                            img_rest = substr(arr_content, img_pos + length(img_key_str))
                            img_endq = index(img_rest, "\"")
                            if (img_endq > 0) {
                                msg_image_key = substr(img_rest, 1, img_endq - 1)
                            }
                        }
                        # Extract text from each element: {"tag":"text","text":"..."}
                        while ((tag_pos = index(arr_content, "\"tag\":\"text\"")) > 0) {
                            arr_content = substr(arr_content, tag_pos + 13)
                            text_pos = index(arr_content, "\"text\":\"")
                            if (text_pos > 0) {
                                text_rest = substr(arr_content, text_pos + 8)
                                text_end = index(text_rest, "\"")
                                if (text_end > 0) {
                                    extracted_text = substr(text_rest, 1, text_end - 1)
                                    if (msg_text != "") msg_text = msg_text "\n"
                                    msg_text = msg_text extracted_text
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    print is_ref
    print msg_timestamp
    print msg_type
    print msg_text
    print msg_image_key
    print msg_file_key
    print msg_file_name
    print msg_chat_id
    print msg_message_id
    print parent_id
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
