
# Main entry point for advise completion
# Reads a jso (JSON) file and generates completion candidates based on arguments

# Parse each line of input as JSON into the obj array
# Uses jiparse for incremental JSON parsing
{ if ($0 != "") jiparse(obj, $0); }

END{
    # Prepare arguments from environment variable
    prepare_argarr( ENVIRON[ "ARGSTR" ], parsed_argarr )

    # Parse arguments and generate completion candidates
    # SUBSEP "\"1\"" is the root keypath for the advise object
    parse_args_to_env( parsed_argarr, obj, SUBSEP "\"1\"" )

    # Output the formatted completion candidates
    printf( "%s", comp_advise_parse_candidate_arr(CAND))
}
