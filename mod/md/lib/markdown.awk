BEGIN {
    false = 0
    true = 1
    IS_BLOCK = false
    IS_NOTE = false
    block_str = ""

    out_color_italy         = "\033[3;36m"
    out_color_bold          = "\033[1m\033[4m"
    out_color_del           = "\033[9m"
    # out_color_backtick      = "\033[41;37m""\033[7m"
    out_color_backtick      = "\033[48;5;251;31m"
    out_color_url           = "\033[0;32m"

    out_color_bullet        = "\033[0m" "\033[1;35m"
    out_color_bullet2       = "\033[0m"

    out_color_ordered       = "\033[0m" "\033[1;35m"
    out_color_ordered2      = "\033[0m"

    out_color_head1         = "\033[1;34m" "\033[7;34m"
    out_color_head2         = "\033[1;34m" "\033[7;34m"
    out_color_head21        = "\033[0;34m" "\033[4;34m"
    out_color_head22        = "\033[0;34m"
    out_color_head3         = "\033[1;34m" "\033[4;34m"

    out_color_block         = "\033[2m"

    out_color_end = "\033[0m"

    # indent_arr
    last_line_is_order = false
    order_block_count = 0

    last_lead_indent = ""
}

# Section : utils

function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

function str_trim(astr){
    gsub(/^[ \r\t\b\v\n]+/, "", astr)
    gsub(/[ \r\t\b\v\n]+$/, "", astr)
    return astr
}

function str_rep(char, number, _i, _s) {
    for (   _i=1; _i<=number; ++_i  ) _s = _s char
    return _s
}

# list
# url
# TODO
# simple language color engine

function str_center(text, linelen, _len, _len1){
    _len = wcswidth(text)
    _len1 = (linelen - _len) / 2
    return sprintf ("%" _len1 "s%s" "%" (linelen - _len - _len1 + 1) "s", "", text, "")
}

# EndSection

# Section : show_block
function show_block(){
    if (block_str != "") {
        gsub(/\n/, "\n  \033[0;34m> \033[0;33m", block_str)
        block_str = substr(block_str, 2)
        print out_color_ordered2 "  ```"
        print out_color_end block_str out_color_ordered2
        printf("%s\n" , "  ```" out_color_end)
        block_str = ""
    }
}

# EndSection

# Section : show_table
function show_table( table_str,  _line, _line_arr, _line_len, _table, _table_col_maxw, _cell ,_last_token_len,_token_len2){

    _line_len = split( substr(table_str, 2), _line_arr, /\n/ )
    _token_len = split( _line_arr[2], _token_arr, "|" )

    _last_token_len = _token_len

    _count_underline = 0
    for ( _i=1; _i<=_token_len; ++_i) {
        _token = str_trim( _token_arr[ _i ] )
        if(_token == "") {
            _last_token_len--
        }
        if (_token !~ /\-+/) {
            if (_token != "") return false
            else {
                if ( (_i == 1) || (_i == _token_len) ) continue
                return false
            }
        } else {
            _count_underline = _count_underline + 1
        }
    }

    if ( _count_underline == 0 ) return false


    for ( _i=1; _i <= _line_len; ++_i ) {
        _line = str_trim(_line_arr[ _i ])
        gsub(/^\|?/, "", _line)
        gsub(/\|$/, "", _line)

        _token_len2 = split( _line, _token_arr, "|" )
        for ( _j=1; _j <= _token_len2; ++_j ) {
            _cell = str_trim( _token_arr[_j] )
            _cell_len = wcswidth(_cell) # Should not count the non-printable characters
            _cell = markdown_text_render(_cell)
            _cell_len = _cell_len - FORMAT_DEL_NUM
            if (_cell_len > _table_col_maxw[ _j ])  _table_col_maxw[ _j ] = _cell_len
            _table[ _i RS _j ] = _cell
            _table[ _i RS _j RS "LEN" ] = _cell_len
        }
    }

    for ( _i=1; _i <= _line_len; ++_i ) {
        if (_i == 2) continue
        if (_i == 1) printf out_color_end
        for ( _j=1; _j <= _last_token_len; ++_j) {
            _cell_len = _table_col_maxw[_j] + 2
            _cell = _table[ _i RS _j ]
            _size = _table[ _i RS _j RS "LEN" ]
            if ( _j == _last_token_len ) {
                if (_i == 1){
                    printf("\033[7m   %s", _cell sprintf("%" (_cell_len - _size) "s", ""))
                }else{
                    printf("   %s", _cell sprintf("%" (_cell_len - _size) "s", ""))
                }
                # printf(" %s", _cell sprintf("%" (_cell_len - _size) "s", ""))
            } else {
                if (_i == 1){
                    printf("   %s","\033[7m" _cell sprintf("%" (_cell_len - _size) "s""\033[7m", "|"))
                }else{
                    printf("   %s", _cell sprintf("%" (_cell_len - _size) "s", "|"))
                }
                # printf(" %s", _cell sprintf("%" (_cell_len - _size) "s", "|"))
            }
        }
        printf "\033[0m\n"
    }
    return true
}

