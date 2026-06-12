BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    TYPE_COLOR="\033[1;36m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="abstract,actual,annotation,as,break,by,catch,class,companion,const,constructor,continue,crossinline,data,do,else,enum,expect,external,false,final,finally,for,fun,get,if,import,in,infix,init,inline,inner,interface,internal,is,it,lateinit,native,object,open,operator,out,override,package,private,protected,public,reified,return,sealed,set,super,suspend,tailrec,this,throw,true,try,typealias,val,var,vararg,when,where,while,yield"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    TYPE_LIST="String,Int,Long,Short,Byte,Float,Double,Boolean,Unit,Nothing,Any,Array,List,Map,Set,MutableList,MutableMap,MutableSet,Pair,Triple,Result,Sequence,Flow,Throwable"
    TYPE_REPR = convert_keywordlist_to_keywordrepr( TYPE_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,\\*=,/=,=,==,!=,->,=>,\\?\\?,\\?\\:,\\.\\.\\."
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

    # Annotations @Annotation
    gsub(/@[a-zA-Z_][a-zA-Z0-9_.]*/, SYMBOL "&" UI_END, text)

    gsub(TYPE_REPR, TYPE_COLOR "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
