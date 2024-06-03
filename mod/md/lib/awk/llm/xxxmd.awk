function _regex_head( key ){
    return "^[ ]*" key " [^#]+$"
}

# upper blankline
# background color + bold
# lower blanklike
function hd_head1( line ){
    larr_advance()
    printf(HD_BLANK "%s\n", "\033[1;45m" line "\033[0m")
}

# background color + bold
function hd_head2( line ){
    larr_advance()
    printf(HD_BLANK "%s\n", "\033[1;36m" line "\033[0m")
}

# bold + underline
function hd_head3( line ){
    larr_advance()
    printf(HD_BLANK "%s\n", "\033[1;36m" line "\033[0m")
}

# draw the table with some help in csv ...
function hd_table(){

}

# draw the body ...

function hd_body_line(){

}

BEGIN{
    true = 1
    false = 0

    ARR_I = "CURRENT"
    ARR_L = "LENGTH"
    HD_BLANK = "  "
}

function larr_advance( offset ) {
    arr[ ARR_I ] = arr[ ARR_I ] + ( (offset == "") ? 1 : offset )
}

function hd_main( arr,      i, l, line ){
    l = ARR_L
    arr[ ARR_I ] = 0
    while (arr[ ARR_I ]<=l) {
        i = arr[ ARR_I ]
        line = arr[i]
        if ( line ~ "^[-|*|_]{3,}[ ]*$" ) {
            gsub("^[-|*|_]{3,}[ ]*$", "----------", line)
            printf(HD_BLANK "%s\n", "\033[2m" line "\033[0m")
            larr_advance()
            continue
        }

        if ( line ~ _regex_head( "#" ) )     { hd_head1( line ); continue }

        if ( line ~ _regex_head( "##" ) )    { hd_head2( line ); continue }

        if ( line ~ _regex_head( "#{3,6}" )) { hd_head3( line ); continue }

        if ( line ~ "^[ ]*```[A-Za-z0-9]+$" ) {
            hd_codeblock( arr )
            continue
        }

        # handle table, this is the most difficult
        # if ( line ~ "^```|(|)|$" ) {

        # }

        hd_body( arr )
    }

}

{
    arr[ ARR_L ++ ] = $0
}

END{
    printf("\n")
    hd_main( arr )
}