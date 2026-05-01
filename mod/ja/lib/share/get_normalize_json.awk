
BEGIN{
    json_str = ENVIRON[ "json_str" ]

    ans = ""
    while ( (match(json_str, "\"%{[A-Za-z0-9_]+}%\"")) || (match(json_str, "%{[A-Za-z0-9_]+}%")) ) {
        _name = _str_parse( substr(json_str, RSTART, RLENGTH) )
        ans = ans substr(json_str, 1, RSTART-1) _name
        json_str = substr(json_str, RSTART+RLENGTH)
    }
    json_str = ans json_str

    ORS = ""
    jiter_tokenized_normalized( json_str )
    fflush()
}

# "%{name}%" or %{name}%
function _str_parse(str,        varname, varval, is_quoted, varval_arr, l, i, varval_str) {
    if ( str ~ "^\"" ) {
        varname = substr(str, 4, length(str) - 6)
        is_quoted = 1
    } else {
        varname = substr(str, 3, length(str) - 4)
        is_quoted = 0
    }
    varval = ENVIRON[ varname ]
    if ( is_quoted ) {
        return jqu(varval)
    } else if ( varval ~ "," ) {
        l = split(varval, varval_arr, ",")
        varval_str = ( (varval_arr[1] ~ "^\"") ? jqu(varval_arr[1]) : varval_arr[1] )
        for (i=2; i<=l; ++i){
            varval_str = varval_str ", " ( (varval_arr[i] ~ "^\"") ? jqu(varval_arr[i]) : varval_arr[i] )
        }
        return varval_str
    } else {
        return varval
    }
}
