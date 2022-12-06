# Section: utils
BEGIN{
    UI_ADVISE_WARN = "\033[33;1m"
    UI_ADVISE_END  = "\033[0m"
    if( ADVISE_NO_COLOR == true ) UI_ADVISE_WARN = UI_ADVISE_END = ""
    # EXIT_CODE = 0
}

function advise_panic(msg){
    CODE = "_message_str='" UI_ADVISE_WARN "[ADVISE PANIC]: " msg UI_ADVISE_END "'"
    return false
}

function str_escape_colon(s){
    gsub(":", "\\:", s)
    return s
}
## EndSection
