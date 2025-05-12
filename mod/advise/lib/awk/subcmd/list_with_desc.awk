
{ if ($0 != "") jiparse_after_tokenize(obj, $0); }
END{
    ARGSTR = ENVIRON[ "ARGSTR" ]
    comp_advise_prepare_argarr(ARGSTR, args, " ")
    obj_prefix = comp_advise_locate_obj_prefix( obj, args )
    advise_gen_subcmd_list( obj, obj_prefix, arr )
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        print arr[i] LIST_DESC_SEP arr[ i, "desc" ]
    }
}

function advise_gen_subcmd_list( obj, kp, arr,          msg, i, l, k, uqk, uqkl, j, _, arrl){
    if ((msg = comp_advise_get_ref(obj, kp)) != true) return false # advise_error( msg )
    comp_advise_parse_group(obj, kp, subcmd_group, option_group, flag_group)
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, subcmd_group)

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        k = obj[ kp, i ]
        uqk = juq( k )
        if ( uqk ~ "^#|^\\$" ) continue
        else if (( uqk ~ "^-" ) && (!aobj_is_subcmd(obj, kp SUBSEP k))) continue
        uqkl = split(uqk, _, "|")
        for (j=1; j<=uqkl; ++j){
            arr[ ++arrl ] = _[j]
            arr[ arrl, "desc" ] = aobj_get_description(obj, kp SUBSEP k)
        }
    }
    return arr[ L ] = arrl
}

