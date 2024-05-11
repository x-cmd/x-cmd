# The loading time should be less than 3ms, should be less than 1000 lines -- 1025 line
# default.awk

BEGIN {
    false = FALSE = 0
    true  = TRUE  = 1
    S = SUBSEP
    T = "\002"
    L = "\003"
}

# Section: new core
function clone( src, dst,   i ){    for (i in src) dst[i] = src[i];     }

BEGIN{
    TRIMH = "(^[ \t\b\v\n]+)"
    TRIMT = "([ \t\b\v\n]+$)"
    TRIM = "(" TRIMH ")|(" TRIMT ")"
}

# This will slow down the speed ...
function trim( astr ){  gsub(TRIM, "", astr);  return astr; }
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
# EndSection

# Section: debug
function debug(msg){
    # print msg > "/dev/stderr"
	print "[DBG]: " "\033[31m" msg "\033[0m" > "/dev/stderr"
}

# function debug(msg){
#     if (0 != DEBUG)     print msg > "/dev/stderr"
# }

function debug_file(msg, file){
    if (file == "") {
        file = "./awk.default.debug.log"
    }
    print msg > file
}
# EndSection

# Section: exit
BEGIN {
    EXIT_CODE = -1
}

function exit_now(code){
    EXIT_CODE = code    # You still need to check EXIT_CODE in end block
    exit code
}

function exit_msg( code, msg ){
    if (msg == "") {
        msg = code
        code = 1
    }
    printf("%s\n", msg)
    exit( code )
}

# EndSection

