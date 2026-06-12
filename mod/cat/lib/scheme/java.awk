BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    TYPE_COLOR="\033[1;36m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="abstract,assert,break,case,catch,class,const,continue,default,do,else,enum,extends,final,finally,for,if,implements,import,instanceof,interface,native,new,package,private,protected,public,return,static,strictfp,super,switch,synchronized,this,throw,throws,transient,try,void,volatile,while,true,false,null"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    TYPE_LIST="String,Integer,Int,Long,Boolean,Double,Float,List,Map,Set,ArrayList,HashMap,HashSet,Optional,Stream,Exception,System,Object,Thread,Override,Deprecated"
    TYPE_REPR = convert_keywordlist_to_keywordrepr( TYPE_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,--,=,==,!=,&&,\\|\\|,->"
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

    # Annotations like @Override
    gsub(/@[A-Za-z_][A-Za-z0-9_]*/, SYMBOL "&" UI_END, text)

    gsub(TYPE_REPR, TYPE_COLOR "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Double-quoted strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)

    # Char literals
    gsub(/'[^']+'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
