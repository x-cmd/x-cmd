BEGIN{
    colr_ok1 = "\033[32m"
    colr_ok2 = "\033[36;1m"

    colr_ban = "\033[31;2m"
    colr_ban2 = "\033[0m\033[34m"

    colr_ok_pat     = colr_ok1     "%20s" "\t"  colr_ok2  "%s" "\033[0m\n"
    colr_ban_pat    = colr_ban     "%20s" "\t"  colr_ban2 "%s" "\033[0m\n"

    exit_code = 0
}

{
    if ((limit != 0) && (NR > limit)) {
        exit_code = 1
        exit
    }

    if ($1 != "0.0.0.0")    printf(colr_ok_pat,     $1, $2 )
    else                    printf(colr_ban_pat,    $1, $2 )
}

END{
    exit(exit_code)
}
