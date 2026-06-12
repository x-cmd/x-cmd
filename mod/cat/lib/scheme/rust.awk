BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    TYPE_COLOR="\033[1;36m"
    SYMBOL="\033[33m"
    MACRO="\033[1;35m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="as,async,await,break,const,continue,crate,dyn,else,enum,extern,fn,for,if,impl,in,let,loop,match,mod,move,mutable,mut,pub,ref,return,self,Self,static,struct,super,trait,type,unsafe,use,where,while,true,false"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    TYPE_LIST="i8,i16,i32,i64,i128,isize,u8,u16,u32,u64,u128,usize,f32,f64,bool,char,str,String,Vec,Option,Result,Box,Rc,Arc,HashMap,HashSet,BTreeMap,BTreeSet"
    TYPE_REPR = convert_keywordlist_to_keywordrepr( TYPE_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,\\*=,/=,=,==,!=,->,=>,\\.\\.\\.,\\|\\|,&&"
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

    # Macros like println!, vec!, macro_rules!
    gsub(/[a-zA-Z_][a-zA-Z0-9_]*!/, MACRO "&" UI_END, text)

    # fn definition
    match(text, /fn[ ]+[a-zA-Z0-9_]+/)
    if (RLENGTH > 0) {
        f = substr(text, RSTART, RLENGTH)
        gsub(/fn/, KEYWORD "&"  UI_END SYMBOL, f )
        text = substr(text, 1, RSTART-1) f UI_END substr(text, RSTART + RLENGTH)
    }

    gsub(TYPE_REPR, TYPE_COLOR "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)

    # Lifetime annotations 'a
    gsub(/'[a-zA-Z_][a-zA-Z0-9_]*/, SYMBOL "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
