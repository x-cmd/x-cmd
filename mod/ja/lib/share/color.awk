
BEGIN {
    TH_END          = "\033[0m"

    TH_RED          = "\033[31m"
    TH_GREEN        = "\033[32m"
    TH_YELLOW       = "\033[33m"
    TH_BLUE         = "\033[1;34m"
    TH_KEY          = "\033[32m"

    TH_BOLD         = "\033[1m"
    TH_DIM          = "\033[2m"

    JO_TH_COLON     = ":"
    JO_TH_COMMA     = TH_DIM "," TH_END
    JO_TH_LBOX      = TH_BOLD "[" TH_END
    JO_TH_RBOX      = TH_BOLD "]" TH_END
    JO_TH_LCURLY    = TH_BOLD "{" TH_END
    JO_TH_RCURLY    = TH_BOLD "}" TH_END

    JO_TH_TRUE      = TH_BLUE "true" TH_END
    JO_TH_FALSE     = TH_RED "false" TH_END
    JO_TH_NULL      = TH_DIM "null" TH_END

    JO_TH_LNUMBER   = ""
    JO_TH_RNUMBER   = TH_END

    JO_TH_LSTRING   = TH_YELLOW
    JO_TH_RSTRING   = TH_END
}

function jiter_print_colorize_value( value ){
    if (value == "true")        return JO_TH_TRUE
    if (value == "false")       return JO_TH_FALSE
    if (value == "null")        return JO_TH_NULL
    if (value ~ /^"/)           return JO_TH_LSTRING value JO_TH_RSTRING   #"
    return JO_TH_LNUMBER value JO_TH_RNUMBER
}

function jiter_print_color( obj, item ){
    if (item ~ /^$/)    return
    if (item ~ /^:$/) {
        printf( "%s ",  JO_TH_COLON )
        JITER_LAST_IS_VALUE = 1
    } else if (item ~ /^,$/) {
        printf( "%s\n%s", JO_TH_COMMA, JITER_PRINT_INDENT )
    } else if (item ~ /^[\[\{]$/) { # }
        JITER_LAST_IS_VALUE = 0
        JITER_LEVEL += JITER_LEVEL_STEP
        obj[ JITER_LEVEL ] = JITER_STATE
        obj[ JITER_LEVEL + JITER_LEVEL_INDENT ] = JITER_PRINT_INDENT

        JITER_PRINT_INDENT = JITER_PRINT_INDENT INDENT
        JITER_STATE = item
        if (item == "[")    printf("%s\n%s", JO_TH_LBOX, JITER_PRINT_INDENT)

        else                printf("%s\n%s", JO_TH_LCURLY, JITER_PRINT_INDENT)
    } else if (item ~ /^[\[\{tfn"0-9+-]/)  #"        # (item !~ /^[\{\}\[\]]$/)
    {
        if (JITER_LAST_IS_VALUE == 0) {
            printf( "%s",   TH_KEY item  TH_END)
        } else {
            JITER_LAST_IS_VALUE = 0
            printf( "%s", jiter_print_colorize_value(item) )
        }
    } else {
        JITER_STATE = obj[ JITER_LEVEL ]
        JITER_PRINT_INDENT = obj[ JITER_LEVEL + JITER_LEVEL_INDENT ]
        JITER_LEVEL -= JITER_LEVEL_STEP
        if (item == "]")    printf("\n%s%s", JITER_PRINT_INDENT, JO_TH_RBOX)
        else                printf("\n%s%s", JITER_PRINT_INDENT, JO_TH_RCURLY)
    }
}

BEGIN{
    JITER_LEVEL_STEP = 2
    JITER_LEVEL_INDENT = 1

    if (INDENT == "")  INDENT = "  "
    if ( int(INDENT) > 0 )  INDENT = sprintf("%" int(INDENT) "s", "")
}

{
    jiter_print_color( _, $0 )
}
