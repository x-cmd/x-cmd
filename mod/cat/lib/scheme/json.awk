BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="true,false,null"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text ){
    # JSON keys (quoted strings before colon)
    match(text, /^[ \t]*\"([^"\\]|\\.)*\"[ \t]*:/)
    if (RLENGTH > 0) {
        key = substr(text, 1, RLENGTH)
        gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, key )
        text = key UI_END substr(text, RLENGTH + 1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Remaining strings (values)
    gsub(/\"([^"\\]|\\.)*\"/, SYMBOL "&" UI_END, text)

    return text
}

{
    print colorize( $0 )
}
