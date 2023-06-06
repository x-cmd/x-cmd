# a."b.c".d => a.b\\.c.d
function handle_argument(argstr,       e ){
    argvl = split(argstr, argv, "\001")
    patarrl = selector_normalize_generic( argv[1], patarr )
    for (i=2; i<=argvl; ++i)   argv[ i-1 ] = accessor_normalize( argv[i] );
    argvl = argvl - 1
}

function handle_output( value, idx, max_idx ){
    print value
}
