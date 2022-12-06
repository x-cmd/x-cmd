
# Section: prepare argument
function prepare_argarr( argstr,        l ){
    if ( argstr == "" ) return
    gsub( "(^[\002]+)|([\002]+$)", "" , argstr)
    l = split(argstr, args, "\002")
    args[L] = l
}

{
    if (NR == 1) { prepare_argarr( $0 ); next; }
    if ($0 != "") jiparse_after_tokenize(obj, $0)
}

function locate_obj_prefix( args,       i, j, l, argl, optarg_id, obj_prefix ){
    obj_prefix = SUBSEP "\"1\""   # Json Parser
    argl = args[L]
    for (i=1; i<=argl; ++i){
        l = aobj_len( obj, obj_prefix )
        for (j=1; j<=l; ++j) {
            optarg_id = aobj_get( obj, obj_prefix SUBSEP j)
            if ("|"juq(optarg_id)"|" ~ "\\|"args[i]"\\|") {
                obj_prefix = obj_prefix SUBSEP optarg_id
                break
            }
        }
        if (j>l) break
    }
    return obj_prefix
}

END{
    obj_prefix = locate_obj_prefix( args )

    print_helpdoc( obj, obj_prefix ) > "/dev/stderr";
}
