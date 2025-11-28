
# extra_field: none
function chat_str_truncate( str,            l, ls, rs ){
    l = length(str)
    if ( l <= 2048 ) return str

    ls = substr(func_stderr, 1, 512)
    if ( match( ls, "^[^-a-zA-Z0-9+&@#/%?=~_|!:,.; ]+" ) ) {
        ls = substr(ls, 1, RSTART-1)
    }

    rs = substr(func_stderr, l-512, 512)
    if ( match( rs, "^[^-a-zA-Z0-9+&@#/%?=~_|!:,.; ]+" ) ) {
        rs = substr(rs, RSTART+RLENGTH)
    }
    return "(truncated)\n" ls "\n<<< omitted " (loutput - 1024) " bytes >>>\n" rs
}

function chat_str_is_null( str, extra_field ){
    return ((str == "") || (str == "null") || (str == "NULL") || (str == "\"\"") || ( str == extra_field ))
}

function chat_str_replaceall( src, is_escape,         _name, ans ){
    ans = ""
    while (match(src, "%{[A-Za-z0-9_]+}%")) {
        _name = substr(src, RSTART+2, RLENGTH-4)
        if ( _name ~ "^(BODY|QUESTION)$" ) _name = QUESTION
        else _name = ENVIRON[ _name ]
        if ( is_escape == true ) _name = jescape( _name )
        ans = ans substr(src, 1, RSTART-1) _name
        src = substr(src, RSTART+RLENGTH)
    }

    return str_remove_esc( ans src )
}

function chat_record_str_to_drawfile(item, draw_prefix){
    item = chat_trim_str( item )
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
        _str = chat_wrap_tag("file-name", fp ) "\n"
        if ( fp_desc !="" ) _str = _str chat_wrap_tag("file-desc", fp_desc ) "\n"
        if (match(tolower(fp), "(.png|.jpeg|.jpg|.webp|.gif)$")) {
            fp_suffix = tolower( substr(fp, RSTART+1) )
            fp_base64 = file_base64(fp)
            _str = _str chat_wrap_tag("file-type", "image") "\n"
            if ( fp_base64 != "" ) {
                arr[ fp, "type" ] = "image"
                arr[ fp, "text" ] = _str
                arr[ fp, "base64" ] = fp_base64
                if ( fp_suffix == "jpg" ) fp_suffix = "jpeg"
                arr[ fp, "mime_type" ] = "image/" fp_suffix
            } else {
                _str = _str chat_wrap_tag("file-content", "Failed to read image file content") "\n"
                arr[ fp, "type" ] = "text"
                arr[ fp, "text" ] = _str
                continue
            }
        } else {
            fp_content = cat(fp)
            gsub("[ \t]+\n", "\n", fp_content)
            _str = _str chat_wrap_tag("file-content", fp_content ) "\n"
            arr[ fp, "type" ] = "text"
            arr[ fp, "text" ] = _str
        }
    }
}

function chat_statsfile_load( hist_session_dir,         fp, str ){
    fp = hist_session_dir "/stats.yml"
    str = cat( fp )
    if ( cat_is_filenotfound() ) return
    return chat_wrap_tag("stats-file", str)
}

function chat_context_filelist_load_to_array( context_filelist, arr,            i, l, _, fp, c ){
    if ( chat_str_is_null(context_filelist) ) return
    l = split( context_filelist, _, "\n" )
    for (i=1; i<=l; ++i){
        fp = _[i]
        if ( fp == "" ) continue
        if ( arr[ fp, "recorded" ] == true ) continue
        c = cat( fp )
        arr[ fp, "recorded" ] = true
        if ( c == "" ) continue
        arr[ ++arr[L] ] = fp
        arr[ arr[L], "content" ] = c
    }
    return arr[L]
}

function chat_context_filelist_load( context_filelist,            i, l, arr, _res ){
    l = chat_context_filelist_load_to_array( context_filelist, arr )
    for (i=1; i<=l; ++i){
        _res = _res "# Instruction file for " arr[ i ] "\n" chat_wrap_tag( "INSTRUCTIONS", arr[ i, "content" ] ) "\n"
    }
    return _res
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

function chat_trim_str( str ){
    str = str_xml_transpose( str )
    str = str_unicode2utf8( str )
    return str
}

function chat_get_cres_dir( session_dir, chatid ){
    return ( session_dir "/" chatid "/chat.response" )
}

function chat_get_creq_dir( session_dir, chatid ){
    return ( session_dir "/" chatid "/chat.request" )
}

function chat_get_session_last_total_token( session_dir, chatid,            last_chatid, hist_session_dir ){
    last_chatid         = creq_fragfile_unit___get( chat_get_creq_dir(session_dir, chatid), "last_chatid" )
    if ( last_chatid == "" ) return
    hist_session_dir    = creq_fragfile_unit___get( chat_get_creq_dir(session_dir, chatid), "hist_session_dir" )
    return cres_fragfile_unit___get( chat_get_cres_dir( hist_session_dir, last_chatid ), "usage_session_total_token" )
}

function chat_get_session_last_total_price( session_dir, chatid,            last_chatid, hist_session_dir ){
    last_chatid         = creq_fragfile_unit___get( chat_get_creq_dir(session_dir, chatid), "last_chatid" )
    if ( last_chatid == "" ) return
    hist_session_dir    = creq_fragfile_unit___get( chat_get_creq_dir(session_dir, chatid), "hist_session_dir" )
    return cres_fragfile_unit___get( chat_get_cres_dir( hist_session_dir, last_chatid ), "usage_session_total_price" )
}
