
# extra_field: none
function chat_str_is_null( str, extra_field ){
    return ((str == "") || (str == "null") || (str == "NULL") || (str == "\"\"") || ( str == extra_field ))
}

function chat_str_replaceall( src,          _name, ans ){
    ans = ""
    while (match(src, "%{[A-Za-z0-9_]+}%")) {
        _name = substr(src, RSTART+2, RLENGTH-4)
        if ( _name ~ "^(BODY|QUESTION)$" ) _name = QUESTION
        else _name = ENVIRON[ _name ]
        gsub( "\\\\", "&\\", _name )
        gsub( "\"", "\\\"", _name )
        gsub( "\n", "\\n", _name )
        gsub( "\t", "\\t", _name )
        gsub( "\v", "\\v", _name )
        gsub( "\b", "\\b", _name )
        gsub( "\r", "\\r", _name )
        ans = ans substr(src, 1, RSTART-1) _name
        src = substr(src, RSTART+RLENGTH)
    }

    return str_remove_esc( ans src )
}

function chat_record_str_to_drawfile(item, draw_prefix){
    if ( IS_ENACTNONE == true ) return
    item = str_xml_transpose( item )
    gsub( "\n|\r", "&" draw_prefix, item )
    printf( "%s", item ) >> XCMD_CHAT_ENACTALL_DRAWFILE
    fflush()
}

function chat_cal_cached( curr, last,         _curr_arr, _last_arr, _curr_l, _last_l, c, i, l, l1, l2 ) {
    curr = json_to_machine_friendly( curr )
    last = json_to_machine_friendly( last )

    _curr_l = split( curr, _curr_arr, "\n" )
    _curr_arr[ L ] = _curr_l

    _last_l = split( last, _last_arr, "\n" )
    l = _last_arr[ L ] = _last_l
    if ( l > _curr_l ) l = _curr_l

    c = 0
    for (i=1; i<=l; ++i) {
        l1 = length( _curr_arr[i] )
        l2 = length( _last_arr[i] )
        if ( (l1 == l2) && (_last_arr[i] == _curr_arr[i]) ) {
            c += l2
            continue
        }

        # TODO: we can use divide and conqure for more accuracy. But it is meanless comparing to the time cost.
        break
    }

    return c
}

function chat_filelist_load_to_array(v, arr,            i, l, _, fp, fp_desc, fp_content, fp_base64, fp_suffix, id, _str ){
    if ( chat_str_is_null(v) ) return
    l = split( v, _, "\n" )
    for (i=1; i<=l; ++i){
        fp = _[i]
        fp_desc = ""
        if (fp == "") continue
        if ( (id=index(fp, ":")) > 0 ) {
            fp_desc = substr(fp, id+1)
            fp = substr(fp, 1, id-1)
        }

        if ( arr[ fp, "recorded" ] == true ) continue
        arr[ ++arr[L] ] = fp
        arr[ fp, "recorded" ] = true
        _str = "<file-name>" fp "</file-name>\n"
        if ( fp_desc !="" ) _str = _str "<file-desc>" fp_desc "</file-desc>\n"
        if (match(tolower(fp), "(.png|.jpeg|.jpg|.webp|.gif)$")) {
            fp_suffix = tolower( substr(fp, RSTART+1) )
            fp_base64 = file_base64(fp)
            _str = _str "<file-type>image</file-type>\n"
            if ( fp_base64 != "" ) {
                arr[ fp, "type" ] = "image"
                arr[ fp, "text" ] = _str
                arr[ fp, "base64" ] = fp_base64
                if ( fp_suffix == "jpg" ) fp_suffix = "jpeg"
                arr[ fp, "mime_type" ] = "image/" fp_suffix
            } else {
                _str = _str "<file-content>Failed to read image file content</file-content>\n"
                arr[ fp, "type" ] = "text"
                arr[ fp, "text" ] = _str
                continue
            }
        } else {
            fp_content = cat(fp)
            gsub("[ \t]+\n", "\n", fp_content)
            _str = _str "<file-content>" fp_content "</file-content>\n"
            arr[ fp, "type" ] = "text"
            arr[ fp, "text" ] = _str
        }
    }
}

function chat_tf_bit(v){
    v = ((v ~ "^\"") ? juq(v) : v) ""
    v = tolower(v)
    if (( v == true ) || ( v == "true" ))           return true
    else if (( v == false ) || ( v == "false" ))    return false
}

function chat_tf_str(v){
    v = ((v ~ "^\"") ? juq(v) : v) ""
    v = tolower(v)
    if (( v == "true" ) || ( v == true ))           return "true"
    else if (( v == "false" ) || ( v == false ))    return "false"
}

function chat_wrap_tag(name, str, name_desc){
    if ( str == "" ) return
    return "<" name name_desc ">" str "</" name ">"
}
