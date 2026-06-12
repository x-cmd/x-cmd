BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    TYPE_COLOR="\033[1;36m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="break,case,catch,class,const,continue,debugger,default,delete,do,else,enum,export,extends,finally,for,function,if,implements,import,in,instanceof,interface,let,new,of,package,private,protected,public,return,static,super,switch,this,throw,try,typeof,var,void,while,with,yield,async,await,as,from,is,keyof,readonly,type,declare,module,namespace,abstract,true,false,null,undefined,never,unknown,any,void,string,number,boolean,object,symbol,bigint"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,--,=,==,===,!=,!==,&&,\\|\\|,=>,\\?:,\\.\\.\\."
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

    # Type annotations: : TypeName
    match(text, /:[ ]*[A-Z][A-Za-z0-9_]*(<[^>]*>)?/)
    if (RLENGTH > 0) {
        t = substr(text, RSTART, RLENGTH)
        gsub(/[A-Z][A-Za-z0-9_]*/, TYPE_COLOR "&" UI_END, t )
        text = substr(text, 1, RSTART-1) t substr(text, RSTART + RLENGTH)
    }

    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Template literals
    gsub(/`[^`]*`/, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
