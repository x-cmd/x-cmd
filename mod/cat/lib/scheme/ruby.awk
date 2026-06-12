BEGIN{
    BRACKET="\033[35m"
    TH_NUMBER="\033[32m"
    KEYWORD="\033[1;34m"
    SYMBOL="\033[33m"

    TH_COMMENT = "\033[32;2m"
    UI_END="\033[0m"

    KEYWORD_LIST="alias,and,BEGIN,begin,break,case,class,def,defined?,do,else,elsif,END,end,ensure,false,for,if,in,module,next,nil,not,or,redo,rescue,retry,return,self,super,then,true,undef,unless,until,when,while,yield,require,require_relative,include,extend,attr_reader,attr_writer,attr_accessor,raise"
    KEYWORD_REPR = convert_keywordlist_to_keywordrepr( KEYWORD_LIST )

    SYMBOL_LIST="\\+\\+,\\+=,-=,\\*=,/=,=,==,!=,=>,->,\\|\\|,&&,<<,>>"
    SYMBOL_REPR = convert_keywordlist_to_keywordrepr( SYMBOL_LIST )
}

function convert_keywordlist_to_keywordrepr(list, KEYWORD_REPR){
    arrl = split(list, arr, ",")
    for (i=1; i<=arrl; ++i)     KEYWORD_REPR = KEYWORD_REPR "|(" arr[i] ")"
    KEYWORD_REPR = substr( KEYWORD_REPR, 2 )
    return KEYWORD_REPR
}

function colorize( text, _comment ){
    # Ruby # comment
    match( text, "#[^\"']*$")
    if (RLENGTH > 0) {
        _comment = TH_COMMENT substr(text, RSTART) UI_END
        text = substr(text, 1, RSTART-1)
    }

    gsub(/[0-9]+/, TH_NUMBER "&" UI_END, text)

    # Instance variables @var and @@class_var
    gsub(/@@[a-zA-Z_][a-zA-Z0-9_]*/, SYMBOL "&" UI_END, text)
    gsub(/@[a-zA-Z_][a-zA-Z0-9_]*/, SYMBOL "&" UI_END, text)

    # Symbols :name
    gsub(/:[a-zA-Z_][a-zA-Z0-9_?]*/, BRACKET "&" UI_END, text)

    # def/class/module name
    match(text, /(def|class|module)[ ]+[a-zA-Z0-9_:]+/)
    if (RLENGTH > 0) {
        f = substr(text, RSTART, RLENGTH)
        gsub(/(def|class|module)/, KEYWORD "&"  UI_END SYMBOL, f )
        text = substr(text, 1, RSTART-1) f UI_END substr(text, RSTART + RLENGTH)
    }

    gsub(KEYWORD_REPR, KEYWORD "&" UI_END, text)

    # Strings
    gsub(/\"([^"\\]|\\.)*\"/, KEYWORD "&" UI_END, text)
    gsub(/'([^'\\]|\\.)*'/, KEYWORD "&" UI_END, text)

    return text _comment
}

{
    print colorize( $0 )
}