# EndSection

# Section : url
# function show_url(tmp,color){
#     if(!color) color=out_color_end
#     if(match(tmp, /\[[^\[]+\]\([^\(]+\)/)){
#         _RSTART=RSTART
#         _RLENGTH=RLENGTH
#         tmpUrl=substr(tmp,_RSTART,_RLENGTH)
#         if(match(tmpUrl,/\]\(/)){
#             tmpUrl = "\033[4m" substr(tmpUrl,2,RSTART-2)out_color_end "\033[3;90m" substr(tmpUrl,RSTART+1)
#         }
#         tmp = substr(tmp,1,_RSTART-1) out_color_url tmpUrl out_color_end show_url(substr(tmp, _RSTART + _RLENGTH),out_color_end)
#     }
#     return tmp
# }
# EndSection

# Section : table
function markdown_text_render(tmp,color) {

    # debug(tmp)

    if(!color){
        color=out_color_end
    }

    FORMAT_DEL_NUM = 0

    gsub(/\\\\/, "\001", tmp)
    gsub(/\\`/, "\002", tmp)

    while (match(tmp, /\*\*[^\*]+\*\*/ ) || match(tmp,/__[^_]+__/) ) {
        tmp = substr(tmp, 1, RSTART-1) out_color_bold substr(tmp, RSTART+2, RLENGTH-4) color substr(tmp, RSTART + RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM + 4
    }

    while (match(tmp, /\*[^\*]+\*/ ))  {
        tmp = substr(tmp, 1, RSTART-1) out_color_italy substr(tmp, RSTART+1, RLENGTH-2) color substr(tmp, RSTART + RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM + 2
    }

    while (match(tmp, /~~[^~]+~~/ )) {
        tmp = substr(tmp, 1, RSTART-1) out_color_del substr(tmp, RSTART+2, RLENGTH-4) color substr(tmp, RSTART + RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM + 4
    }

    while (match(tmp, /`[^`]+`/ )) {
        tmp = substr(tmp, 1, RSTART-1) out_color_backtick " " substr(tmp, RSTART+1, RLENGTH-2) " " color substr(tmp, RSTART + RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM
    }
    while (match(tmp, /``[^`]+``/ )) {
        tmp = substr(tmp, 1, RSTART-2) out_color_backtick " " substr(tmp, RSTART+2, RLENGTH-4) " " color substr(tmp, RSTART + RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM + 2
    }

    while (match(tmp, /```[^`]+```/ )) {
        tmp = substr(tmp, 1, RSTART-3) out_color_backtick " " substr(tmp, RSTART+3, RLENGTH-6) " " color substr(tmp, RSTART + RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM + 4
    }
    while(match(tmp, /\[[^\[]+\]\([^\(]+\)/)){
        _RSTART=RSTART
        _RLENGTH=RLENGTH
        tmpUrl=substr(tmp,_RSTART,_RLENGTH)
        if(match(tmpUrl,/\]\(/)){
            # tmpUrl = "\033[4m\033[1m" substr(tmpUrl,2,RSTART-2)
            tmpUrl = "\033[1m" substr(tmpUrl,2,RSTART-2) "\033[2;3;4m" substr(tmpUrl,RSTART+1)
        }
        tmp = substr(tmp,1,_RSTART-1) out_color_url tmpUrl color substr(tmp, _RSTART + _RLENGTH)
        FORMAT_DEL_NUM = FORMAT_DEL_NUM + 2
    }

    gsub("\001", "\\\\", tmp)
    gsub("\002", "\\`", tmp)
    gsub("\003", "*", tmp)
    gsub("\004", "~", tmp)

    return tmp
}
# EndSection

# Section : main
function consume_line(text,   tmp, _i){
    match(text, /^<!--.+-->/)
    if (RSTART > 0) {
        text = substr(text, 1, RSTART-1) substr(text, RSTART + RLENGTH)
    }

    if (IS_NOTE == true) {
        if (text ~ /-->[ ]+/) {
            IS_NOTE = false
            return
        }
        return
    }

    if (text ~ /^<!--/ && text !~ /-->$/){
        if (IS_NOTE == false) {
            IS_NOTE = true
            return
        }
    }

    if (text ~ /^---$/ ){
        for (_i=5; _i<COLUMNS; ++_i){
            text = text "-"
        }
    }

    if (IS_BLOCK == true) {
        # if (text == "```" || text == "````") {
        if (text ~ /```/) {
            IS_BLOCK = false
            show_block()
            return
        }
        block_str = block_str "\n" text
        return
    }

    # if (text ~ /^```/ && text !~ /```$/){
    if (text ~ /```/ && text !~ /```[^`]+```/){
        if (IS_BLOCK == false) {
            IS_BLOCK = true
            return
        }
    }

    # match(text, /^[ \t]*#[ ]+/)
    # if (RSTART > 0)
    # {
    #     tmp = substr(text, RSTART + RLENGTH)
    #     printf out_color_head1
    #     printf ( "%s\n", sprintf("%" COLUMNS  "s", "") )
    #     # printf ( "%s%s\n", tmp, sprintf("%" COLUMNS - wcswidth(tmp) "s", "") )
    #     print str_center(tmp, COLUMNS)
    #     printf ( "%s\n", sprintf("%" COLUMNS "s", "") out_color_end )
    #     # printf ( "%s\n", str_rep("=", length(tmp) + 2 ) out_color_end )

    #     return
    # }

    # match(text, /^[ \t]*##[ ]+/)
    # if (RSTART > 0)
    # {
    #     tmp = substr(text, RSTART + RLENGTH)

    #     # printf ( "%s\n", out_color_head21 sprintf("%" COLUMNS "s", "") )
    #     printf ( "%s\n", out_color_head21 str_rep("-", COLUMNS) )
    #     printf out_color_end
    #     printf out_color_head2
    #     # printf ( "%s\n", sprintf("%" COLUMNS "s", "") )
    #     printf ( "%s%s\n", tmp, sprintf("%" COLUMNS - wcswidth(tmp) "s", "") )
    #     # printf ( "%s\n", sprintf("%" COLUMNS "s", "") )
    #     # printf ( "%s\n", str_rep("-", length(tmp) + 2 ) out_color_end )
    #     printf out_color_end
    #     printf ( "%s\n", out_color_head22 str_rep("-", COLUMNS) )
    #     printf out_color_end
    #     return
    # }

    match(text, /^[ \t]*#{1,6}[ ]+/)
    if (RSTART > 0)
    {
        tmp = substr(text, RSTART + RLENGTH)
        printf ("  %s%s%s\n", out_color_head3, substr(text, RSTART , RLENGTH) , markdown_text_render(tmp), sprintf("%" COLUMNS - wcswidth(tmp) "s", "") )
        printf out_color_end
        return
    }
    tmp = text

    if (match(tmp, /^<.+>/)){
        tmp = substr(tmp, 1, RSTART-1) out_color_url substr(tmp,RSTART,RLENGTH) out_color_end substr(tmp, RSTART + RLENGTH)
    }

    if (match(tmp, /^[ ]*\- / ) || match(tmp, /^[ ]*\+ / ) || match(tmp, /^[ ]*\* / )) {
        tmp = out_color_bullet "●" substr(tmp, 2, RSTART + RLENGTH - 2) \
            out_color_bullet2 markdown_text_render(substr(tmp, RSTART + RLENGTH),out_color_bullet2) out_color_end
    } else if (match(tmp, /^[ \t]*[0-9]+\. / )) {
        _RSTART = RSTART
        _RLENGTH = RLENGTH

        match( tmp, /^[ ]*/ )
        lead_indent = substr(tmp, 1, RLENGTH)
        order = indent_arr[order_block_count RS RLENGTH]


        if (order == "")    order = 1
        else                order = order + 1
        indent_arr[order_block_count RS RLENGTH] = order

        sub(/[0-9]+/, order, tmp)
        last_line_is_order = true

        tmp = out_color_ordered substr(tmp, 1, _RSTART + _RLENGTH - 1) \
            out_color_ordered2 \
            markdown_text_render(substr(tmp, _RSTART + _RLENGTH),out_color_ordered2) \
            out_color_end

        for (_i = length(lead_indent) + 1; _i <= length(last_lead_indent); ++_i) {
            indent_arr[order_block_count RS _i] = ""
        }


        last_lead_indent = lead_indent
    } else {
        if (last_line_is_order == true) {
            last_line_is_order = false
            order_block_count = order_block_count + 1
        }
    }

    if (tmp ~ /\|[^\|]+/) {
        table_block = table_block "\n" tmp
        # debug(table_block)
        return
    } else {
        if (table_block != "") {
            if ( false == show_table( table_block ) ) {
                tmp = substr(table_block, 2) "\n" tmp
            }
            table_block = ""
        }
    }

    tmp = markdown_text_render(tmp)
    print "  " out_color_end tmp
}

{
    consume_line($0)
}

END {
    # debug(table_block)
    if (table_block != "") {
        if ( false == show_table( table_block ) ) {
            tmp = substr(table_block, 2)
            tmp = markdown_text_render(tmp)
            print out_color_end tmp
        }
        table_block = ""
    }
    # show_block()
}

# EndSection

