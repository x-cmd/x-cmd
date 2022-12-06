
{
    if (NR>1) {
        # if ($0 != "") jiparse(obj, $0)
        if ($0 != "") jiparse_after_tokenize(obj, $0)
    } else prepare_argarr( $0, parsed_argarr )
}

END{
    if (parse_args_to_env( parsed_argarr, obj, SUBSEP "\"1\"", genv_table, lenv_table )) printf( "offset=%s\n", OFFSET)
    printf( "%s", CODE)
}
