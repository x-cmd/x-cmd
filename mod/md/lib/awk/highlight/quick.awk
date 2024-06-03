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
    printf("File : %s " "NR =%s FNR =%s\n", "\033[38;5;027m"FILENAME"\033[0m" ,"\033[38;5;027m"" "NR"\033[0m", "\033[38;5;027m"" "FNR"\033[0m")
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


    # 代码片语言分类
    #TODO:只把语言类型进行着色
    if ($0 ~ "^[ ]*{0,}```[^`]*$") {

        match($0,"```[^`]*$")
        mlquote_lang = substr($0,RSTART+3)

       text = text "\n" "```""\033[38;5;147m" mlquote_lang "\033[0m"

       next
    }

    # 一级标题
    if ($0 ~ "^\\s*# [^#]+$") {
        {
        for (i=1;i<=cols;i++) first_title_dividing_line = first_title_dividing_line "—"
        ORS = "\n" "\033[2m" first_title_dividing_line "\033[0m"
         }
        text =  text "\n" "\033[38;5;196m" "\033[1m" $0 "\033[0m" \
        "\n""\033[2m" first_title_dividing_line "\033[0m"

        next
    }

    ## 二级标题 TODO:可选语法re
    if ($0 ~ "^\\s*## [^#]+$") {
        text = text "\n"  "\033[38;5;202m" $0 "\033[0m"
        next
    }

    ### 三级标题
    if ($0 ~ "^\\s*### [^#]+$") {
        text = text  "\n" "\033[38;5;178m" $0 "\033[0m"
        next
    }

    #### 四级标题
    if ($0 ~ "^\\s*#### [^#]+$") {
        text = text "\n"  "\033[38;5;42m" $0 "\033[0m"
        next
    }

    ##### 五级标题
    if ($0 ~ "^\\s*##### [^#]+$") {
        text = text "\n"  "\033[38;5;32m" $0 "\033[0m"
        next
    }

    ###### 六级标题
    if ($0 ~ "^\\s*###### [^#]+$") {
        text = text "\n" "\033[38;5;129m" $0 "\033[0m"
        next
    }

    # 分割线
    if ($0 ~ "(^[(-|*|_)]{3,}[ ]*)$") {
        for (i=1;i<=cols;i++) c=c "-"
        text = text "\n" "\033[2m" c "\033[0m"
        c = ""
        next
    }

    text = text "\n" handle_body( $0 )
    next
}


