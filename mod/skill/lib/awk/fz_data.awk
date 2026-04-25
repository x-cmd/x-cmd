( $0 != "" ){
    ++ arrl
    arr[ arrl, "id" ] = $1
    arr[ arrl, "desc" ] = $2
}
END {
    for ( i = 1; i <= arrl; ++i ) {
        printf "\033[0;33m%s\033[0m\t\033[0;36m%s\033[0m\n", arr[i, "id"], arr[i, "desc"]
    }
}