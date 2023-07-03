
{ if ($0 != "") jiparse_after_tokenize(obj, $0); }
END{
    prepare_argarr( ENVIRON[ "ARGSTR" ], parsed_argarr )
    parse_args_to_env( parsed_argarr, obj, SUBSEP "\"1\"" )
    printf( "%s", comp_advise_parse_candidate_arr(CAND))
}