# Section: var ==> shell var generate
function var_quote1(str){
    # gsub("\\", "\\\\", str) # This is wrong in case: # print str_quote1("h'a\\\'")
    gsub(/\\/, "&\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function var_set(name, value){
    return sprintf("%s=%s", name, var_quote1(value))
}
# EndSection

# Section: json
# function juq_original( str ){
#     str = substr( str, 2, length(str)-2 )
#     gsub( /\\\\/, "\001", str )
#     gsub( /\\"/, "\"", str )
#     gsub( /\\n/, "\n", str )
#     gsub( /\\t/, "\t", str )
#     gsub( /\\v/, "\v", str )
#     gsub( /\\b/, "\b", str )
#     gsub( /\\r/, "\r", str )
#     gsub( "\\/", "/", str )                 # Notice: This is for the bwh json.
#     gsub( "\001", "\\", str )
#     return str
# }

BEGIN{
    PHP_JSON = ENVIRON["___X_CMD_AWK_PHPJSON"]
}

function juq( str ){
    str = substr( str, 2, length(str)-2 )
    if (str !~ /\\/) return str

    gsub( /\\\\/, "\001", str )
    gsub( /\\"/, "\"", str )
    gsub( /\\n/, "\n", str )
    gsub( /\\r/, "\r", str )
    gsub( /\\t/, "\t", str )

    if (str ~ /\\/) {
        if (str ~ /\\u/){   # Only for gemini ...
            gsub( /\\u003c/, "<", str )
            gsub( /\\u003e/, ">", str )
            # TODO: in the future: if (str ~ /\\u/) -> transform to binary format. Time consuming ...
        }

        gsub( /\\v/, "\v", str )    # Notice: Will remove in the future, the jq won't recognized
        gsub( /\\b/, "\b", str )
        if (PHP_JSON)   gsub( "\\/", "/", str )                 # Notice: This is for the bwh json.
        # control characters from U+0000 through U+001F must be escaped
    }

    gsub( "\001", "\\", str )
    return str
}

function juq_gawk( str ){
    # using translate for UTF-8 handle
}

function juq1( str ){
    str = substr( str, 2, length(str)-2 )
    if (str !~ /\\/) return str

    gsub( /\\\\/, "\001", str )
    gsub( /\\'/, "'", str )
    gsub( /\\n/, "\n", str )
    gsub( /\\t/, "\t", str )
    gsub( /\\v/, "\v", str )
    gsub( /\\b/, "\b", str )
    gsub( /\\r/, "\r", str )
    gsub( "\001", "\\", str )
    return str
}

# TODO: will translate control chars to unicode -- That might be the bug in the script play.
function jqu( str ){
    gsub( "\\\\", "&\\", str )
    gsub( "\"", "\\\"", str )
    gsub( "\n", "\\n", str )
    gsub( "\t", "\\t", str )
    gsub( "\v", "\\v", str )        # Notice: Will remove in the future, using \u000b to encode
    gsub( "\b", "\\b", str )
    gsub( "\r", "\\r", str )
    return "\"" str "\""
}
# EndSection

# Section: not used
# This is for refactor
function alength_get( a, prefix ){
    return a[ prefix L ]
}

function alength_put( a, prefix, l ){
    return a[ prefix L ] = l
}
# EndSection

# Section: opt
function opt_init( arr ){
    delete arr
}

function opt_set( arr, k, v ){
    arr[ k ] = v
}

function opt_get( arr, k ){
    return arr[ k ]
}

function opt_getor( arr, k,   def ){
    return ( arr[ k ] == "" ) ? def : arr[ k ]
}
# EndSection

# Section: seq
function seq( seqstr, a,    i, j ){
    seq_parse( seqstr )
    if (SEQ_STEP < 0) {
        for (i=SEQ_START; i>=SEQ_END; i+=SEQ_STEP) a[ ++j ] = i
    } else {
        for (i=SEQ_START; i<=SEQ_END; i+=SEQ_STEP) a[ ++j ] = i
    }
}

function seq_parse(  seqstr,       l, a ){
    # l = split(seqstr, a, ":")
    # if (l == 1)      {  SEQ_START =   1 ;   SEQ_END = a[1];   SEQ_STEP =   1 ;     }
    # else if (l == 2) {  SEQ_START = a[1];   SEQ_END = a[2];   SEQ_STEP = ( ((SEQ_START > SEQ_END) && ( SEQ_END > 0 )) ? -1 : 1 ) ;     }
    # else             {  SEQ_START = a[1];   SEQ_END = a[3];   SEQ_STEP = a[2];     }
    seq_init( seqstr, a )
    SEQ_START = a[ "S" ]
    SEQ_STEP  = a[ "P" ]
    SEQ_END   = a[ "E" ]
}

function seq_within( number, seqstr ){
    seq_parse( seqstr )
    if (SEQ_STEP < 0) {
        return ( (number <= SEQ_START) && (number >= SEQ_END) && ( 0 == (number - SEQ_END) % SEQ_STEP ) )
    } else {
        return ( (number >= SEQ_START) && (number <= SEQ_END) && ( 0 == (number - SEQ_START) % SEQ_STEP ) )
    }
}

BEGIN{
    MAX_INT = 4294967295
}

# Consider apply this to the seq() and seq_parse()
function seq_init( astr, obj, idx,      a, l ){
    l = split(astr, a, ":")
    if (l == 1)          seq_init_data( obj, idx, 1, 1, a[1] )
    else if (l == 2)     seq_init_data( obj, idx, a[1], "", a[2] )
    else if (l == 3)     seq_init_data( obj, idx, a[1], a[2], a[3] )
}

function seq_init_data( obj, idx, start, step, end ){
    obj[ idx "S" ] = start = ( start != "") ? start : 1
    obj[ idx "E" ] = end = ( end != "" ) ? end : MAX_INT
    obj[ idx "P" ] = ( step != "" ) ? step : ( ((start > end) && ( end > 0 )) ? -1 : 1 )
}

function seq_canstream( start, step, end ){
    # if ((end  != "") || (end  < 0))  return false
    # if ((step != "") || (step < 0))  return false
    if ((end < 0) || (step < 0)) return false
    return true
}
# EndSection

# Section: log.awk
BEGIN{
    # x_LOG_FLAT = ENVIRON["x_LOG_FLAT"]
    ___X_CMD_LOG_C_TF = ENVIRON["___X_CMD_LOG_C_TF"]
    ___X_CMD_LOG_YML_INDENT = ENVIRON["___X_CMD_LOG_YML_INDENT"]
    ___X_CMD_LOG_YML_PID_LIST = ENVIRON["___X_CMD_LOG_YML_PID_LIST"]
    if (___X_CMD_LOG_YML_PID_LIST != "") ___X_CMD_LOG_YML_PID_LIST = " " ___X_CMD_LOG_YML_PID_LIST

    if (___X_CMD_LOG_C_TF == "") {
        ___X_CMD_LOG_C_DEBUG = escape_char033(ENVIRON[ "___X_CMD_LOG_C_DEBUG" ])
        ___X_CMD_LOG_C_INFO  = escape_char033(ENVIRON[ "___X_CMD_LOG_C_INFO" ])
        ___X_CMD_LOG_C_WARN  = escape_char033(ENVIRON[ "___X_CMD_LOG_C_WARN" ])
        ___X_CMD_LOG_C_ERROR = escape_char033(ENVIRON[ "___X_CMD_LOG_C_ERROR" ])
        ___X_CMD_LOG_END     = "\033[0m"
        ___X_CMD_LOG_C_BG    = "\033[7m"
        ___X_CMD_LOG_C_MSG   = "\033[0m"
    }
}

function escape_char033(s){
    gsub("\\\\033", "\033", s)
    return s
}

function log_mul_msg( msg ){
    msg = "|\n" msg
    gsub( "\n", "\n" ___X_CMD_LOG_YML_INDENT "    ", msg )
    return msg
}

function log_debug( mod, msg ){
    log_level( "D", mod, msg, ___X_CMD_LOG_C_DEBUG )
}

function log_info( mod, msg ){
    log_level( "I", mod, msg, ___X_CMD_LOG_C_INFO, "", ___X_CMD_LOG_C_MSG )
}

function log_warn( mod, msg ){
    log_level( "W", mod, msg, ___X_CMD_LOG_C_WARN, ___X_CMD_LOG_C_BG )
}

function log_error( mod, msg ){
    log_level( "E", mod, msg, ___X_CMD_LOG_C_ERROR, ___X_CMD_LOG_C_BG )
}

function log_level( level, mod, msg, c, c_bg, c_msg ){
    printf("%s%s %s%s%s%s%s|%s: %s%s%s\n", ___X_CMD_LOG_YML_INDENT "-", ___X_CMD_LOG_YML_PID_LIST, \
        c, c_bg, level, ___X_CMD_LOG_END, c, mod, \
        c_msg, msg, ___X_CMD_LOG_END ) >"/dev/stderr"
}
# EndSection

# Section: fs.awk cat bcat
# TODO: this module try to provide facility for filesystem manipulation in the future.
function cat( filepath,    r, c, l ){
    CAT_FILENOTFOUND = false
    filepath = filepath_adjustifwin( filepath )
    while ((c=(getline <filepath))==1) { l = RS $0; r = r l; }
    sub("^"RS, "", r)
    if (c == -1)    CAT_FILENOTFOUND = true
    close( filepath )
    return r
}

function cat_to_arr( filepath, arr,         r, c, i ){
    CAT_FILENOTFOUND = false
    filepath = filepath_adjustifwin( filepath )
    while ((c=(getline <filepath))==1) arr[ ++i ] = $0
    if (c == -1)    CAT_FILENOTFOUND = true
    close( filepath )
    return ( arr[L] = i )
}

function cat_is_filenotfound(){
    return CAT_FILENOTFOUND
}

BEGIN{
    IS_OS_WIN = int(ENVIRON[ "IS_OS_WIN" ])
}

# This is for cawk ...
function filepath_adjustifwin( fp ){
    if ( (IS_OS_WIN == 1) && match(fp, "^/[^/]") ) return substr(fp, 2, RLENGTH-1) ":/" substr(fp, RSTART+RLENGTH)
    return fp
}

function bcat_oct_init(){
    if (BCAT_INIT == 1) return
    BCAT_INIT = 1
    for (i=1; i<=256; ++i) OCTARR[ sprintf("%03o", i) ] = sprintf("%c", i)
}

# I remember this is for the binary file during the script module development.
function bcat( filepath, a,     _tmprs, _cmd, c ){
    _tmprs = RS
    # filepath = filepath_adjustifwin( filepath )
    _cmd = "hexdump -v -b " filepath " 2>/dev/null"

    i = 0; while ((c=(_cmd | getline))==1) {
        a[ ++i ] = OCTARR[$2]
        a[ ++i ] = OCTARR[$3]
        a[ ++i ] = OCTARR[$4]
        a[ ++i ] = OCTARR[$5]
        a[ ++i ] = OCTARR[$6]
        a[ ++i ] = OCTARR[$7]
        a[ ++i ] = OCTARR[$8]
        a[ ++i ] = OCTARR[$9]
        a[ ++i ] = OCTARR[$10]
        a[ ++i ] = OCTARR[$11]
        a[ ++i ] = OCTARR[$12]
        a[ ++i ] = OCTARR[$13]
        a[ ++i ] = OCTARR[$14]
        a[ ++i ] = OCTARR[$15]
        a[ ++i ] = OCTARR[$16]
        a[ ++i ] = OCTARR[$17]
    }
    if (c == -1)    CAT_FILENOTFOUND = true
    close(_cmd)

    RS = _tmprs
    return a[ L ] = i
}
# EndSection

# Section: ord.awk
# For those who need efficiency: BEGIN{ ord_init(); } { _ord_[]; }
function ord_init(    low, high, i, t) {
    if (low == "")  low = 0
    if (high == "") high = 255
    for (i = low; i <= high; i++) {
        t = sprintf("%c", i)
        _ord_[t] = i
    }
    ___ORD_INIT_FLAG = 1
}

function ord(c){
    if ( 1 != ___ORD_INIT_FLAG ) ord_init()
    return _ord_[c]
}

function ord_is_number(o) {     return ( (o >= 48) && (o <= 57) );  }
function ord_is_letter(o) {     return ! ((ord_is_uppercase(o) == false) && (ord_is_lowercase(o) == false)); }
function ord_is_uppercase(o) {  return ( (o >= 65) && (o <= 90) );  }
function ord_is_lowercase(o) {  return ( (o >= 97) && (o <= 122) ); }

function ord_leading1( o ){
    if (o < 128) return 0
    if (o < 192) return 1
    if (o < 224) return 2
    if (o < 240) return 3
    if (o < 248) return 4
    if (o < 252) return 5
    if (o < 254) return 6
    if (o < 256) return 7
}
# EndSection

# Section: arr
BEGIN {
    NULL = "\001"
}

function arr_len(arr, kp,   l){
    return int(arr[ kp L ] + 0)
}

function arr_seq( arr, s, delta, e,        i, c ){
    for (i=0; s<=e; s+=delta) arr[++i] = s
    arr[ L ] = i
    return i
}

function arr_eq( a1, a2,            i, l ){
    if ((l = arr_len(a1)) != arr_len(a2))       return false
    for (i=1; i<=l; i++) if (a1[i] != a2[i])    return false
    return true
}

function arr_get( a, i ){
    return a[i]
}

# arr[ ++arr[ L ] ] = elem
function arr_push(arr, elem,        l){
    arr[ L ] = l = arr[ L ] + 1
    arr[ l ] = elem
    return l
}

# arr[ arr[ L ] -- ]
function arr_pop(arr,   l){
    if ((l = arr[ L ]) < 1)     return NULL
    arr[ L ] = l - 1
    return arr[ l ]
}

# arr[ arr[ L ] ]
function arr_top(arr,   l) {
    if ((l = arr[ L ]) < 1)     return NULL
    return arr[ l ]
}

function arr_join(arr,              _sep, _start, l,              _i, _result) {
    if (_sep == "")             _sep = "\n"
    if (_start == "")           _start = 1
    if (l == "")                l = arr[ L ]

    if (l < 1) return ""

    _result = arr[1]
    for (_i=2; _i<=l; ++_i)      _result = _result _sep arr[_i]
    return _result
}

# arr[ L ] = split(str, arr, sep)
# function arr_split(arr, str, sep,       l){
function arr_cut(arr, str, sep,       l){
    l = split(str, arr, sep)
    return arr[ L ] = l
}

function arr_clone( src, dst,   l, i ){
    l = src[ L ]
    for (i=1; i<=l; ++i)  dst[i] = src[i]
    return dst[ L ] = l
}

# function arr_clone( src, dst, kp,       l, i ){
#     dst[ L ] = l = src[ kp L ]
#     for (i=1; i<=l; ++i)  dst[i] = src[ ( (kp != "") ? kp SUBSEP : kp ) i]
#     return l
# }

function arr_shift( arr, offset,        l, i ){
    l = arr[ L ] - offset
    for (i=1; i<=l; ++i) arr[i] = arr[i+offset]
    arr[ L ] = l
    return l
}

function arr_unshift( arr, v,        l, i ){
    arr[ L ] = l = arr[ L ] + 1
    for (i=l; i>=1; --i) arr[i] = arr[i-1]
    arr[1] = v
    return l
}

function arr_rev( arr,      l, i, l2, t ){
    l2 = (l = arr[ L ]) / 2
    for (i=1; i<=l2; ++i) {
        t = arr[i]
        arr[i] = arr[l-i+1]
        arr[l-i+1] = t
    }
    return l
}

function arr_print( arr, s, l,  i, l2, t ){
    l = (l=="") ? arr[L] : l
    for (i= (s=="") ? 1 : s ; i<=l; ++i) print arr[i]
}

function arr_pr( arr, sep, start, step, end ){
    if (sep == "")  sep = "\n"
    if (step == "") {
        seq_parse( start )
        start   = SEQ_START
        step    = SEQ_STEP
        end     = SEQ_END
    } else {
        if (end == "")  end = arr[L]
    }

    if (step < 0)   for (i=start; i>=end; i+=step) printf("%s%s", arr[i], sep)
    else            for (i=start; i<=end; i+=step) printf("%s%s", arr[i], sep)
}

function arr_pl( arr, start, step, end ){
    return arr_pr( arr, "\n", start, step, end )
}

function arr_gc( arr, gcl,      i, j ){
    if ( (l = arr[ L ]) <= gcl ) return
    j = l - gcl
    for (i=1; i<=gcl; ++i) arr[i] = arr[j+i]
    arr[ L ] = gcl
}

# tgtl == 10 * gcl
function arr_gcwhen( arr, tgtl, gcl,      i, j ){
    if ( (l = arr[ L ]) <= tgtl ) return false
    arr_gc(arr, gcl)
    return true
}

function arr_uniq( arr,         l, i, j ) {
    l = arr[ L ]
    j = 1
    for (i=2; i<=l; ++i) {
        if (arr[i] != arr[i-1]) arr[++j] = arr[i]
    }
    return arr[ L ] = j
}
# EndSection

# Section: str

# Add Code
function str_escape(s) {
    gsub( "\\\\", "&\\", s )
    gsub(/\b/, "\\b", s)
    gsub(/\t/, "\\t", s)
    gsub(/\n/, "\\n", s)
    gsub(/\r/, "\\r", s)
    gsub(/\n/, "\\n", s)
    gsub(/"/, "\\\"", s)
    gsub(/\//, "\\/", s)
    return "\"" s "\""
}

function str_quote1(str){
    gsub(/\\/, "&\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function str_unquote1(str){
    gsub(/\\\\/, "\\", str)
    gsub(/\\'/, "'", str)
    return substr(str, 2, length(str)-2)
}


function str_quote2(str){
    gsub(/\\/, "&\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function str_unquote2(str){
    gsub(/\\\\/, "\\", str)
    gsub(/\\"/, "\"", str)
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
    gsub(/[ \t\b\v\n]+$/, "", astr)
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


### Section: str module

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

function str_joinwrap(sep, left, right, obj, prefix, start, end,     i, _result) {
    _result = (start <= end) ? left obj[prefix start] right : ""
    for (i=start+1; i<=end; ++i) _result = _result sep left obj[prefix i] right
    return _result
}

### EndSection

BEGIN{
    # STR_TERMINAL_ESCAPE033 = "\033\\[([0-9]+;)*([0-9]+)?(m|dh|A|B|C|D)"
    STR_TERMINAL_ESCAPE033 = "\033\\[[^A-Za-z]*(dh|[A-Za-z=])"
    STR_TERMINAL_ESCAPE033_LIST = "(" STR_TERMINAL_ESCAPE033 ")+"
    TRIM033 = STR_TERMINAL_ESCAPE033_LIST
}

function str_len( s ) {         return length( s );     }
function str_len_noesc( s ){    return length( str_remove_esc( s ) );   }

function trim033( text ){
    gsub( TRIM033, "", text )
    return text
}

function str_remove_esc(text){
    gsub( STR_TERMINAL_ESCAPE033_LIST, "", text )
    return text
}

# TODO: Deprecated.
function str_remove_style(text){
    return str_remove_esc( text )
}

function str_divide_( astr, _sep,     i ){
    i = index( astr, _sep )
    x_1 = substr( astr, 1, i-1 )
    x_2 = substr( astr, i+1 )
}

function str_divide( astr, _sep, ret,    i ){
    i = index( astr, _sep )
    ret[1] = substr( astr, 1, i-1 )
    ret[2] = substr( astr, i+1 )
}
# EndSection


# Section: ring
BEGIN{
    RING_MOD        = 1
    RING_COUNTER    = 2
    RING_OFFSET     = 3
}
function ring_init( o, mod ){
    o[ RING_MOD ]        = mod
    o[ RING_COUNTER ]   = 0
}

function ring_add( o, element,        m, n, i ){
    n = (o[ RING_COUNTER ] += 1)
    m = o[ RING_MOD ]
    o[ RING_OFFSET + (n % m) ] = element
}

# i start with 1
function ring_get( o, i,   m, n ){
    n = o[ RING_COUNTER ]
    m = o[ RING_MOD ]

    if ( n < m ) {
        return o[ RING_OFFSET + i ]
    } else {
        return o[ RING_OFFSET + ( (n + i) % m ) ]
    }
}

function ring_counter( o ){
    return o[ RING_COUNTER ]
}

function ring_size( o ){
    n = o[ RING_COUNTER ]
    m = o[ RING_MOD ]

    if ( n < m )    return n
    else            return m
}

# TODO: ...
# function ring_dump( o, tgt,   m, n, i ){
#     n = o[ RING_COUNTER ]
#     m = o[ RING_MOD ]

#     if ( n < m ) {
#         for (i=1; i<=n; ++i)  tgt[ i ] = o[ RING_OFFSET + i ]
#     } else {
#         j = 0
#         for (i = (n + 1) % m; i<m; ++i) tgt[ ++j ] = o[ RING_OFFSET + i ]
#         i = i - m
#         for (; j<=m; ++j)  tgt[ ++j ] = o[ RING_OFFSET + (i++) ]
#     }
# }

# EndSection
