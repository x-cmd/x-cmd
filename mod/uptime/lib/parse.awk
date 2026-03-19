BEGIN{
    if (NO_COLOR != 1) {
        UI_KEY = "\033[36m"
        UI_VAL = "\033[32m"
        UI_END = "\033[0m"
    }
}

function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function lag_trim(astr){
    gsub(/,/, "", astr)
    return str_trim( astr )
}

{
    printf(UI_KEY "%-15s"   UI_END "  :  " UI_VAL "%s\n"    UI_END,     "Current-time"      , str_trim($1) )

    str = $0
    sub("^.*up[ \t]+", "", str)
    sub("user.*", "", str)
    match(str, ",[ \t][^,]+$")
    uptime = substr(str, 1, RSTART-1)
    user = str_trim( substr(str, RSTART+1) )
    printf(UI_KEY "%-15s"   UI_END "  :  " UI_VAL "%s\n"    UI_END,     "System-uptime"     , uptime )

    printf(UI_KEY "%-15s"   UI_END "  :  " UI_VAL "%s\n"    UI_END,     "Number-of-users"   , (user) )
    printf(UI_KEY "%-15s"   UI_END "  :\n" UI_END,                      "Load-average" )
    printf(UI_KEY "  %-8s"  UI_END "  :  " UI_VAL "%6s\n"    UI_END,     "1-min"            , lag_trim($(NF-2)) )
    printf(UI_KEY "  %-8s"  UI_END "  :  " UI_VAL "%6s\n"    UI_END,     "5-min"            , lag_trim($(NF-1)) )
    printf(UI_KEY "  %-8s"  UI_END "  :  " UI_VAL "%6s\n"    UI_END,     "15-min"           , lag_trim($(NF)) )

}