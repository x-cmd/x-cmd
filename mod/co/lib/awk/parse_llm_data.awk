BEGIN{
    NO_COLOR = ENVIRON[ "NO_COLOR" ]
    if (!NO_COLOR) {
        yml_style_key = "\033[1;34m"
        yml_style_val = "\033[1;36m"
        yml_style_end = "\033[0m"
    }
}

BEGIN{
    num = 0
    msg = ENVIRON[ "msg" ]
    while ( match(msg, "<CMD>") ){
        msg = substr(msg, RSTART+RLENGTH)
        if ( ! match(msg, "</CMD>") )   break
        ARR[ ++num, "cmd" ] = substr(msg, 1, RSTART-1)
        msg = substr(msg, RSTART+RLENGTH)

        if ( ! match(msg, "<DESC>") )   break
        msg = substr(msg, RSTART+RLENGTH)
        if ( ! match(msg, "</DESC>") )  break
        ARR[ num, "desc" ] = substr(msg, 1, RSTART-1)
        msg = substr(msg, RSTART+RLENGTH)
    }

    print yml_format_log(ARR, num) > "/dev/stderr"

    print "local _cmd_num=" int(num) " >/dev/null"
    for (i=1; i<=num; ++i){
        print "local _cmd_" i " >/dev/null; _cmd_" i "=" qu1(ARR[ i, "cmd" ])
        print "local _desc_" i " >/dev/null; _desc_" i "=" qu1(ARR[ i, "desc" ])
    }
}

function yml_format_log(ARR, num,           _res, i){
    if ( num <= 0 ) return
    indent = "  "
    _res = "- " yml_style_key "answer" yml_style_end ":"
    for (i=1; i<=num; ++i){
        _res = _res "\n" indent "- " yml_style_key "cmd" yml_style_end ": " yml_format_log_item(ARR[ i, "cmd" ]) "\n" \
            indent indent yml_style_key "desc" yml_style_end ": " yml_format_log_item(ARR[ i, "desc" ])
    }
    return _res
}

function yml_format_log_item(s){
    if (s !~ "\n") return yml_style_val s yml_style_end

    s = "\n" s
    gsub("\n", "\n" indent indent indent, s)
    return "|" yml_style_val s yml_style_end
}
