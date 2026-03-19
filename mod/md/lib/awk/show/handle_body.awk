
function md_handle_body( line, output_arr ){
    line = md_body_transform_quote(line)
    line = md_body_transform_italic(line)
    line = md_body_transform_bold(line)
    line = md_body_transform_bold_italic(line)
    line = md_body_transform_strikethrough(line)
    line = md_body_transform_url_email(line)
    line = md_body_transform_link(line)
    line = md_body_transform_pic(line)
    line = md_body_transform_abstract(line)
    line = md_body_transform_task_list_done(line)
    line = md_body_transform_task_list_undone(line)

    return md_output( md_body_transpose(line), output_arr )
}

function md_body_transpose( line ){
    # handle the data
    gsub("&nbsp;",      " ",    line)
    gsub("&lt;",        "<",    line)
    gsub("&gt;",        ">",    line)
    gsub("&amp;",       "\\&",  line)
    gsub("&quot;",      "\"",   line)
    gsub("&apos;",      "'",    line)
    gsub("&cent;",      "￠",   line)
    gsub("&pound;",     "£",    line)
    gsub("&yen;",       "¥",    line)
    gsub("&euro;",      "€",    line)
    gsub("&sect;",      "§",    line)
    gsub("&copy;",      "©",    line)
    gsub("&reg;",       "®",    line)
    gsub("&times;",     "×",    line)
    gsub("&divide;",    "÷",    line)
    gsub("&trade;",     "™",    line)
    gsub("&ldquo;",     "“",    line)
    gsub("&rdquo;",     "”",    line)
    gsub("&lsquo;",     "‘",    line)
    gsub("&rsquo;",     "’",    line)
    gsub("&ndash;",     "–",    line)
    gsub("&mdash;",     "—",    line)
    return line
}

# 倾斜字体
function md_body_transform_italic( text,     s1, s2, r, _regex1, _regex2 ){
    _regex = "(\\*[^ *]\\*[^*]+|_[^_]+_[^_]+)"
    while (match(text, _regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        gsub(STR_TERMINAL_ESCAPE033_LIST, "", s2)
        text = substr(text, RSTART+RLENGTH)
        r = r s1 HD_STYLE_ITALIC UI_TEXT_ITALIC s2 HD_STYLE_END
    }
    return ("" == r) ? text : r text
}

# 加粗字体
function md_body_transform_bold( text,     s1, s2, r, l, i, line, _style, _regex, style_enable ){
    _style = HD_STYLE_STRONG UI_TEXT_BOLD
    _regex = "(\\*\\*[^*]+\\*\\*|__[^_]+__[^_]+)"
    # _regex1 = "\\*("STR_TERMINAL_ESCAPE033_LIST")?\\*([^ *][^*]*[^ *]|[^ *])\\*("STR_TERMINAL_ESCAPE033_LIST")?\\*"
    # _regex2 = "(^| )_("STR_TERMINAL_ESCAPE033_LIST")?_([^ ].*[^ ]|[^ ])_("STR_TERMINAL_ESCAPE033_LIST")?_( |$)"
    while (match(text, _regex)) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        if ( s2 ~ STR_TERMINAL_ESCAPE033_LIST ) {
            gsub( STR_TERMINAL_ESCAPE033_LIST,  "\n&\n",  s2 )
            l = split( s2, arr, "\n" )
            for (i=1; i<=l; ++i) {
                if (arr[i] ~ "\033\\[0m" ) {
                    style_enable = 0
                    line = line arr[i]
                    continue
                }else if (arr[i] ~ STR_TERMINAL_ESCAPE033_LIST ) {
                    style_enable = 1
                    line = line arr[i]
                } else {
                    line = (style_enable == 1) ? line arr[i] : line _style arr[i] HD_STYLE_END
                }
            }
        } else {
            line = _style s2 HD_STYLE_END
        }

        r = r s1 line
        text = substr( text, RSTART+RLENGTH )
    }
    return ("" == r) ? text : r text
}

