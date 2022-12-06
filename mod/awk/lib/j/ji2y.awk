# json iterator conversion to yml

function ji2y_init( indent ){
    JITER_STATE = ""
    JITER_LAST_KP = ""
    JITER_FA_KEYPATH = ""
    JITER_LEVEL = 0
    JITER_LEN = 0
    JITER_INDENT = (indent == "") ? "  " : indent
    JITER_INDENT_CUR = ""
}

BEGIN {
    ji2y_init( "  " )
}

function printstack( stack,     i ){
    for (i=1; i<=JITER_LEVEL; ++i) print "--->>> " i "\t" stack[ i SUBSEP ]
}

function ji2y( item, indent, stack,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ "^[tfn\"0-9+-]") {
        if ( JITER_LAST_KP != "" ) {
            _res = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
            print item
            # TODO: If comment exists, add here
            return
        }
        if ( JITER_STATE != "{" ) {
            JITER_LEN ++
            # TODO: If comment exists, add here
            if (( JITER_LEN <= 1 ) && ( stack[ JITER_LEVEL SUBSEP ] == "[" )) {
                print "- " item
            } else {
                print JITER_INDENT_CUR "- " item
            }
            return
        }

        JITER_LEN ++
        JITER_LAST_KP = item
        # TODO: If comment exists, add here
        if (( JITER_LEN <= 1 ) && ( stack[ JITER_LEVEL SUBSEP ] == "[" )) {
            printf( "%s", j2y_better_key(item) ": " )
        } else {
            printf( "%s", JITER_INDENT_CUR j2y_better_key(item) ": " )
        }
        # return JITER_FA_KEYPATH S JITER_CURLEN
    } else if (item ~ "^[\\[\\{]$") {
        if ( JITER_STATE != "{" ) {
            if (JITER_STATE == "") {
                if (JITER_LEVEL == "") print "---"
            } else {
                printf("%s", JITER_INDENT_CUR "- " )
            }
        } else {
            print ""
            JITER_LAST_KP = ""
        }

        JITER_LEVEL = JITER_LEVEL + 1
        stack[ JITER_LEVEL SUBSEP SUBSEP ] = ++ JITER_LEN
        stack[ JITER_LEVEL SUBSEP ] = JITER_STATE
        stack[ JITER_LEVEL ] = JITER_INDENT_CUR

        JITER_LEN = 0
        JITER_STATE = item
        if (JITER_LEVEL > 1) JITER_INDENT_CUR = JITER_INDENT_CUR JITER_INDENT
        return
    } else {
        JITER_LEN = stack[ JITER_LEVEL SUBSEP SUBSEP ]
        JITER_STATE = stack[ JITER_LEVEL SUBSEP ]
        JITER_INDENT_CUR = stack[ JITER_LEVEL ]
        JITER_LEVEL = JITER_LEVEL - 1
    }
    return ""
}