md_mode==MD_MODE_MLQUOTE{
    # 代码块
    if ($0 ~ "^```\\s*$") {
        text = text "\n" "\033[33m" "\033[1m" "```" "\033[0m"
        md_mode = MD_MODE_NORMAL
        next
    }

    text = text "\n" $0
    next
}

    # 高亮内容显示
    function handle_body_quote( text,     s1, s2, r ){
         while (match(text, "`[^`]+`")) {
            s1 = substr(text, 1, RSTART-1)
            s2 = substr(text, RSTART+1, RLENGTH-2)
            text = substr(text, RSTART+RLENGTH+1)

            r = r s1 "\033[38;5;226m" s2  "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 链接
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

    # 图片
    function handle_body_pic( text,     s1, s2, r,_regex  ){
        _regex = "\\[[^\\]]*\\]\\([^)]+\\)"
        while (match(text, "^" "!"_regex )) {

            s1 = substr(text, 1, RSTART-1)
            s2 = substr(text, RSTART, RLENGTH)
            text = substr(text, RSTART+RLENGTH+1)

            r = r   "\033[38;5;118m" s1  s2 "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 倾斜字体语法1
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

    # 倾斜字体语法2
    function handle_body_tilter( text,     s1, s2, r ){
        while (match(text, "^" "_[^_]+_")) {
            s1 = substr(text, 1, RSTART-1)
            s2 = substr(text, RSTART, RLENGTH)
            text = substr(text, RSTART+RLENGTH+1)

            r = r s1 "\033[38;5;214m" "\033[3m"  s2  "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 加粗字体
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

    # 字体为倾斜加粗
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

    # 文字加下划线
    function handle_body_strikethrough( text,     s1, s2, r ){
        while (match(text, "~~(.*?)~~")) {
            s1 = substr(text, 1, RSTART-1)
            s2 = substr(text, RSTART, RLENGTH)
            text = substr(text, RSTART+RLENGTH+1)

            r = r s1 "\033[38;5;69m" "\033[4m"   s2 "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 引用
    function handle_body_abstract( text,     s1, s2, r ){
        while (match(text, "(&gt;|>).*")) {
            s1 = substr(text, 1, RSTART)
            s2 = substr(text, RSTART+1, RLENGTH-1)
            text = substr(text, RSTART+RLENGTH+1)

            r = r s1 "\033[38;5;27m"  s2 "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 一级无序列表
    function handle_body_unordered_list1( text,      s2, r ){
        while (match(text, "^[ \\s]*[-\\*\\+] +(.*)")) {

            s2 = substr(text, RSTART+2, RLENGTH)
            text = substr(text, RSTART+RLENGTH+1)

            r = r  "\033[38;5;208m" " ● " s2  "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 二级无序列表
    function handle_body_unordered_list2( text,      s2, r ){
        while (match(text, "[-\\*\\+] +(.*)")) {

            s2 = substr(text, RSTART+2, RLENGTH)
            text = substr(text, RSTART+RLENGTH+1)

            r = r  "\033[38;5;208m""  "" ○ "s2  "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 有序列表
    function handle_body_ordered_list( text,     s1, s2, r ){
        while (match(text, "^[.A-Za-z0-9_-]*[0-9]+\\.(.*)")) {
            s1 = substr(text, 1, RSTART)
            s2 = substr(text, RSTART+1, RLENGTH-1)
            text = substr(text, RSTART+RLENGTH+1)

            r = r "\033[38;5;150m" s1 s2 "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 已完成任务列表
    function handle_body_task_list1( text,     s1, r ){

        while (match(text, "^[ ]*(-|\\*) (\\[x]) ")) {
            text = substr(text, RSTART+RLENGTH)
            r =  "[ ✔ ]"          #"✅"
        }
        return ("" == r) ? text : r " " text
    }

    # 未完成任务列表
    function handle_body_task_list2( text,     s1, r ){
        while (match(text, "^[  ]*(-|\\*) (\\[ ]) ")) {
            text = substr(text, RSTART+RLENGTH)
            r = r   "[   ]"        #"❌"
        }
        return ("" == r) ? text : r " " text
    }

    # 背景高亮
    function handle_body_bghighlight( text,     s1, s2, r, _regex ){
        _regex = "==[^=]+=="
        while (match(text, "(^"_regex")|[^=]"_regex)) {
            s1 = substr(text, 1, RSTART-1)
            s2 = substr(text, RSTART, RLENGTH)
            text = substr(text, RSTART+RLENGTH+2)

            r = r s1 "\033[43;5;125m"  s2 "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    # 代码块注释
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

    # TODO:表格
    # \\|(?:([^\r\n\\|]*)\\|)+\r?\n\\|(?:(:?-+:?)\\|)+\r?\n(\\|(?:([^\r\n\\|]*)\\|)+\r?\n)+
    function handle_body_table( text,     s1, s2, r ){
        while (match(text, "\\|[ ]*[^\n]+[ ]?\\|*")) {
            s1 = substr(text, 1, RSTART)
            s2 = substr(text, RSTART+1, RLENGTH-1)

            text = substr(text, RSTART+RLENGTH+1)

            r = r "\033[38;5;150m" s1 s2 "\033[0m"
        }
        return ("" == r) ? text : r text
    }

    function handle_body( text,     s1, s2, r ){
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
        text = handle_body_bghighlight( text )
        text = handle_body_table( text )
        text = handle_body_exegesis( text )

        return text
    }


