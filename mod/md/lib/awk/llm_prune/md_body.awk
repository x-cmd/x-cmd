BEGIN{
    HD_STYLE_STRONG_0 = "\033[1;36m"
    HD_STYLE_STRONG_1 = "\033[0m"

    HD_STYLE_ITALIC_0 = "\033[3m"
    HD_STYLE_ITALIC_1 = "\033[0m"

    HD_STYLE_QUOTE_0 = "\033[38;5;210m"
    HD_STYLE_QUOTE_1 = "\033[0m"

    HD_STYLE_NUMBER_0 = "\033[35m"
    HD_STYLE_NUMBER_1 = "\033[0m"

    HD_STYLE_UNDERLINE_0 = "\033[4;36m"
    HD_STYLE_UNDERLINE_1 = "\033[0m"

    HD_STYLE_BRACKET_0 = "\033[33m"
    HD_STYLE_BRACKET_1 = "\033[0m"

}

function hd_body( arr,                  pattern, _line, i, a, l ){
    _line = arr[ arr[ ARR_I ] ]


    if ( _line ~ "^[ ]*[0-9]+\\.[ ]+") {
        gsub("[0-9]+",  HD_STYLE_NUMBER_0 "&"   HD_STYLE_NUMBER_1, _line)
    }

    _line = HD_BLANK "  " _line

    # TODO: do something with 1. *. -
    pattern = "(`[^`]+`)"
    pattern = pattern "|" "(\\*\\*[^*]+\\*\\*)"
    pattern = pattern "|" "(\\*[^ *]+\\*)"

    gsub( pattern,  "\n&\n",  _line )
    l = split( _line, a, "\n" )

    for (i=1; i<=l; ++i) {
        if (a[i] ~ "^\\*\\*[^*]+") {
            printf( "%s",  HD_STYLE_STRONG_0 substr( a[i], 1 ) HD_STYLE_STRONG_1 )
        } else if (a[i] ~ "^`") {
            printf( "%s", HD_STYLE_QUOTE_0 substr( a[i], 1 ) HD_STYLE_QUOTE_1)
            # TODO: list starting with *
        } else if (a[i] ~ "^\\*[^ *]+") {
            printf( "%s", HD_STYLE_ITALIC_0 substr( a[i], 1 ) HD_STYLE_ITALIC_1)
        } else {
            # if ( i > 1) HD_BLANK=""
            printf( "%s", hd_body_colorize( a[i] ))

        }
    }

    printf("\n")
    # HD_BLANK="  "
    larr_advance(arr)
}

function hd_body_colorize( str ){
    gsub("[ ]+[0-9]+[ ]+", HD_STYLE_NUMBER_0 "&" HD_STYLE_NUMBER_1, str)
    if ( str ~ "\\[[^\\]]*\\]\\([^)]+\\)")  return hd_body_link( str )
    return str
}

function hd_body_link( str,     pattern, a, s1, s2, l, text ){
    pattern="\\[[^\\]\\[]*\\]\\([^)]+\\)"
    gsub( pattern,  "\n&\n",  str )
    l = split( str, a, "\n" )
    text = ""
    for (i=1; i<=l; ++i) {
        if ( match( a[i], "\\[[^\\]]*\\]") ) {
            s1 = substr(a[i], RSTART+1, RLENGTH-2)
            text = text HD_STYLE_NUMBER_0 s1 HD_STYLE_NUMBER_1
        }
        if (match( a[i], "\\([^)]+\\)") ) {
            s2 = substr(a[i], RSTART+1, RLENGTH-2)
            if ( s1 == s2 )  continue
            text = text " " HD_STYLE_UNDERLINE_0 s2 HD_STYLE_UNDERLINE_1
        } else {
            text = (text == "") ? a[i] : text a[i]
        }
    }
    return text
}


# keywords
# 1.
# * ->
