
# In the future, we might need to support recursive
function md_handle_list( line, output_arr,          level_cache, num_cache ){
    if ( level_cache[0] == 0 ) level_cache[0] = 1
    md_handle_list_( line, output_arr, level_cache, num_cache )

    while (md_getline()){
        if (md_handle_list_( $0, output_arr, level_cache, num_cache )) return 1
    }
}

function md_handle_list_( line, output_arr, level_cache, num_cache,          _level, num, level ){
    level = level_cache[0]
    num = num_cache[ level ]
    $0 = line
    if ($0 ~ MD_REGEX_SPACE) return 1
    if ($0 ~ MD_REGEX_BLIST) {
        _level = md_list_level($0)
        if ( _level > level ) level ++
        else level = _level

        $0 = md_str_trim( $0 )
        gsub("^[*\\-+]", md_list_indent(level) "•", $0)
        md_handle_body($0, output_arr)
    }
    else if ($0 ~ MD_REGEX_OLIST) {
        _level = md_list_level($0)
        if ( _level > level ) num = num_cache[ ++level ]
        else if ( _level < level ){
            num_cache[ level ] = 0
            level = _level
            num = num_cache[ level ]
        }

        $0 = md_str_trim( $0 )
        # extract the first number, increase
        if (num != 0) num_cache[ level ] = int(++num)
        else {
            match($0, "^[0-9]+")
            num_cache[ level ] = num = int( substr($0, 1, RLENGTH) )
        }

        gsub("^[0-9]+", md_list_indent(level) num, $0)
        md_handle_body($0, output_arr)
    }
    else {
        $0 = md_str_trim( $0 )
        md_handle_body( md_list_indent(level) $0, output_arr )
    }
    level_cache[0] = level
}

function md_list_level(line){
    match( line, "[^ ]")
    return int((RSTART - 1) / 4 ) + 1
}

function md_list_indent(level,      s){
    if ( (s = INDENT_STR[ level ]) != "" ) return s
    return INDENT_STR[ level ] = str_rep( "  ", int(level - 1) )
}

