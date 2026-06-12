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

    # Parse body.content JSON to extract text, image_key, or file_key.
    # IMPORTANT: we keep JSON escape sequences (\") intact in inner_json so that
    # find_json_str_end can correctly distinguish the closing quote of a string
    # value from escaped quotes inside it. A previous version of this file ran
    # `gsub(/\\"/, "\"", inner_json)` first, which collapsed \" into " and made
    # the next `index(rest, "\"")` land on the WRONG quote — truncating any
    # message whose text contained an escaped quote (e.g. \"立刻马上\") at that
    # point. See REF content fix.
    if (body_content != "") {
        inner_json = body_content

        if (msg_type == "text") {
            colon_pos = index(inner_json, "\"text\":")
            if (colon_pos > 0) {
                rest = substr(inner_json, colon_pos + 8)
                end_quote = find_json_str_end(rest)
                if (end_quote > 0) {
                    msg_text = substr(rest, 1, end_quote - 1)
                    gsub(/\\"/, "\"", msg_text)
                    # Replace @_user_N placeholders with @_user_N=real_name
                    # using the mentions[] array from the outer message JSON.
                    msg_text = substitute_mentions(msg_text, s)
                    msg_text = parse_tsv_esc(msg_text)
                }
            }
        } else if (msg_type == "image") {
            msg_image_key = extract_json_string(inner_json, "\"image_key\":\"")
        } else if (msg_type == "file") {
            msg_file_key = extract_json_string(inner_json, "\"file_key\":\"")
            msg_file_name = extract_json_string(inner_json, "\"file_name\":\"")
        } else if (msg_type == "media") {
            msg_image_key = extract_json_string(inner_json, "\"image_key\":\"")
            msg_file_key = extract_json_string(inner_json, "\"file_key\":\"")
            msg_file_name = extract_json_string(inner_json, "\"file_name\":\"")
        } else if (msg_type == "post") {
            # Parse post message: {"post":{"zh_cn":{"title":"...","content":[[{"tag":"text","text":"..."}]]}}}
            # title
            msg_text = extract_json_string(inner_json, "\"title\":\"")
            # content array — find the [[ ... ]] block, tracking nesting
            content_str = "\"content\":"
            pos = index(inner_json, content_str)
            if (pos > 0) {
                rest = substr(inner_json, pos + length(content_str))
                arr_start = index(rest, "[[")
                if (arr_start > 0) {
                    arr_rest = substr(rest, arr_start + 1)
                    arr_end = find_arr_end(arr_rest)
                    if (arr_end > 0) {
                        arr_content = substr(arr_rest, 1, arr_end - 1)
                        # Extract image_key from {"tag":"img","image_key":"..."}
                        msg_image_key = extract_json_string(arr_content, "\"tag\":\"img\",\"image_key\":\"")
                        # Extract text from each element: {"tag":"text","text":"..."}
                        while ((tag_pos = index(arr_content, "\"tag\":\"text\"")) > 0) {
                            arr_content = substr(arr_content, tag_pos + 13)
                            text_pos = index(arr_content, "\"text\":\"")
                            if (text_pos > 0) {
                                text_rest = substr(arr_content, text_pos + 8)
                                text_end = find_json_str_end(text_rest)
                                if (text_end > 0) {
                                    extracted_text = substr(text_rest, 1, text_end - 1)
                                    gsub(/\\"/, "\"", extracted_text)
                                    # Replace @_user_N placeholders in this segment
                                    extracted_text = substitute_mentions(extracted_text, s)
                                    if (msg_text != "") msg_text = msg_text "\n"
                                    msg_text = msg_text extracted_text
                                }
                            }
                        }
                        # Escape the joined post text so the shell printf can
                        # safely include it on a single TSV line.
                        msg_text = parse_tsv_esc(msg_text)
                    }
                }
            }
        }
    }

    print is_ref
    print msg_timestamp
    print msg_sender_id
    print msg_type
    print msg_text
    print msg_image_key
    print msg_file_key
    print msg_file_name
    print msg_chat_id
    print msg_message_id
    print parent_id
}

# Find the 1-based end position of a JSON string value in s. The string value
# is assumed to start at position 1 (the caller has already sliced off the
# opening quote and the field-name prefix). Returns 0 if no closing quote is
# found. Skips over JSON escape sequences (\", \\, \n, \t, \r, \uXXXX, ...)
# so escaped quotes inside the value don't terminate the string prematurely.
function find_json_str_end(s,    i, c) {
    i = 1
    while (i <= length(s)) {
        c = substr(s, i, 1)
        if (c == "\\") {
            i += 2
        } else if (c == "\"") {
            return i
        } else {
            i += 1
        }
    }
    return 0
}

