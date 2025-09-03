
function chat_str_is_null( str ){
    return ((str == "") || (str == "null") || (str == "NULL") || (str == "\"\""))
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

function chat_filelist_load(v,      i, l, arr, fp, fp_desc, fp_content, id, _str, _res){
    if ( chat_str_is_null(v) ) return
    l = split( v, arr, "\n" )
    for (i=1; i<=l; ++i){
        fp = arr[i]
        fp_desc = ""
        if (fp == "") continue
        if ( (id=index(fp, ":")) > 0 ) {
            fp_desc = substr(fp, id+1)
            fp = substr(fp, 1, id-1)
        }
        fp_content = cat(fp)
        gsub("[ \t]+\n", "\n", fp_content)
        # _str =  "<|---BEGIN[FILE-NAME]---|>" fp "<|---END---|>\n"
        # if ( fp_desc !="" ) _str = _str "<|---BEGIN[FILE-DESC]---|>" fp_desc "<|---END---|>\n"
        # _str = _str "<|---BEGIN[FILE-CONTENT]---|>" fp_content "<|---END---|>\n"
        _str =  "<file-name>" fp "</file-name>\n"
        if ( fp_desc !="" ) _str = _str "<file-desc>" fp_desc "</file-desc>\n"
        _str = _str "<file-content>" fp_content "</file-content>\n"

        _res = _str
    }
    if ( _res != "" ) _res = "Please note that the following content is provided in XML format. Focus only on the file content part and ignore the tags.\n" _res
    return _res
}
