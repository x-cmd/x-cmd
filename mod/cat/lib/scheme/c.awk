BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    TYPE_COLOR="\033[1;36m"
    SYMBOL="\033[33m"
    PREPROC="\033[1;35m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="auto,break,case,char,const,continue,default,do,double,else,enum,extern,float,for,goto,if,int,long,register,return,short,signed,sizeof,static,struct,switch,typedef,union,unsigned,void,volatile,while"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    TYPE_LIST="uint8_t,uint16_t,uint32_t,uint64_t,int8_t,int16_t,int32_t,int64_t,size_t,ssize_t,ptrdiff_t,bool,NULL,FILE,stdin,stdout,stderr"
    TYPE_REPR = convert_keywordlist_to_keywordrepr( TYPE_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,\\*=,/=,=,==,!=,->,&&,\\|\\|,\\.\\.\\."
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # // comment
    match( text, "//[^\"']*$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    # Preprocessor directives
    match(text, /^[ \t]*#[ \t]*(include|define|ifdef|ifndef|endif|if|else|elif|undef|pragma|error|warning)/)
    if (RLENGTH > 0) {
        _comment = PREPROC substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(TYPE_REPR, TYPE_COLOR "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)+'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
