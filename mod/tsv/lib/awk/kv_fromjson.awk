
function json_to_machine_friendly(text){
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|:|,|\]|\[|\{|\}|null|false|true|[ \t\n\r]+/, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    gsub("^[\n]+", "", text)
    return text
}

function json_split2tokenarr( arr, text,    l ){
    l = split( json_to_machine_friendly(text), arr, "\n" )
    arr[ L ] = l
    return l
}

function juq( str ){
    str = substr( str, 2, length(str)-2 )
    if (str !~ /\\/) return str

    gsub( /\\\\/, "\001", str )
    gsub( /\\"/, "\"", str )
    gsub( /\\n/, "\n", str )
    gsub( /\\r/, "\r", str )
    gsub( /\\t/, "\t", str )

    if (str ~ /\\/) {
        if (str ~ /\\u/){   # Only for gemini ...
            gsub( /\\u003c/, "<", str )
            gsub( /\\u003e/, ">", str )
            # TODO: in the future: if (str ~ /\\u/) -> transform to binary format. Time consuming ...
        }

        gsub( /\\v/, "\v", str )    # Notice: Will remove in the future, the jq won't recognized
        gsub( /\\b/, "\b", str )
        if (PHP_JSON)   gsub( "\\/", "/", str )                 # Notice: This is for the bwh json.
        # control characters from U+0000 through U+001F must be escaped
    }

    gsub( "\001", "\\", str )
    return str
}

function tsv_esc( v ){
    if (v ~ /[\r\n\t\\]/) {
        # gsub( "\\", "\\\\", v )
        gsub( "\\\\", "&\\", vd )
        gsub( "\r", "\\r",  v )
        gsub( "\n", "\\n",  v )
        gsub( "\t", "\\t",  v )
    }
    return v
}


BEGIN{
    handle_init()
}

# juq , tsv_quote

function handle_init(){
    JITER_LEVEL = 1

    TSV_KV_KEY_SEP = "." # "\t"
    TSV_KV_SEP = "\t\t"

    JITER_FA_KEYPATH = ""

}

function handle( item ){
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/)                                  #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {
            print JITER_FA_KEYPATH TSV_KV_KEY_SEP JITER_LAST_KP TSV_KV_SEP tsv_esc( juq( item ) )
            JITER_LAST_KP = ""
            return
        }
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != "{" ) {
            print JITER_FA_KEYPATH TSV_KV_KEY_SEP JITER_CURLEN TSV_KV_SEP tsv_esc( juq( item ) )
            return
        }
        JITER_LAST_KP = tsv_esc( juq( item ) )
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != "{" ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_LEVEL "L" ] = JITER_CURLEN
            if ( JITER_FA_KEYPATH != "" ) {
                JITER_FA_KEYPATH = JITER_FA_KEYPATH TSV_KV_KEY_SEP JITER_CURLEN
            } else {
                JITER_FA_KEYPATH = JITER_CURLEN
            }
            print JITER_FA_KEYPATH TSV_KV_SEP "\v" item

        } else {
            stack[ JITER_LEVEL "L" ] = JITER_CURLEN
            if ( JITER_FA_KEYPATH != "" ) {
                JITER_FA_KEYPATH = JITER_FA_KEYPATH TSV_KV_KEY_SEP JITER_CURLEN
            } else {
                JITER_FA_KEYPATH = JITER_CURLEN
            }
            print JITER_FA_KEYPATH TSV_KV_SEP "\v" item
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        stack[ ++ JITER_LEVEL ] = JITER_FA_KEYPATH
        stack[ -JITER_LEVEL ] = item
    } else {
        stack[ JITER_LEVEL "L" ] = JITER_CURLEN

        JITER_FA_KEYPATH = stack[ --JITER_LEVEL ]
        JITER_STATE = stack[ -JITER_LEVEL ]
        JITER_CURLEN = stack[ JITER_LEVEL "L" ]
    }
}

{
    l = json_split2tokenarr( arr, $0 )
    for (i=1; i<=l; ++i) {
        handle( arr[i] )
    }
}
