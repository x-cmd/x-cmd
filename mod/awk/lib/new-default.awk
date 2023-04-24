

BEGIN{
    TRIMH = "(^[ \t\b\v\n]+)"
    TRIMT = "([ \t\b\v\n]+$)"
    TRIM = "(" TRIMH ")|(" TRIMT ")"
}

# This will slow down the speed ...
function trim( astr ){  gsub(TRIM, "", astr)；  return astr; }
function trimh( astr ){ gsub(TRIMH, "", astr);  return astr; }
function trimt( astr ){ gsub(TRIMT, "", astr);  return astr; }

function join( sep, arr, prefix, start, end ){
    _result = (start <= end) ? obj[prefix start]: ""
    for (i=start+1; i<=end; ++i) _result = _result sep obj[prefix i]
    return _result
}

function joinwrap( sep, left, right, arr, prefix, start, end ){
    _result = (start <= end) ? left obj[prefix start] right : ""
    for (i=start+1; i<=end; ++i) _result = _result sep left obj[prefix i] right
    return _result
}

BEGIN{
    STR_TERMINAL_ESCAPE033 = "\033\\[([0-9]+;)*([0-9]+)?(m|dh|A|B|C|D)"
    STR_TERMINAL_ESCAPE033_LIST = "(" STR_TERMINAL_ESCAPE033 ")+"
    TRIM033 = STR_TERMINAL_ESCAPE033_LIST
}

function trim033(){
    gsub( TRIM033, "", text )
    return text
}

function divide( astr, _sep, ret,     i ){
    if ( (i = index( astr, _sep )) <= 0 ) return false
    ret[1] = substr( astr, 1, i-1 )
    ret[2] = substr( astr, i+1 )
    return true
}

function repeat(char, number,       _i, _s) {
    for (   _i=1; _i<=number; ++_i  ) _s = _s char
    return _s
}
