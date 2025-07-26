BEGIN{
    ___X_CMD_ROOT_ADV       = ENVIRON[ "___X_CMD_ROOT_ADV" ]
    NOT_SUITABLE_COMPLETE_MOD_LIST   = ENVIRON[ "NOT_SUITABLE_COMPLETE_MOD_LIST" ]
    NOT_SUITABLE_XRC_MOD_LIST   = ENVIRON[ "NOT_SUITABLE_XRC_MOD_LIST" ]
    gen_blacklist(COMPLETE_BLACKLIST, NOT_SUITABLE_COMPLETE_MOD_LIST)
    gen_blacklist(XRC_BLACKLIST, NOT_SUITABLE_XRC_MOD_LIST)

    Q2_1    = "\"1\""
    Q2_DESC = "\"#desc\""
    Q2_NAME = "\"#name\""
    Q2_TAG  = "\"#tag\""
    Q2_REF  = "\"$ref\""
    Q2_EXEC = "\"#exec\""
    ADV_SPECIFIED_FIELD_PAT = "^(" Q2_NAME "|" Q2_DESC "|" Q2_TAG ")$"

    patarr[1] = Q2_1
    patarr[2] = ADV_SPECIFIED_FIELD_PAT
    patarrl = 2

    o[ SUBSEP Q2_1 ] = "{"
    o[L] = 1

    ADVISE_PANIC_EXIT = 0

    true = 1
    false = 0
}

function gen_is_value_null(v){  return ( (v == "") || (v == "null") );   }
function gen_blacklist(o, str,      _, i, l){
    gsub("^\n+|\n+$", "", str)
    l = split(str, _, "\n")
    for (i=1; i<=l; ++i) o[_[i]] = true
}

function get_mod_desc_of_advise_file(o, keypath, key, filepath,         kp, _, c, RS_OLD, _last_curkey, _desc_val, _name_val){
    RS_OLD = RS
    RS = "\n"
    kp = keypath SUBSEP key
    filepath = filepath_adjustifwin( filepath )
    while ((c=(getline <filepath))==1) {
        _last_curkey = (JITER_CURKEY != "") ? JITER_CURKEY : JITER_LAST_KP
        if ( jiter_regexarr_parse(_, $0, patarrl, patarr) == false )    continue
        if ( _last_curkey !~ ADV_SPECIFIED_FIELD_PAT ) continue
        jdict_put( o, kp, _last_curkey, "null")
        jmerge_soft___value( o, kp SUBSEP _last_curkey, _, SUBSEP Q2_1 )
    }
    close( filepath )
    if (c == -1) {
        log_error( "advise", "Failed to generate x advise jso, not found such filepath - " filepath )
        ADVISE_PANIC_EXIT = 1
        exit(1)
    }

    JITER_CURLEN = JITER_LEVEL = 0
    JITER_CURKEY = ""
    RS = RS_OLD

    _desc_val = o[ kp SUBSEP Q2_DESC ]
    _name_val = o[ kp SUBSEP Q2_NAME ]
    if (gen_is_value_null(_desc_val) && gen_is_value_null(_name_val)){
        # log_info( "advise", filepath " num:" ++num)
        jdict_rm( o, keypath, key)
        return false
    }
    return true
}

function handle(o, mod, filepath,           _, _q2_mod, _mod_kp, _name_kp, n, d, k){
    _q2_mod = jqu(mod)
    _mod_kp = SUBSEP Q2_1 SUBSEP _q2_mod
    jdict_put( o, SUBSEP Q2_1, _q2_mod, "{")

    if (get_mod_desc_of_advise_file( o, SUBSEP Q2_1, _q2_mod, filepath ) != true ) return
    jdict_put( o, _mod_kp, Q2_REF, "\"x-advise://"mod"\"")
    if ( XRC_BLACKLIST[ mod ] ) return
    jdict_put( o, _mod_kp, Q2_EXEC, "\"xrc "mod" 2>/dev/null\"")
}

!COMPLETE_BLACKLIST[$0]{ handle(o, $0, comp_advise_get_ref_adv_jso_filepath("x-advise://" $0) );  }
END{
    if (ADVISE_PANIC_EXIT != 0) exit(ADVISE_PANIC_EXIT)

    basepath = ENVIRON[ "BASEFILE" ]
    jiparse2leaf_fromfile( obj, "", basepath)
    if ( cat_is_filenotfound() ) {
        log_error( "advise", "Failed to generate x advise jso, not found such filepath - " basepath  )
        exit(1)
    }
    if (obj[L] > 0) jmerge_soft___value( o, SUBSEP Q2_1, obj, SUBSEP Q2_1)
    print jstr0(o)
}
