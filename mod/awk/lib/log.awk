BEGIN{
    LOG_COLOR_INFO  = ( ___X_CMD_LOG_C_INFO != "" )  ? ___X_CMD_LOG_C_INFO  : "\033[1;36m"
    LOG_COLOR_WARN  = ( ___X_CMD_LOG_C_WARN != "" )  ? ___X_CMD_LOG_C_WARN  : "\033[1;33m"
    LOG_COLOR_ERROR = ( ___X_CMD_LOG_C_ERROR != "" ) ? ___X_CMD_LOG_C_ERROR : "\033[1;31m"
    LOG_COLOR_DEBUG = ( ___X_CMD_LOG_C_DEBUG != "" ) ? ___X_CMD_LOG_C_DEBUG : "\033[2;35m"
}

function log_info( mod, msg ){
    log_level( LOG_COLOR_INFO, "INF", mod, msg )
}

function log_warn( mod, msg ){
    log_level( LOG_COLOR_WARN, "WRN", mod, msg )
}

function log_error( mod, msg ){
    log_level( LOG_COLOR_ERROR, "ERR", mod, msg )
}

function log_debug( mod, msg ){
    log_level( LOG_COLOR_DEBUG, "DBG", mod, msg )
}

function log_level( color, level, mod, msg ){
    # printf("[%s] <%s> : %s", level, mod, msg) >"/dev/stderr"
    printf("%s[%s] <%s> :\033[0m %s\n", color, level, mod, msg) >"/dev/stderr"
}
