
# Add Code
function str_escape(s) {
    gsub(/\\/, "\\\\", s)   # Must place first line
    gsub(/\b/, "\\b", s)
    gsub(/\t/, "\\t", s)
    gsub(/\n/, "\\n", s)
    gsub(/\r/, "\\r", s)
    gsub(/\n/, "\\n", s)
    gsub(/"/, "\\\"", s)
    gsub(/\//, "\\/", s)
    return "\"" s "\""
}

# print str_quote1("h'a\\\'")
function str_quote1(str){
    # gsub("\\", "\\\\", str) # This is wrong in case: # print str_quote1("h'a\\\'")
    gsub(/\\/, "\\\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function str_unquote1(str){
    gsub(/\\\\/, "\001\001", str)
    gsub(/\\'/, "'", str)
    gsub("\001\001", "\\\\", str)
    return substr(str, 2, length(str)-2)
}


function str_quote2(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function str_unquote2(str){
    gsub(/\\\\/, "\001\001", str)
    gsub(/\\"/, /"/, str)
    gsub("\001\001", "\\\\", str)
    return substr(str, 2, length(str)-2)
}

function str_rep(char, number, _i, _s) {
    for (   _i=1; _i<=number; ++_i  ) _s = _s char
    return _s
}


function str_pad_center(str, len,       _len, _len1, _len2) {
    if (_len == "") _len = length(str)
    if (_len < len) {
        _len1 = len - _len
        _len2 = _len1 / 2

        return sprintf("%" _len2 "s", "") str sprintf("%" ( _len1 - _len2 ) "s", "")
    }
    return str
}

function str_pad_left(str, len,   _len) {
    if (_len == "") _len = length(str)
    if (_len < len) {
        return sprintf("%" len - _len "s", "") str
    }
    return str
}

function str_pad_right(str, len,   _len) {
    if (_len == "") _len = length(str)
    if (_len < len) {
        return str sprintf("%" len - _len "s", "")
    }
    return str
}

function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_trim_left(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    return astr
}

function str_trim_right(astr){
    gsub(/^[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_startswith(s, tgt){
    if (substr(s, 1, length(tgt)) == tgt) return true
    return false
}

function str_split_safe(string, array, fieldsep){
    gsub("\n", "\001", string)
    return split(string, array, fieldsep)
}

function str_split( string, array, fieldsep,    e, i, l ){
    l = str_split_without_recovery( string, array, fieldsep )
    for (i=1; i<=l; ++i) {
        e = array[ i ]
        gsub("\001", "\n", e)
        array[i] = e
    }
    return l
}

function str_split_without_recovery( string, array, fieldsep,    l ){
    gsub("\n", "\001", string)
    l = split(string, array, fieldsep)
    array[ L ] = l
    return l
}

function str_split_safe_recover(string){
    gsub("\001", "\n", string)
}


# Section: str module

function str_quote_if_unquoted(str){
    if (str ~ /^".+"$/)
    {
        return str
    }
    return qu(str)
}

function str_wrap2(str){
    return "\"" str "\""
}

function str_wrap_by_backslash(str){
    return "\\\"" str "\\\""
}

function qu(str){
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function qu1(str){
    gsub(/'/, "'\"'\"'", str)
    return "'" str "'"
}

function str_unquote(str){
    gsub(/\\"/, "\"", str)
    return substr(str, 2, length(str)-2)
}

function str_unquote_if_quoted(str){
    if (str ~ /^".+"$/)
    {
        return str_unquote(str)
    }
    return str
}

# output certain kinds of array

function str_join(sep, obj, prefix, start, end,     i, _result) {
    _result = (start <= end) ? obj[prefix start]: ""
    for (i=start+1; i<=end; ++i) _result = _result sep obj[prefix i]
    return _result
}

# function str_joinwrap(left, right, obj, prefix, start, end,     i, _result) {
#     _result = ""
#     for (i=start; i<=end; ++i) _result = _result left obj[prefix i] right
#     return _result
# }

function str_joinwrap(sep, left, right, obj, prefix, start, end,     i, _result) {
    _result = (start <= end) ? left obj[prefix start] right : ""
    for (i=start+1; i<=end; ++i) _result = _result sep left obj[prefix i] right
    return _result
}

## EndSection

BEGIN{
    STR_TERMINAL_ESCAPE033 = "\033\\[([0-9]+;)*([0-9]+)?(m|dh|A|B|C|D)"
    STR_TERMINAL_ESCAPE033_LIST = "(" STR_TERMINAL_ESCAPE033 ")+"
}

function str_len( s ) {         return length( s );     }
function str_len_noesc( s ){    return length( str_remove_esc( s ) );   }

function str_remove_esc(text){
    # gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    gsub( STR_TERMINAL_ESCAPE033_LIST, "", text )
    return text
}

# TODO: Deprecated.
function str_remove_style(text){
    return str_remove_esc( text )
}

