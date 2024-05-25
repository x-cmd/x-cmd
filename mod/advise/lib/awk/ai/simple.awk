function expand_value(o, kp,       v){
    v = o[ kp ]
    if (v == "{") return expand_dict(o, kp)
    if (v == "[") return expand_list(o, kp)
}

function expand_list(o, kp,        i, l){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) expand_value(o, kp SUBSEP jqu(i))
}
function expand_dict(o, kp,        i, l, msg){
    if ((msg = comp_advise_get_ref( o, kp )) != true) return advise_error( msg )
    l = o[ kp L ]
    for (i=1; i<=l; ++i) expand_value(o, kp SUBSEP o[ kp, i ])
}


function trim_value(o, kp1, obj, kp2){
    o[ kp1 ] = obj[ kp2 ]
    if (o[ kp1 ] == "{") return trim_dict(o, kp1, obj, kp2)
    if (o[ kp1 ] == "[") return trim_list(o, kp1, obj, kp2)
}

function trim_dict(o, kp1, obj, kp2,          l, i, key, _l, val, val_l, j){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i){
        key = obj[ kp2, i ]
        # if ( key ~ "\"#(subcmd:|option:|flag:|regex|exec|tag|subcmd_help_tip|setup|demo|case|web|abstract)" ) continue
        if (( key ~ "^\"#" ) && ( key !~ "^\"#("RESERVED_FIELD")" )) continue
        else if (aobj_is_option(o, kp1 SUBSEP key) || ((key ~ "^\"-") && (!aobj_is_subcmd(o, kp1 SUBSEP key)))) continue
        o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
        o[ kp1, _l ] = key

        trim_value(o, kp1 SUBSEP key, obj, kp2 SUBSEP key)

        if (key ~ "^\"#") {
            val = o[ kp1, key ]
            if (val == "{") jdict_rm(o, kp1 SUBSEP key, "\"cn\"")
            else if (val == "[") {
                val_l = o[ kp1, key L ]
                for (j=1; j<=val_l; ++j){
                    jdict_rm(o, kp1 SUBSEP key SUBSEP "\"" j "\"", "\"cn\"")
                }
            }
        }
    }
}

function trim_list(o, kp1, obj, kp2,          l, i, key){
    o[ kp1 L ] = l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) trim_value(o, kp1 SUBSEP "\"" i "\"", obj, kp2 SUBSEP "\"" i "\"")
}

function trim_obj_of_args(o, argstr,            args, argl, kp, nextkp, i, n, l, optarg_id, _delete){
    comp_advise_prepare_argarr(argstr, args, " ")
    kp = nextkp = Q2_1
    argl = args[ L ]
    for (i=1; i<=argl; ++i){
        n = 0
        kp = nextkp
        l = aobj_len( o, kp )
        for (j=1; j<=l; ++j) {
            optarg_id = aobj_get( o, kp SUBSEP j)
            if ("|"juq(optarg_id)"|" ~ "\\|"args[i]"\\|") {
                nextkp = kp SUBSEP optarg_id
            } else if ( optarg_id !~ "\"#" ) {
                _delete[ ++n ] = optarg_id
            }
        }
        if ( l == n ) break
        for (j=1; j<=n; ++j){
            jdict_rm(o, kp, _delete[ j ])
        }
    }
}
BEGIN{
    RESERVED_FIELD = ENVIRON[ "RESERVED_FIELD" ]
    if ( RESERVED_FIELD == "" ) RESERVED_FIELD = "name|desc|tldr|other|tip"
}

{ if ($0 != "") jiparse_after_tokenize(o, $0); }
END{
    Q2_1 = SUBSEP "\"1\""
    expand_value(o, Q2_1)

    ARGSTR = ENVIRON[ "ARGSTR" ]
    if (ARGSTR != "") trim_obj_of_args(o, ARGSTR)

    trim_value( o_trim, Q2_1, o, Q2_1)
    print jstr(o_trim, Q2_1)
}
