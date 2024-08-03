BEGIN{
    IS_XBIN_LIST = 0
    print "candidate_exec_arr+=("
}
(IS_XBIN_LIST == 0) {
    if ( $0 == "\001\002\003") {
        IS_XBIN_LIST = 1
        next
    }

    if ( ___X_CMD_SHELL == "zsh" ) {
        gsub(":.*", "", name)
    } else {
        name = $1
    }
    arr[ name ] = 1
}
(IS_XBIN_LIST == 1) {
    if ((arr[ $1 ] != 1) && (( cur == "" ) || ( $1 ~ "^"cur ))) {
        print comp_advise_str_style($1, "[PKG]:"$2)
    }
}
END{
    print ")"
}
