# Section: visualize

function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

function strlen_without_color(text){
    gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    return wcswidth(text)
}

function get_space(space_len,      _space, _j){
    _space=""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}

function cut_info_line(info, space_len, color,
    _info_len, _info_arr_len, _info_arr_real_len, _info_line, _info_arr_key, _arr){
    _info_line         = ""
    _info_arr_len      = 0
    _info_arr_real_len = 0
    _info_arr_key      = 0

    _info_len     = strlen_without_color(info)
    _info_arr_key = split(info, _arr, " ")

    if (_info_len < COLUMNS-space_len) {
        _info_line = info get_space(COLUMNS-space_len-_info_len)
    } else {
        for (_i=1; _i<=_info_arr_key; ++_i) {
            _info_arr_len      = _info_arr_len + strlen_without_color(_arr[_i])
            _info_arr_real_len = _info_arr_real_len + length(_arr[_i])

            if (_info_arr_len >= COLUMNS-space_len) {
                _info_arr_len      = _info_arr_len - strlen_without_color(_arr[_i])
                _info_arr_real_len = _info_arr_real_len - length(_arr[_i])
                break
            }
        }
        _info_line         = _info_line substr(info,1,_info_arr_real_len) get_space(COLUMNS - space_len - _info_arr_len) color get_space(space_len) cut_info_line(substr(info,_info_arr_real_len+1), space_len,color)
        _info_arr_len      = 0
        _info_arr_real_len = 0
    }
    return color _info_line
}

function handle_title(title){
    printf("\033[0;40m%s\033[1;40m", get_space(COLUMNS))
    printf("\033[1;32;40m%s: \033[0;40m", title)
    return int(strlen_without_color(title)+2)
}

function handle_desc(desc, title_len){
    printf("\033[1;33;40m%s%s%s\n\033[0;40m", desc, get_space(COLUMNS-title_len-strlen_without_color(desc)-1)," ")
}


function handle_cmd(cmd,     _max_len, _i, _key_len, _cmd_text){
    _max_len = 0
    _key_len = 0

    printf("\033[0;40m%s%s\033[1;40m", get_space(COLUMNS-1), " ")
    for (_i=0; _i<cmd_key; _i++) {
        _cmd_text = cmd[ _i "text"]

        while (match(_cmd_text, /\{\{[^\{]+\}}/)) {
            _cmd_text = substr(_cmd_text,1,RSTART-1) out_cmd_key_color substr(_cmd_text,RSTART+2, RLENGTH-4) out_cmd_key_color substr(_cmd_text, RSTART + RLENGTH)
        }

        _key_len        = strlen_without_color(_cmd_text)
        cmd[ _i "text"] = _cmd_text

        if (_key_len > _max_len) {
            _max_len = _key_len
        }
    }

    if (_max_len > COLUMNS*0.6) {
        handle_long_cmd(cmd)
    } else {
        handle_short_cmd(cmd,_max_len)
    }
}

function handle_short_cmd(cmd, max_len,
    _cmd_info, _cmd_text, _i, _text){

    for (_i=0; _i<cmd_key; _i++) {
        _cmd_info = cmd[ _i "info"]
        _cmd_text = cmd[ _i "text"]
        gsub(/:[ ]*$/, "", _cmd_info)

        if (_i%2 == 0) {
            out_cmd_key_color  = "\033[1;33;40m"
            out_cmd_info_color = "\033[1;32;40m"
        } else {
            out_cmd_key_color  = "\033[1;37;40m"
            out_cmd_info_color = "\033[1;36;40m"
        }
        _text=out_cmd_key_color _cmd_text "\033[0;40m" get_space(max_len+4-strlen_without_color(_cmd_text)) out_cmd_info_color cut_info_line(_cmd_info,max_len+4, out_cmd_info_color)
        printf("%s\n\033[0;40m", _text)
    }
    printf("\033[0;40m%s%s\033[0;40m", get_space(COLUMNS-1), " ")
}

function handle_long_cmd(cmd,
    _cmd_info, _i, _cmd_len){

    for (_i=0; _i<cmd_key; _i++) {
        _cmd_len  = strlen_without_color(cmd[ _i "text"])
        _cmd_info = cmd[ _i "info"]
        gsub(/:[ ]*$/, "", _cmd_info)

        while (_cmd_len > COLUMNS) {
            _cmd_len=_cmd_len-COLUMNS
        }

        printf("\033[1;33;40m%s%s\033[0;40m", cmd[ _i "text"], get_space(COLUMNS-_cmd_len))
        printf("    \033[1;36;40m%s\n\033[0;40m", cut_info_line(_cmd_info,4,"\033[1;36;40m"))
        printf("\033[0;40m%s%s\033[0;40m", get_space(COLUMNS-1), " ")
    }
}


# EndSection

BEGIN {
    if (COLUMNS == 0) COLUMNS=179
    printf("\033[0;40m%s", "")
    out_cmd_key_color  = ""
    out_cmd_info_color = ""
    cmd_key = 0
}

{
    if ($0 ~ /^[ \t\r]*$/){

    } else if ($1~/^#/)
    {
        title = $0
        gsub(/^#[ ]*/, "", title)
        title_len = handle_title(title)
    } else if ($1~/^>/) {
        desc = $0
        gsub(/^>[ ]*/, "", desc)
        handle_desc(desc, title_len)
        title_len = 0
    } else if ($1 ~ /^-/) {
        desc = $0
        gsub(/^-[ ]*/, "", desc)
        cmd_info = desc
    } else {
        if ($0 ~ /^`[^`]+`/) {
            gsub("`","  ",$0)
            cmd_text = substr($0, 1, length($0)-2)
            cmd[ cmd_key "text"] = cmd_text
            cmd[ cmd_key "info"] = cmd_info
            cmd_info = ""
            cmd_text = ""
            cmd_key++
        }
    }
}

END {
    handle_cmd(cmd)
    cmd_key = 0
    printf "\033[0m\n"
}
