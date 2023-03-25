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
