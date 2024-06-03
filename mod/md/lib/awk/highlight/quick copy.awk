# This is not a strict

BEGIN{
    TERMINAL_ESCAPE033 = "\033\\[([0-9]+;)*([0-9]+)?(m|dh|A|B|C|D)"
    TERMINAL_ESCAPE033_LIST = "(" TERMINAL_ESCAPE033 ")+"
}

BEGIN {
    for (i=1;i<=cols;i++) begin_article = begin_article  "↔"
    ORS = "\n" "\033[2m" begin_article "\033[0m"

    print FILENAME

    MD_MODE_NORMAL=1
    MD_MODE_MLQUOTE=2       # multiple lines quote

    md_mode = MD_MODE_NORMAL

    mlquote_lang = ""

    TH_COLOR_MAIN = ""
}

# debug
function debug(msg){
    print "\033[1;31m" msg "\033[0;0m" > "/dev/stderr"
}

END {
    for (i=1;i<=cols;i++) end_text = end_text  "↔"
    ORS = "\n" "\033[2m" end_text "\033[0m"
    printf("FILENAME:%s " "NR =%s FNR =%s\n", "\033[38;5;027m"FILENAME"\033[0m" ,"\033[38;5;027m"" "NR"\033[0m", "\033[38;5;027m"" "FNR"\033[0m")
    print text
    printf("\033[38;5;196mEND Block\033[0m""   ""NR =%s FNR =%s\n", "\033[38;5;027m"" "NR"\033[0m", "\033[38;5;027m"" "FNR"\033[0m")
    print "Total number of records:","\033[38;5;027m"NR"\033[0m"
}


md_mode==MD_MODE_NORMAL{
    # 转义字符
        gsub("&nbsp;", " ", $0)
        gsub("&lt;", "<", $0)
        gsub("&gt;", ">", $0)
        gsub("&amp;", "\\&", $0)
        gsub("&quot;", "\"", $0)
        gsub("&apos;", "'", $0)
        gsub("&cent;", "￠", $0)
        gsub("&pound;", "£", $0)
        gsub("&yen;", "¥", $0)
        gsub("&sect;", "§", $0)
        gsub("&copy;", "©", $0)
        gsub("&reg;", "®", $0)
        gsub("&times;", "x", $0)
        gsub("&divide;", "÷", $0)

    # 代码片语言分类为 #afafff色
    #TODO:只把语言类型进行着色
    if ($0 ~ "^[ ]*{0,}```[^`]*$") {
        textb = RSTART
        texte = RLENGTH
        match($0,"```[^`]*$")

        mlquote_lang = substr($0,RSTART-3)
        s2 = substr($0,textb)

       text =   text "\n" "\033[38;5;147m" mlquote_lang "\033[0m"

       next
    }

    # 一级标题为 #ff0000红色
    if ($0 ~ "^\\s*# [^#]+$") {
        {
        for (i=1;i<=cols;i++) first_title_dividing_line = first_title_dividing_line "—"
        ORS = "\n" "\033[2m" first_title_dividing_line "\033[0m"
         }
        text =  text "\n" "\033[38;5;196m" "\033[1m" $0 "\033[0m" \
        "\n""\033[2m" first_title_dividing_line "\033[0m"

        next
    }

    ## 二级标题为 #ff5f00橙色 TODO:可选语法re
    if ($0 ~ "^\\s*## [^#]+$") {
        text = text "\n"  "\033[38;5;202m" $0 "\033[0m"
        next
    }

    ### 三级标题为 #d7af00黄色
    if ($0 ~ "^\\s*### [^#]+$") {
        text = text  "\n" "\033[38;5;178m" $0 "\033[0m"
        next
    }

    #### 四级标题为 #00d787绿色
    if ($0 ~ "^\\s*#### [^#]+$") {
        text = text "\n"  "\033[38;5;42m" $0 "\033[0m"
        next
    }

    ##### 五级标题为 #0087d7蓝色
    if ($0 ~ "^\\s*##### [^#]+$") {
        text = text "\n"  "\033[38;5;32m" $0 "\033[0m"
        next
    }

    ###### 六级标题为 #af00ff紫色
    if ($0 ~ "^\\s*###### [^#]+$") {
        text = text "\n" "\033[38;5;129m" $0 "\033[0m"
        next
    }
    # 分割线
{
    if ($0 ~ "(^[(-|*|_)]{3,}[ ]*)$") {
        for (i=1;i<=cols;i++) c=c "-"
        text = text "\n" "\033[2m" c "\033[0m"
        c = ""
        next
    }

    text = text "\n" handle_body( $0 )
    next
    }
}


