
BEGIN{
    RE_LOG_CHECK = "^(\\[(ERR|WRN|INF|DBG)\\] <[A-Za-z0-9_-]+>)"
    RE_LOG_DEBUG ="^\\[DBG\\] <[A-Za-z0-9_-]+>"
    RE_LOG_INFO  ="^\\[INF\\] <[A-Za-z0-9_-]+>"
    RE_LOG_WARN  ="^\\[WRN\\] <[A-Za-z0-9_-]+>"
    RE_LOG_ERROR ="^\\[ERR\\] <[A-Za-z0-9_-]+>"
}

# function is_log_item(){

# }

function parse_level_code( item,        s   ){
    s = substr(item, 2, 3)
    if (s == "DBG")     return 1
    if (s == "INF")     return 2
    if (s == "WRN")     return 3
    if (s == "ERR")     return 4
}

function level_code2displayname( code ){
    if (code == 1)      return "DBG"
    if (code == 2)      return "INF"
    if (code == 3)      return "WRN"
    if (code == 4)      return "ERR"
}

# function parse_logger_name( item ){
#     if (match(item, RE_LOG_CHECK))  return substr(item, 8, RLENGTH - 9)
# }

function parsetest( item ){
    if (match(item, RE_LOG_CHECK) == 0)     return 0

    last_logger = logger
    last_code = code
    last_body = body

    logger = substr(item, 8, RLENGTH - 8)
    code = parse_level_code(item)
    body = substr(item, RLENGTH+3)
    return 1
}

BEGIN{
    FS = ""
}

function level_code2theme( code ){
    if (code == 1)      return "\033[32m"
    if (code == 2)      return "\033[1;34m"
    if (code == 3)      return "\033[1;33m"
    if (code == 4)      return "\033[1;31m"
}

{
    if ( ! parsetest($0) )  next

    display_logger = "<" logger ">"
    display_level_name = "[" level_code2displayname(code) "]"
    if (last_logger == logger) {
        gsub(/./, " ", display_logger)
        if (last_code == code) {
            gsub(/./, " ", display_level_name)
        }
    }

    print level_code2theme(code)    display_logger " " display_level_name  "\t"    body    "\033[0m"
}

