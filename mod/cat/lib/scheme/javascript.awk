BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="break,case,catch,class,const,continue,debugger,default,delete,do,else,export,extends,finally,for,function,if,import,in,instanceof,let,new,of,return,static,super,switch,this,throw,try,typeof,var,void,while,with,yield,async,await,true,false,null,undefined,NaN,Infinity,console,log,require,module"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,--,=,==,===,!=,!==,&&,\\|\\|,=>,\\.\\.\\."
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

    # function/const/let/class name
    match(text, /(function|const|let|var|class)[ ]+[a-zA-Z0-9_]+/)
    if (RLENGTH > 0) {
        f = substr(text, RSTART, RLENGTH)
        gsub(/(function|const|let|var|class)/, KEYWORD "&"  UI_END SYMBOL, f )
        text = substr(text, 1, RSTART-1) f UI_END substr(text, RSTART + RLENGTH)
    }

    # Arrow function: name =>
    match(text, /[a-zA-Z_][a-zA-Z0-9_]*[ ]*=>/)
    if (RLENGTH > 0) {
        a = substr(text, RSTART, RLENGTH)
        gsub(/=>/, SYMBOL "&" UI_END, a )
        text = substr(text, 1, RSTART-1) a substr(text, RSTART + RLENGTH)
    }

    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Template literals
    gsub(/`[^`]*`/, KEYWORD "&" UI_END, text)

    # Strings (double and single quoted)
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
