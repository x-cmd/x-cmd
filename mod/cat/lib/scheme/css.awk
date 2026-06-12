BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"
    PROP="\033[1;36m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="@media,@keyframes,@import,@font-face,@charset,@supports,@page,@layer,important"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    PROP_LIST="color,background,background-color,margin,padding,border,display,position,top,left,right,bottom,width,height,font,font-size,font-weight,font-family,text-align,flex,grid,overflow,opacity,transform,transition,animation,box-shadow,border-radius,z-index,justify-content,align-items,flex-direction,gap,max-width,min-width,max-height,min-height,visibility,pointer-events,cursor,outline,content,margin-top,margin-bottom,padding-top,padding-bottom,background-image"
    PROP_REPR = convert_keywordlist_to_keywordrepr( PROP_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # CSS comments /* ... */
    match(text, /\/\*.*\*\//)
    if (RLENGTH > 0) {
        comment = substr(text, RSTART, RLENGTH)
        text = substr(text, 1, RSTART-1) TH_COMMENT comment UI_END substr(text, RSTART + RLENGTH)
    }

    # Property: value (match word before colon)
    match(text, /[a-zA-Z-]+[ \t]*:/)
    if (RLENGTH > 0) {
        p = substr(text, RSTART, RLENGTH)
        gsub(/[a-zA-Z-]+/, PROP "&" UI_END, p )
        text = substr(text, 1, RSTART-1) p substr(text, RSTART + RLENGTH)
    }

    # Selectors: .class, #id, tag
    gsub(/\.[a-zA-Z_-][a-zA-Z0-9_-]*/, SYMBOL "&" UI_END, text)
    gsub(/#[a-zA-Z_-][a-zA-Z0-9_-]*/, BRACKET "&" UI_END, text)

    gsub(PROP_REPR, PROP "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Colors: #hex
    gsub(/#[0-9a-fA-F]{3,8}/, TH_NUMBER "&" UI_END, text)

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
