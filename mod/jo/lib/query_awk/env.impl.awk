# a."b.c".d => a.b\\.c.d
function handle_argument(argstr,       e ){
    argvl = split(argstr, argv, "\001")
    patarrl = selector_normalize_generic( argv[1], patarr )
    for (i=2; i<=argvl; ++i) {
        e =  argv[i]
        if (match(e ,/^[A-Za-z0-9_]+=/)) {
            varname[ i - 1 ] = substr( e, 1, RLENGTH-1 )
            argv[ i ] = substr( e, RLENGTH+1 )
        } else {
            if (! match(e, /[A-Za-z0-9_]+$/) ){
                print "Cannot reason out a valid variable name from: " e >"/dev/stderr"
                exit(1)
            }
            varname[ i - 1 ] = substr( e, RSTART )
        }
        argv[ i-1 ] = accessor_normalize( argv[i] )
    }
    argvl = argvl - 1
}

function handle_jsontext( str ){
    if (str ~ /^"/) return str;  # "
    gsub("'", "'\\''", str)
    return "'" str "'"
}

BEGIN{
    if (___X_CMD_JO_ENV_MULTIPLELINE_SEP == "") {
        ___X_CMD_JO_ENV_MULTIPLELINE_SEP = "\n"
    }
}

function handle_output(value, idx, max_idx) {
    printf("%s", varname[ idx ] "=" handle_jsontext(value) ";")
    if (idx == max_idx) printf("%s", ___X_CMD_JO_ENV_MULTIPLELINE_SEP)
}