# 倾斜加粗字体
function md_body_transform_bold_italic( text,     s1, s2, r, _regex1, _regex2 ){
    _regex1 = "\\*("STR_TERMINAL_ESCAPE033_LIST")?\\*\\*([^ *][^*]*[^ *]|[^ *])\\*\\*("STR_TERMINAL_ESCAPE033_LIST")?\\*"
    _regex2 = "(^| )_("STR_TERMINAL_ESCAPE033_LIST")?__([^ ].*[^ ]|[^ ])__("STR_TERMINAL_ESCAPE033_LIST")?_( |$)"
    while (match(text, "("_regex1 "|" _regex2 ")")) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        gsub(STR_TERMINAL_ESCAPE033_LIST, "", s2)
        text = substr(text, RSTART+RLENGTH)
        r = r s1 HD_STYLE_ITALIC2 UI_TEXT_ITALIC UI_TEXT_BOLD  s2  HD_STYLE_END
    }
    return ("" == r) ? text : r text
}

# 文字删除
function md_body_transform_strikethrough( text,     s1, s2, r ){
    while (match(text, "~~(.*?)~~")) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH)
        r = r s1 HD_STYLE_DELETE   s2 HD_STYLE_END
    }
    return ("" == r) ? text : r text
}

# 高亮内容显示，单行代码命令
function md_body_transform_quote( text,     s1, s2){
    while (match(text, "`[^`]+`")) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART+1, RLENGTH-2)
        gsub(STR_TERMINAL_ESCAPE033_LIST, "", s2)
        text = s1 HD_STYLE_CODE " " s2 " "  HD_STYLE_END substr(text, RSTART+RLENGTH)
    }
    return text
}

# URLs and Email 链接地址
function md_body_transform_url_email( text,     s1, s2, r ){
    while (match(text, "((^| )" RE_URL_HTTP "|(^| )" RE_URL_HTTPS "|(^| )" RE_EMAIL ")" )) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART+1, RLENGTH-1)
        text = substr(text, RSTART+RLENGTH)
        r = r s1 HD_STYLE_LINK  s2  HD_STYLE_END
    }
    return ("" == r) ? text : r text
}

# 链接
function md_body_transform_link( text,     s1, s2, r ,_regex ){
    _regex = "\\[[^\\]]*\\]\\([^)]+\\)"
    while (match(text, "([^!]|^)"_regex )) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH)
        gsub(STR_TERMINAL_ESCAPE033_LIST, "", s2)
        r = r s1 HD_STYLE_LINK  s2  HD_STYLE_END
    }
    return ("" == r) ? text : r text
}

# 图片
function md_body_transform_pic( text,     s1, s2, r,_regex  ){
    _regex = "\\[[^\\]]*\\]\\([^)]+\\)"
    while (match(text, "!"_regex )) {
        s1 = substr(text, 1, RSTART-1)
        s2 = substr(text, RSTART, RLENGTH)
        text = substr(text, RSTART+RLENGTH)
        gsub(STR_TERMINAL_ESCAPE033_LIST, "", s2)
        r = r s1 HD_STYLE_IMAGE s2 HD_STYLE_END
    }
    return ("" == r) ? text : r text
}

# 引用
function md_body_transform_abstract( text,     s, r ){
    while (match(text, "^[ ]*(>[ ]?)+")) {
        s = substr(text, 1, RLENGTH)
        gsub(">[ ]*", "│ ", s)
        text = s substr(text, RLENGTH+1)
    }
    return text
}

# 已完成任务列表
function md_body_transform_task_list_done( text,     s1, r ){

    while (match(text, "^[ ]*[•*+\\-] (\\[x]) ")) {
        text = substr(text, RSTART+RLENGTH)
        r =  "[ \033[38;5;34m✓\033[0m ]"          #"✅"
    }
    return ("" == r) ? text : r " " text
}

# 未完成任务列表
function md_body_transform_task_list_undone( text,     s1, r ){
    while (match(text, "^[  ]*[•*+\\-] (\\[ ]) ")) {
        text = substr(text, RSTART+RLENGTH)
        r = r   "[   ]"        #"❌"
    }
    return ("" == r) ? text : r " " text
}

