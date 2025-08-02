
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
