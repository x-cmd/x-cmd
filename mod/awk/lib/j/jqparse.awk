BEGIN{
    L = "\003"
}

function jqparse0( text, obj, kp,      l, a ){
    l = split(json_to_machine_friendly(text), a, "\n")
    return jqparse( obj, kp, l, a )
}

function jqparse_dict0( text, obj, kp,      l, a ){
    l = split(json_to_machine_friendly(text), a, "\n")
    return jqparse_dict( obj, kp, l, a )
}

function jqparse(obj, kp,      token_arrl, token_arr,                                   i, l ){
    i = 1
    while (i <= token_arrl) {
        if (token_arr[i] == "") { i++; continue; }
        i = ___jqparse_value( obj, kp SUBSEP "\"" ++l "\"",    token_arrl, token_arr, i )
    }
    obj[ kp L ] = l
}

function jqparse_dict(obj, kp,     token_arrl, token_arr,  idx ){
    return ___jqparse_dict( obj, kp, token_arrl, token_arr, (idx != "") ? idx : 1 )
}

function jqparse_list(obj, kp,     token_arrl, token_arr,  idx ){
    return ___jqparse_list( obj, kp, token_arrl, token_arr, (idx != "") ? idx : 1 )
}

function ___jqparse_value(obj, kp,     token_arrl, token_arr,  idx,                     t ){
    t = token_arr[ idx ]
    if (t == "[")       return ___jqparse_list( obj, kp, token_arrl, token_arr, idx )
    if (t == "{")       return ___jqparse_dict( obj, kp, token_arrl, token_arr, idx )
    obj[ kp ] = t;      return idx + 1
}

function ___jqparse_list(obj, kp,     token_arrl, token_arr,  idx,                 l ){
    obj[ kp ] = "["
    ++ idx
    while ( idx <= token_arrl ) {
        if (token_arr[ idx ] == "]") {
            obj[ kp L ] = l
            return idx + 1
        }

        idx = ___jqparse_value( obj, kp SUBSEP "\"" (++l) "\"", token_arrl, token_arr, idx )
        if ( token_arr[ idx ] == ",")     idx ++
    }
    # return 11111111
}

function ___jqparse_dict(obj, kp,     token_arrl, token_arr,  idx,                 l, t ){
    obj[ kp ] = "{"
    ++ idx
    while ( idx <= token_arrl ) {
        t = token_arr[ idx ]
        if (t == "}") {
            obj[ kp L ] = l
            return idx + 1
        }

        obj[ kp, (++ l) ] = t
        idx = ___jqparse_value( obj, kp SUBSEP t, token_arrl, token_arr, idx + 2 )
        if ( token_arr[ idx ] == "," )     idx ++
    }
    # return 11111111
}
