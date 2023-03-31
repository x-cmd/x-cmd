BEGIN {
    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
    S = SUBSEP
    T = "\002"
    L = "\003"
}

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

# Section: exit
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

# Section: jqu

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

# This is for refactor
function alength_get( a, prefix ){
    return a[ prefix L ]
}

function alength_put( a, prefix, l ){
    return a[ prefix L ] = l
}

