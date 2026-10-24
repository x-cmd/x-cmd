function expand_value(o, kp,       v){
    v = o[ kp ]
    if (v == "{") return expand_dict(o, kp)
    if (v == "[") return expand_list(o, kp)
}

function expand_list(o, kp,        i, l){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        expand_value(o, kp SUBSEP jqu(i))
    }
}
function expand_dict(o, kp,        i, l, msg, key, delarr, delnum, val, j, val_l){
    if ((msg = comp_advise_get_ref( o, kp )) != true) {
        if ( IS_FAILFAST == 1 ) {
            log_warn( "advise", msg )
            exit(1)
        }
    }
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        key = o[ kp, i ]
        expand_value(o, kp SUBSEP key)
        if ((( key ~ "^\"#[^0-9]" ) && ( key !~ "^\"#("RESERVED_FIELD")" )) || (key == "\"--co|,\"")) {
            delarr[++delnum] = key
            continue
        }
        else if ( (IS_DFS != 1) && (aobj_is_option(o, kp SUBSEP key) || ((key ~ "^\"-") && (!aobj_is_subcmd(o, kp SUBSEP key)))) ) {
            delarr[++delnum] = key
            continue
        }
        else if (key ~ "^\"#") {
            val = o[ kp, key ]
            if (val == "{") rm_data_lang(o, kp SUBSEP key)
            else if (val == "[") {
                val_l = o[ kp, key L ]
                for (j=1; j<=val_l; ++j){
                    rm_data_lang(o, kp SUBSEP key SUBSEP "\"" j "\"")
                }
            }
        }
    }

    for (i=1; i<=delnum; ++i){
        jdict_rm(o, kp, delarr[i])
    }
}

function trim_obj_of_args(o, argstr,            args, argl, kp, nextkp, i, delnum, l, optarg_id, delarr, trigger, j, jl, key){
    comp_advise_prepare_argarr(argstr, args, " ")
    kp = nextkp = Q2_1
    argl = args[ L ]
    for (i=1; i<=argl; ++i){
        delnum = 0
        kp = nextkp
        l = aobj_len( o, kp )
        trigger = 0
        for (j=1; j<=l; ++j) {
            optarg_id = aobj_get( o, kp SUBSEP j)
            if ("|"juq(optarg_id)"|" ~ "\\|"args[i]"\\|") {
                nextkp = kp SUBSEP optarg_id
                trigger = 1
            } else if ( optarg_id !~ "\"#" ) {
                delarr[ ++delnum ] = optarg_id
            }
        }
        if ( trigger == 0 ) {
            if ( IS_FAILFAST == 1 ) exit(1)
            else break
        }
        for (j=1; j<=delnum; ++j){
            jdict_rm(o, kp, delarr[ j ])
        }
    }

    if (IS_DFS != 1){
        kp = nextkp
        FINAL_KP = kp
        l = aobj_len( o, kp )
        for (i=1; i<=l; ++i){
            optarg_id = aobj_get( o, kp SUBSEP i)
            if ( optarg_id !~ "\"#" ) {
                delnum = 0
                jl = aobj_len( o, kp SUBSEP optarg_id )
                for (j=1; j<=jl; ++j){
                    key = aobj_get( o, kp SUBSEP optarg_id SUBSEP j )
                    if ( key !~ "\"#" ) delarr[ ++delnum ] = key
                }

                for (j=1; j<=delnum; ++j){
                    jdict_rm(o, kp SUBSEP optarg_id, delarr[ j ])
                }
            }
        }
    }
}
function rm_data_lang(o, kp,      i){
    for (i=1; i<=RM_DATA_LANG_L; ++i) jdict_rm(o, kp, RM_DATA_LANG[i])
}

BEGIN{
    RESERVED_FIELD  = ENVIRON[ "RESERVED_FIELD" ]
    IS_DFS          = ENVIRON[ "IS_DFS" ]
    IS_FAILFAST     = ENVIRON[ "IS_FAILFAST" ]
    ARGSTR          = ENVIRON[ "ARGSTR" ]
    DATA_LANG       = ENVIRON[ "DATA_LANG" ]
    if ((DATA_LANG == "cn") || (DATA_LANG =="zh")) {
        # Chinese output: keep 'cn'/'zh', remove 'en'
        RM_DATA_LANG[1] = "\"en\""
        RM_DATA_LANG_L  = 1
    } else {
        # English output: remove both 'cn' and 'zh'
        RM_DATA_LANG[1] = "\"cn\""
        RM_DATA_LANG[2] = "\"zh\""
        RM_DATA_LANG_L  = 2
    }
}

{ if ($0 != "") jiparse_after_tokenize(o, $0); }
END{
    FINAL_KP = Q2_1 = SUBSEP "\"1\""
    expand_value(o, Q2_1)

    trim_obj_of_args(o, ARGSTR)

    print jstr(o, FINAL_KP)
}
