BEGIN {
    T_LIST = "["
    T_DICT = "{"

    JO_WORDS  = "null|false|true"
    JO_SYMBOL = ":|,|\\]|\\[|\\{|\\}"

    JO_RE_STR0 = "(\\\\[ ])*[^ \t\v\n:,\\[\\]\\}\\{]+"  "((\\\\[ ])[^ \t\v\n:,\\[\\]\\}\\{]*)*"

    JO_TOKEN = re( RE_STR2 ) RE_OR re( RE_STR1 ) RE_OR JO_SYMBOL RE_OR re( JO_RE_STR0 )
    # JO_TOKEN = JO_SYMBOL RE_OR re( RE_STR2 ) RE_OR re( RE_STR1 ) RE_OR re( RE_STR0 )
    JO_TOKEN = JO_TOKEN RE_OR re( RE_NUM ) RE_OR JO_WORDS

    JO_RE_NEWLINE_TRIM_SPACE = "[ \r\n\t\v]+"

    JO_RE_NEWLINE_TRIM = re("\n" JO_RE_NEWLINE_TRIM_SPACE) RE_OR re(JO_RE_NEWLINE_TRIM_SPACE "\n" )
}

function tokenized( text ){
    gsub( JO_TOKEN, "\n&\n", text )
    gsub( JO_RE_NEWLINE_TRIM, "\n", text )
    gsub( "^[ \n]+" RE_OR "[ \n]+$", "", text)
    return text
}

function quote_key( text ){
    if (text ~ /^".*"$/) {
        return text
    }

    if (text ~ /^'.*'$/) {
        text = substr(text, 2, length(text)-2)
        gsub("\\'", "'", text)
        gsub("\"", "\\\"", text)
        return "\"" text "\""
    }

    gsub("\"", "\\\"", text)
    return "\"" text "\""
}

function quote_value( text ){
    if (text ~ /^(\{|\[|true|false|null)$/)     return text
    if (text ~ "^" RE_NUM "$")                  return text
    return quote_key(text)
}

function jinormal_printkv( item ) {
    if ( JITER_LAST_KP != "" ) {
        # print "JITER_CURLEN:" JITER_CURLEN
        if (JITER_CURLEN > 1)  print ","
        print quote_key(JITER_LAST_KP) "\n:\n" quote_value(item)
        JITER_LAST_KP = ""
    } else {
        JITER_CURLEN = JITER_CURLEN + 1
        if (JITER_STATE != T_DICT) {
            if (JITER_CURLEN > 1)  print ","
            print quote_value(item)
        } else {
            JITER_LAST_KP = item
        }
    }
}

BEGIN{
    JITER_LEVEL = 0
    JITER_LEVEL_STEP = 2
    JITER_LEVEL_STATE = 1
}

function jinormal( obj, item ){
    if (item == "") return
    if (item ~ /^[,:]?$/) return
    if (item ~ /^[\[\{]$/) {
        jinormal_printkv( item )
        JITER_CURLEN = JITER_CURLEN + 1
        obj[ JITER_LEVEL ] = JITER_CURLEN
        obj[ JITER_LEVEL + JITER_LEVEL_STATE ] = JITER_STATE
        JITER_LEVEL += JITER_LEVEL_STEP
        JITER_STATE = item
        JITER_CURLEN = 0
    } else if (item ~ /^[]}]$/) {
        print item
        JITER_LEVEL -= JITER_LEVEL_STEP
        JITER_CURLEN = obj[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_LEVEL + JITER_LEVEL_STATE ]
    } else {
        jinormal_printkv( item )
    }
}

function jiter_tokenized_normalized( text,      _arr, _arrl, i ){
    _arrl = split(tokenized( text ), _arr, "\n")
    for (i=1; i<=_arrl; ++i) {
        jinormal( _, _arr[ i ])
    }
}

BEGIN {
    if (ARGV[1] !="")  print jiter_tokenized_normalized(ARGV[1])
}

{
    jiter_tokenized_normalized( $0 )
    fflush()
}