# Find the 1-based position of the closing ] that matches the leading [ of a
# JSON array. s is assumed to start right after the opening [. Tracks nesting
# (so e.g. `[[{...}],[{...}]]` correctly returns the outermost `]`) and skips
# over string values so that brackets inside strings don't confuse the depth
# counter.
function find_arr_end(s,    i, c, c2, depth) {
    depth = 1
    i = 1
    while (i <= length(s) && depth > 0) {
        c = substr(s, i, 1)
        if (c == "\"") {
            # Skip the string value: advance until the matching unescaped "
            i++
            while (i <= length(s)) {
                c2 = substr(s, i, 1)
                if (c2 == "\\") {
                    i += 2
                } else if (c2 == "\"") {
                    break
                } else {
                    i++
                }
            }
        } else if (c == "[") {
            depth++
        } else if (c == "]") {
            depth--
            if (depth == 0) return i
        }
        i++
    }
    return 0
}

# Find key_str in json, extract the JSON string value that follows it, and
# unescape \" to ". Returns "" if key_str is not found.
function extract_json_string(json, key_str,    pos, rest, endq, value) {
    pos = index(json, key_str)
    if (pos <= 0) return ""
    rest = substr(json, pos + length(key_str))
    endq = find_json_str_end(rest)
    if (endq <= 0) return ""
    value = substr(rest, 1, endq - 1)
    gsub(/\\"/, "\"", value)
    return value
}

# Find the 1-based position of the closing } that matches the leading { of a
# JSON object. s is assumed to start right after the opening {. Tracks nesting
# (so e.g. `{"a":{"b":1}}` correctly returns the outermost `}`) and skips over
# string values so that braces inside strings don't confuse the depth counter.
function find_obj_end(s,    i, c, c2, depth) {
    depth = 1
    i = 1
    while (i <= length(s) && depth > 0) {
        c = substr(s, i, 1)
        if (c == "\"") {
            # Skip the string value: advance until the matching unescaped "
            i++
            while (i <= length(s)) {
                c2 = substr(s, i, 1)
                if (c2 == "\\") {
                    i += 2
                } else if (c2 == "\"") {
                    break
                } else {
                    i++
                }
            }
        } else if (c == "{") {
            depth++
        } else if (c == "}") {
            depth--
            if (depth == 0) return i
        }
        i++
    }
    return 0
}

# Walk the top-level "mentions":[ ... ] array in s, and for every mention
# object replace each occurrence of its `key` placeholder in `text` with
# `key=name`. Returns the (possibly modified) text. If there is no mentions
# field, or no key/name pair, the text is returned unchanged.
function substitute_mentions(text, s,    mpos, rest, arr_end, arr_content,
                              obj_pos, obj_rest, obj_end, obj_content,
                              key, name, replacement) {
    mpos = index(s, "\"mentions\":[")
    if (mpos <= 0) return text

    # rest starts with the opening "[" of the mentions array
    rest = substr(s, mpos + length("\"mentions\":"))
    arr_end = find_arr_end(substr(rest, 2))
    if (arr_end <= 0) return text
    arr_content = substr(rest, 2, arr_end - 1)

    while (1) {
        obj_pos = index(arr_content, "{")
        if (obj_pos == 0) break
        obj_rest = substr(arr_content, obj_pos + 1)
        obj_end = find_obj_end(obj_rest)
        if (obj_end <= 0) break
        obj_content = substr(obj_rest, 1, obj_end - 1)

        key  = extract_json_string(obj_content, "\"key\":\"")
        name = extract_json_string(obj_content, "\"name\":\"")
        if (key != "" && name != "") {
            replacement = key "=" name
            # gsub treats & and \ specially in the replacement string.
            # Escape them so they appear literally in the output.
            gsub(/\\/, "\\\\", replacement)
            gsub(/&/,  "\\&",  replacement)
            gsub(key, replacement, text)
        }

        # Advance past this object and the trailing comma/whitespace
        arr_content = substr(obj_rest, obj_end + 1)
        sub(/^[[:space:]]*,[[:space:]]*/, "", arr_content)
    }
    return text
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
