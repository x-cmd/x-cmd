BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"
    DECORATOR="\033[1;33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="and,as,assert,async,await,break,class,continue,def,del,elif,else,except,finally,for,from,global,if,import,in,is,lambda,nonlocal,not,or,pass,raise,return,try,while,with,yield,True,False,None"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    BUILTIN_LIST="print,range,len,int,str,float,list,dict,set,tuple,type,isinstance,enumerate,zip,map,filter,sorted,reversed,open,super,input,abs,any,all,bin,chr,dir,format,getattr,hasattr,hex,id,iter,max,min,next,oct,ord,pow,repr,round,sum,vars,breakpoint"
    BUILTIN_REPR = convert_keywordlist_to_keywordrepr( BUILTIN_LIST )

    SYMBOL_LIST="\\+=,-=,\\*=,//=,/=,=,==,!=,\\*\\*,->"
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # Python # comment
    match( text, "#[^\"']*$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    # Decorators
    gsub(/@[a-zA-Z_][a-zA-Z0-9_.]*/, DECORATOR "&" UI_END, text)

    # def/class name
    match(text, /(def|class)[ ]+[a-zA-Z0-9_]+/)
    if (RLENGTH > 0) {
        f = substr(text, RSTART, RLENGTH)
        gsub(/(def|class)/, KEYWORD "&"  UI_END SYMBOL, f )
        text = substr(text, 1, RSTART-1) f UI_END substr(text, RSTART + RLENGTH)
    }

    gsub(BUILTIN_REPR, SYMBOL "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # f-strings and regular strings
    gsub(/f\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/f'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
