BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"
    ATTR="\033[1;36m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"
}

function colorize( text ){
    # XML/HTML comments <!-- ... -->
    match(text, /<!--.*-->/)
    if (RLENGTH > 0) {
        comment = substr(text, RSTART, RLENGTH)
        text = substr(text, 1, RSTART-1) TH_COMMENT comment UI_END substr(text, RSTART + RLENGTH)
    }

    # Tags <tagname and </tagname>
    gsub(/<\/?[a-zA-Z][a-zA-Z0-9_-]*/, KEYWORD "&" UI_END, text)

    # Attributes name="value"
    gsub(/[a-zA-Z_-]+=[ \t]*"[^"]*"/, ATTR "&" UI_END, text)
    gsub(/[a-zA-Z_-]+=[ \t]*'[^']*'/, ATTR "&" UI_END, text)

    # Attribute values
    gsub(/\"[^"]*\"/, SYMBOL "&" UI_END, text)
    gsub(/'[^']*'/, SYMBOL "&" UI_END, text)

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    return text
}

{
    print colorize( $0 )
}
