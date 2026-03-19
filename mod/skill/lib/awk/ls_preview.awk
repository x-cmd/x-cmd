( $0 != "" ){
    l_id = length($1)
    if ( max_id < l_id ) max_id = l_id

    ++ arrl
    arr[ arrl, "id" ] = $1

    if ( match($2, "^" HOMEDIR "/" )) {
        $2 = "~/" substr( $2, RLENGTH + 1 )
    }
    l_dir = length($2)
    if ( max_dir < l_dir ) max_dir = l_dir
    if ( match($2, "(claude|codex|gemini)") ) {
        $2 = substr($2, 1, RSTART-1) "\033[1m" substr($2, RSTART, RLENGTH) "\033[0;35m" substr($2, RSTART + RLENGTH)
    }
    arr[ arrl, "dir" ] = $2

    $1 = $2 = ""
    arr[ arrl, "desc" ] = $0
}
END {
    max_id += 1
    max_dir += 1
    if ( max_id < 10 ) max_id = 10
    if ( max_dir < 10 ) max_dir = 10

    if ( HAS_HEADER ) {
        printf("%-" max_id "s%-" max_dir "s%s\n", "skill-id", "skill-dir", "description")
    }

    for ( i = 1; i <= arrl; ++ i ) {
        printf("\033[0;33m%-" max_id "s\033[0;35m%-" max_dir "s\033[0;36m%s\033[0m\n", arr[i, "id"], arr[i, "dir"], arr[i, "desc"])
    }
}
