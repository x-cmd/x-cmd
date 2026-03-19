function _regex_head( key, n, m){
    return "^[ ]*" re_interval_expression(key, n, m) " [^#]+$"
}

# upper blankline
# background color + bold
# lower blanklike
function hd_head1( arr, line ){
    larr_advance(arr)
    printf(HD_BLANK "%s\n", "\033[1;45m" line "\033[0m")
}

# background color + bold
function hd_head2( arr, line ){
    larr_advance(arr)
    printf(HD_BLANK "%s\n", "\033[1;36m" line "\033[0m")
}

# bold + underline
function hd_head3( arr, line ){
    larr_advance(arr)
    printf(HD_BLANK "%s\n", "\033[1;36m" line "\033[0m")
}

BEGIN{
    true = 1
    false = 0

    ARR_I = "CURRENT"
    ARR_L = 0
    HD_BLANK = "  "
    HD_EXITCODE = 0
    HD_HAS_CONTENT = false
}

function larr_advance( arr, offset ) {
    arr[ ARR_I ] = arr[ ARR_I ] + ( (offset == "") ? 1 : offset )
}

function hd_main( arr,      i, l, line, re_line ){
    l = ARR_L
    if ( l <= 0 ) return
    printf("\n")
    arr[ ARR_I ] = 1
    while (arr[ ARR_I ]<=l) {
        i = arr[ ARR_I ]
        line = arr[i]

        re_line = "^(---[-]*|___[_]*|\\*\\*\\*[\\*]*)[ ]*$"
        if ( line ~ re_line  ) {
            gsub(re_line, "----------", line)
            printf(HD_BLANK "%s\n", "\033[2m" line "\033[0m")
            larr_advance(arr)
            continue
        }

        if ( line ~ _regex_head( "#", 1 ) )    { hd_head1( arr, line ); continue }

        if ( line ~ _regex_head( "#", 2 ) )    { hd_head2( arr, line ); continue }

        if ( line ~ _regex_head( "#", 3, 6 ))  { hd_head3( arr, line ); continue }

        if ( line ~ "^[ ]*```[A-Za-z0-9]+$" ) {
            hd_codeblock( arr )
            continue
        }

        hd_body( arr )
    }

    printf("\n")
}
