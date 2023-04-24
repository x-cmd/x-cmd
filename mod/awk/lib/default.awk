BEGIN {
    false = FALSE = 0
    true  = TRUE  = 1
    S = SUBSEP
    T = "\002"
    L = "\003"
}

function clone( src, dst,   i ){    for (i in src) dst[i] = src[i];     }

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
    gsub(/\\/, "\\\\", str)
    gsub(/'/, "\\'", str)
    return "'" str "'"
}

function var_set(name, value){
    return sprintf("%s=%s", name, var_quote1(value))
}
# EndSection

# Section: json
function juq( str ){
    # if (str !~ /^".*"$/) return str         # TODO: remove in the future

    str = substr( str, 2, length(str)-2 )
    gsub( /\\\\/, "\001", str )
    gsub( /\\"/, "\"", str )
    gsub( /\\n/, "\n", str )
    gsub( /\\t/, "\t", str )
    gsub( /\\v/, "\v", str )
    gsub( /\\b/, "\b", str )
    gsub( /\\r/, "\r", str )
    gsub( "\\/", "/", str )                 # Notice: This is for the bwh json.
    gsub( "\001", "\\", str )
    return str
}

function juq1( str ){
    # if (str !~ /^".*"$/) return str         # TODO: remove in the future

    str = substr( str, 2, length(str)-2 )
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

function jqu( str ){
    # if (str ~ /^".*"$/) return str

    gsub( "\\\\", "&\\", str )
    gsub( "\"", "\\\"", str )
    gsub( "\n", "\\n", str )
    gsub( "\t", "\\t", str )
    gsub( "\v", "\\v", str )
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

function opt_getor( arr, k,   default ){
    return ( arr[ k ] == "" ) ? default : arr[ k ]
}
# EndSection

# Section: seq
function seq( seqstr, a,    i, j ){
    seq_parse( seqstr )
    for (i=SEQ_START; i<=SEQ_END; i+=SEQ_STEP) a[ ++j ] = i
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
    return ( (number >= SEQ_START) && (number <= SEQ_END) && ( 0 == (number - SEQ_START) % SEQ_STEP ) )
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