# 代码块
md_mode==MD_MODE_MLQUOTE{
    if ($0 ~ "^```\\s*$") {
        text = text "\n" "\033[33m" "\033[1m" "```" "\033[0m"
        md_mode = MD_MODE_NORMAL
        next
    }

    text = text "\n" $0
    next
}

# 高亮内容显示 #afffd7色
function handle_body_quote( text,     s1, s2, r ){
    while (match(text, "`[^`]+`")) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART+1, RLENGTH-2)
        text = substr(text, RSTART+RLENGTH+1)

        r = r s1 "\033[38;5;226m" s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 链接为 #ff875f色
function handle_body_link( text,     s1, s2, r ,_regex ){
    _regex = "\\[[^\\]]*\\]\\([^)]+\\)"
    while (match(text, "^" _regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)
        gsub(TERMINAL_ESCAPE033_LIST, "", s2)
        r = r s1 "\033[38;5;209m"  s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 图片链接为 #87ff00色
function handle_body_pic( text,     s1, s2, r,_regex  ){
     _regex = "\\[[^\\]]*\\]\\([^)]+\\)"
    while (match(text, "^" "!"_regex )) {

        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)
        # gsub(TERMINAL_ESCAPE033_LIST, "", s1)
        r = r   "\033[38;5;118m" s1  s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 字体为斜体 #ffaf00色
function handle_body_italic( text,     s1, s2, r, _regex ){
    _regex = "\\*[^*]+\\*"
    while (match(text, "(^"_regex")|[^*]"_regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r s1 "\033[38;5;214m" "\033[3m"  s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 字体为倾斜体 #ff5faf色
function handle_body_tilter( text,     s1, s2, r ){
    while (match(text, "^" "_[^_]+_")) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r s1 "\033[38;5;214m" "\033[3m"  s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 字体为加粗 #87d7ff色
function handle_body_bold( text,     s1, s2, r, _regex ){
    _regex = "\\*\\*[^*]+\\*\\*|__[^_]+__"
    while (match(text, "(^"_regex")|[^*]"_regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+2)

        r = r s1 "\033[38;5;117m"  s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 字体为倾斜加粗 #af87ff色
function handle_body_bold_italic( text,     s1, s2, r, _regex ){
    _regex = "\\*\\*\\*[^*]+\\*\\*\\*"
    while (match(text, "(^"_regex")|[^*]"_regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r s1 "\033[38;5;141m" "\033[3m"  s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 文字是加下划线 #5f87ff色
function handle_body_strikethrough( text,     s1, s2, r ){
    while (match(text, "~~(.*?)~~")) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r s1 "\033[38;5;69m" "\033[4m"   s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 引用是 #005fff色
function handle_body_abstract( text,     s1, s2, r ){
    while (match(text, "(&gt;|>).*")) {
        s1 = substr(text, 1, RSTART)
        s2 = substr(text, RSTART+1, RLENGTH-1)
        text = substr(text, RSTART+RLENGTH+1)

        r = r s1 "\033[38;5;27m"  s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 一级无序列表为 #ff8700色
function handle_body_unordered_list1( text,     s1, s2, r ){
    while (match(text, "^[ \\s]*[-\\*\\+] +(.*)")) {

        s2 = substr(text, RSTART+2, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r   "\033[38;5;208m" "●" " "s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# TODO:二级无序列表
function handle_body_unordered_list2( text,     s1, s2, r ){
    while (match(text, "^\t*[-\\*\\+] +(.*)")) {

        s2 = substr(text, RSTART+2, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r   "\033[38;5;208m" "○" " "s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 有序列表为 #87d7ff色
function handle_body_ordered_list( text,     s1, s2, r ){
    while (match(text, "^[.A-Za-z0-9_-]*[0-9]+\\.(.*)")) {
        s1 = substr(text, 1, RSTART)
        s2 = substr(text, RSTART+1, RLENGTH-1)
        text = substr(text, RSTART+RLENGTH+1)

        r = r "\033[38;5;150m" s1 s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}

# 已完成任务列表 TODO:正则表达式影响有空格开头的代码块
function handle_body_task_list1( text,     s1, r ){
    #if ($0 !~ "^[ ]*{0,}```[^`]*$"){
    while (match(text, "^[ ]*(-|\\*) (\\[x]) ")) {
        text = substr(text, RSTART+RLENGTH)
        r =  "[✔]"          #"✅"
    }
    return ("" == r) ? text : r " " text
}

# 未完成任务列表
function handle_body_task_list2( text,     s1, r ){
    while (match(text, "^[  ]*(-|\\*) (\\[ ]) ")) {
        text = substr(text, RSTART+RLENGTH)
        r = r   "[ ]"        #"❌"
    }
    return ("" == r) ? text : r " " text
}

# TODO:tab
function handle_body_tab( text,     s1, s2, r ){
    while (match(text, "^[\t].*$")) {
        s1 = substr(text, 1, RSTART)
        s2 = substr(text, RSTART+1, RLENGTH-1)
        text = substr(text, RSTART+RLENGTH+1)

        r = r "\033[41;5;150m" s1 s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}

# TODO:
# 表格
# \\|(?:([^\r\n\\|]*)\\|)+\r?\n\\|(?:(:?-+:?)\\|)+\r?\n(\\|(?:([^\r\n\\|]*)\\|)+\r?\n)+
function handle_body_table( text,     s1, s2, r ){
    while (match(text, "\\|[^\n]?\\|*")) {
        s1 = substr(text, 1, RSTART)
        print s1 "++++++++++++++++++++"
        s2 = substr(text, RSTART+1, RLENGTH-1)
        text = substr(text, RSTART+RLENGTH+1)

        r = r "\033[41;5;150m" s1 s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}
function handle_body_table( table_str,  _line, _line_arr, _line_len, _table, _table_col_maxw, _cell ,_last_token_len,_token_len2){

    _line_len = split( substr(table_str, 2), _line_arr, /\n/ ) # 分割线的长度判定
    _token_len = split( _line_arr[2], _token_arr, "|" )  # 分割线的数量

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
            _cell_len = wcswidth(_cell)
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
    return ture
     while (match(text, ture)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r    s1 "\033[2m"  s2  "\033[0m"
}
    return ("" == r) ? text : r text
}

# # 脚注
# 背景高亮

function handle_body_bghighlight( text,     s1, s2, r, _regex ){
    _regex = "\\=\\=[^\\=]+\\=\\="
    while (match(text, "(^"_regex")|[^\\=]"_regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+2)

        r = r s1 "\033[43;5;125m"  s2 "\033[0m"
    }
    return ("" == r) ? text : r text
}


# TODO:注释
function handle_body_exegesis( text,     s1, s2, r, _regex ){
    _regex = "//[^\n]*|#+[^\n]*"
    while (match(text, "(^|([ ]+))" _regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH+1)

        r = r    s1 "\033[2m"  s2  "\033[0m"
    }
    return ("" == r) ? text : r text
}

function handle_body( text,     s1, s2, r ){
    text = handle_body_exegesis( text )
    text = handle_body_quote( text )
    text = handle_body_tilter( text )
    text = handle_body_italic( text )
    text = handle_body_task_list1( text )
    text = handle_body_task_list2( text )
    text = handle_body_bold( text )
    text = handle_body_bold_italic( text )
    text = handle_body_strikethrough( text )
    text = handle_body_abstract( text )
    text = handle_body_unordered_list1( text )
    text = handle_body_unordered_list2( text )
    text = handle_body_ordered_list( text )
    text = handle_body_link( text )
    text = handle_body_pic( text )
    text = handle_body_tab( text )
    text = handle_body_bghighlight( text )
    text = handle_body_table( text )

    return text
}


