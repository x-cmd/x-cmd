BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="break,case,chan,const,continue,default,defer,else,fallthrough,for,func,go,goto,if,import,interface,map,package,range,return,select,struct,switch,type,var,true,false,nil,append,cap,close,copy,delete,len,make,new,panic,print,println,recover,fmt,Print,Println,Printf,Sprintf,Errorf"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    SYMBOL_LIST=":=",\\+\\+,\\+=,-=,--,=,==,!=,<-,\\|\\|,&&"
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # Single-line // comment
    match( text, "//[^\"']*$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    # func definition
    match(text, /func[ ]+[a-zA-Z0-9_]+\(/)
    if (RLENGTH > 0) {
        f = substr(text, RSTART, RLENGTH-1)
        gsub(/func/, KEYWORD "&"  UI_END SYMBOL, f )
        text = substr(text, 1, RSTART-1) f "(" UI_END substr(text, RSTART + RLENGTH)
    }

    # type declaration: type Foo struct/interface
    match(text, /type[ ]+[a-zA-Z0-9_]+[ ]/)
    if (RLENGTH > 0) {
        t = substr(text, RSTART, RLENGTH)
        gsub(/type/, KEYWORD "&"  UI_END, t )
        text = substr(text, 1, RSTART-1) t UI_END substr(text, RSTART + RLENGTH)
    }

    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Double-quoted strings (Go has no single-quoted strings for text)
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)

    # Backtick raw strings
    gsub(/`[^`]*`/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
