BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="print,BEGIN,END,return,split,RLENGTH,gsub,if,for,else,then,case,in,esac"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,--,="
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
    # print SYMBOL_REPR
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){

    match( text, "#[^$]+$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)
    # gsub("(+|-)[0-9]+(\.[0-9]+)?", NUMBER "&" UI_END, text)

    match(text, /function[ ]+[a-zA-Z0-9_]+\(/)
    if (RLENGTH > 0) {
        f = substr(text, RSTART, RLENGTH-1)
        gsub(/function/, KEYWORD "&"  UI_END SYMBOL, f )
        text = substr(text, 1, RSTART-1) f "(" UI_END substr(text, RSTART + RLENGTH)
    }

    # gsub(SYMBOL_REPR, SYMBOL "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # gsub(/(^|\s+|[^\033])\[/, BRACKET "&" UI_END, text)
    # gsub(/\{|\}|\]|\(|\)/, BRACKET "&" UI_END, text)

    gsub(/\"([^"]|\\")+\"/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
