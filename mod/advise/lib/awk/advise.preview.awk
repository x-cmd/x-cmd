
# Preview completion candidates of an advise jso file
#
# Input:
#   - the jso file (JSON lines) on stdin, parsed with jiparse (same as advise.main.awk)
#   - queries from ENVIRON[ "ARGSTRS" ]: one or more query strings joined with
#     \001; EACH ARGUMENT given to `x advise preview` is one query string
#
# Query string syntax (exact, no quoting conventions):
#   - words are split on single spaces; '\ ' escapes a literal space in a word
#   - the LAST word is the one being completed
#   - a query ending with a space (or an empty query) completes an empty word
#
# Output: for each query, one header line '#<n>: <words>' (the completing
# word shown as '' when empty) followed by its candidates as
# '<cmd>\t<desc>' lines. Dynamic exec candidates cannot run inside awk -
# they are shown as '[exec] <shell command>' lines instead.
# A query that fails prints '[ADVISE PANIC]: ...' under its own header;
# remaining queries still run. Exit code is 1 if ANY query failed.
#
# Loaded after the advise parsing libraries, replacing advise.main.awk.

{ if ($0 != "") jiparse(obj, $0); }

END{
    rc = 0
    queryl = split(ENVIRON[ "ARGSTRS" ], query_arr, "\001")
    if (queryl == 0) queryl = 1     # no query at all: complete the first word
    for (query_idx=1; query_idx<=queryl; ++query_idx) {
        # CAND accumulates results across queries - reset it per query
        delete CAND
        argl = preview_tokenize( query_arr[ query_idx ], parsed_argarr )
        parse_args_to_env( parsed_argarr, obj, SUBSEP "\"1\"" )
        printf "#%d: %s\n", query_idx, preview_display_query( query_arr[ query_idx ] )
        if ( ! comp_advise_preview_print_candidate( CAND ) ) rc = 1
    }
    exit rc
}

# Splits a query string into words on single spaces ('\ ' escapes a literal
# space). A trailing separator means the word being completed is empty.
# Returns the word count and fills arr (arr[L] = count).
function preview_tokenize( query, arr,      n, word, rest ){
    n = 0; rest = query
    while (match(rest, /^(\\ |[^ ])+/)) {
        word = substr(rest, 1, RLENGTH); rest = substr(rest, RLENGTH + 1)
        sub(/^ /, "", rest)
        gsub(/\\ /, " ", word)
        arr[ ++n ] = word
    }
    if ((query != "") && (substr(query, length(query)) == " "))
        arr[ ++n ] = ""             # completing an empty word
    arr[ L ] = n
    return n
}

# Renders a query string for the header line: words joined with spaces,
# the completing empty word shown as ''
function preview_display_query( query,      i, l, w, s ){
    l = preview_tokenize( query, w )
    if (l == 0) return "''"
    s = ""
    for (i=1; i<=l; ++i)
        s = s (i>1 ? " " : "") ((w[i] == "") ? "''" : w[i])
    return s
}

# Prints CAND as '<cmd>\t<desc>' lines. Returns 1 on success, 0 on panic.
function comp_advise_preview_print_candidate( arr,      i, l, v, d ){
    if ((d = arr[ "MESSAGE" ]) != "") {
        printf "[ADVISE PANIC]: %s\n", juq(d)
        return 0
    }

    l = arr[ "CODE" L ]
    for (i=1; i<=l; ++i){
        v = arr[ "CODE", i ]
        d = arr[ "CODE", v ]
        comp_advise_preview_print_line( juq(v), juq(d) )
    }

    l = arr[ "NOSPACE" L ]
    for (i=1; i<=l; ++i){
        v = arr[ "NOSPACE", i ]
        d = arr[ "NOSPACE", v ]
        comp_advise_preview_print_line( juq(v), juq(d) )
    }

    l = arr[ "EXEC" L ]
    for (i=1; i<=l; ++i)    comp_advise_preview_print_line( "[exec] " juq(arr[ "EXEC", i ]), "" )

    l = arr[ "EXEC_STDOUT" L ]
    for (i=1; i<=l; ++i)    comp_advise_preview_print_line( "[exec] " juq(arr[ "EXEC_STDOUT", i ]), "" )

    l = arr[ "EXEC_STDOUT_NOSPACE" L ]
    for (i=1; i<=l; ++i)    comp_advise_preview_print_line( "[exec] " juq(arr[ "EXEC_STDOUT_NOSPACE", i ]), "" )

    return 1
}

function comp_advise_preview_print_line( v, d ){
    # Flatten tab/newline/CR in desc, so each record stays on one line
    gsub(/[\t\n\r\f\v]/, " ", d)
    if (d == "")    printf "%s\n", v
    else            printf "%s\t%s\n", v, d
}
