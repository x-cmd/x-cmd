{ if ($0 != "") jiparse_after_tokenize(obj, $0); }
END{
    ARGSTR = ENVIRON[ "ARGSTR" ]
    comp_advise_prepare_argarr(ARGSTR, args, " ")
    obj_prefix = comp_advise_locate_obj_prefix( obj, args )
    advise_gen_subcmd_list( obj, obj_prefix, arr )
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        print arr[i]
    }
}

function advise_gen_subcmd_list( obj, kp, arr,          msg, i, l, k, uqk, uqkl, j, _, arrl){
    if ((msg = comp_advise_get_ref(obj, kp)) != true) return false # advise_error( msg )
    comp_advise_parse_group(obj, kp, subcmd_group, option_group, flag_group)

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, i ]
        uqk = juq( k )
        # v1: plain layer keys are subcommands; options live in #option containers
        if ( uqk ~ "^#|^\\$" ) continue
        uqkl = split(uqk, _, "|")
        for (j=1; j<=uqkl; ++j){
            arr[ ++arrl ] = _[j]
        }
    }
    return arr[ L ] = arrl
}

