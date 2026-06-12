BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="if,then,else,elif,fi,case,esac,for,while,until,do,done,in,function,select,time,return,exit,break,continue,local,declare,export,readonly,typeset,unset,shift,eval,trap,source,alias,true,false,test"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    BUILTIN_LIST="echo,printf,read,cd,pushd,popd,pwd,ls,cat,grep,sed,awk,find,mkdir,rm,cp,mv,chmod,chown,head,tail,sort,uniq,wc,cut,tr,xargs,tee,date,sleep,wait,kill,jobs,bg,fg,nohup"
    BUILTIN_REPR = convert_keywordlist_to_keywordrepr( BUILTIN_LIST )

    SYMBOL_LIST="\\+=,-=,=,==,!=,&&,\\|\\|,;;"
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # Shell # comment
    match( text, "#[^\"']*$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    # Variable expansions ${...} and $var
    gsub(/\$\{[^}]+\}/, SYMBOL "&" UI_END, text)
    gsub(/\$[a-zA-Z_][a-zA-Z0-9_]*/, SYMBOL "&" UI_END, text)
    gsub(/\$\([^)]+\)/, SYMBOL "&" UI_END, text)

    gsub(BUILTIN_REPR, BRACKET "&" UI_END, text)
    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'[^']*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
