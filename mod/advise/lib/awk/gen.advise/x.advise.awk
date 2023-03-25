BEGIN{
    ___X_CMD_ROOT_MOD       = ENVIRON[ "___X_CMD_ROOT_MOD" ]
    NOT_COMPLETE_MOD_LIST   = ENVIRON[ "NOT_COMPLETE_MOD_LIST" ]
    gen_blacklist(BLACKLIST, NOT_COMPLETE_MOD_LIST)

    Q2_1 = "\"1\""
    Q2_DESC = "\"#desc\""
    Q2_NAME = "\"#name\""
    Q2_TAG = "\"#tag\""
    Q2_REF = "\"$ref\""
    ADV_SPECIFIED_FIELD_PAT = "^(" Q2_NAME "|" Q2_DESC "|" Q2_TAG ")$"

    patarr[1] = Q2_1
    patarr[2] = ADV_SPECIFIED_FIELD_PAT
    patarrl = 2

    o[ SUBSEP Q2_1 ] = "{"
    o[L] = 1
}

function is_value_null(v){  return ( (v == "") || (v == "null") );   }
function gen_blacklist(o, str,      _, i, l){
    l = split(str, _, "\n")
    for (i=1; i<=l; ++i) o[_[i]] = true
}

function get_mod_desc_of_advise_file(o, kp, filepath,       _, c, RS_OLD, _last_curkey){
    RS_OLD = RS
    RS = "\n"
    while ((c=(getline <filepath))==1) {
        _last_curkey = (JITER_CURKEY != "") ? JITER_CURKEY : JITER_LAST_KP
        if ( jiter_regexarr_parse(_, $0, patarrl, patarr) == false )    continue
        if ( _last_curkey !~ ADV_SPECIFIED_FIELD_PAT ) continue
        jdict_put( o, kp, _last_curkey, "null")
        cp_cover( o, kp SUBSEP _last_curkey, _, SUBSEP Q2_1 )
    }
    close( filepath )
    JITER_CURLEN = JITER_LEVEL = 0
    JITER_CURKEY = ""
    RS = RS_OLD
}

function handle(o, mod, filepath,           _, _q2_mod, _mod_kp, _name_kp, n, d, k){
    _q2_mod = jqu(mod)
    _mod_kp = SUBSEP Q2_1 SUBSEP _q2_mod
    jdict_put( o, SUBSEP Q2_1, _q2_mod, "{")
    get_mod_desc_of_advise_file( o, _mod_kp, filepath )
    jdict_put( o, _mod_kp, Q2_REF, "\""mod"/res/advise.jso\"")
}

!BLACKLIST[$0]{ handle(o, $0, ___X_CMD_ROOT_MOD "/" $0 "/res/advise.jso");  }
END{
    basepath = ENVIRON[ "BASEFILE" ]
    jiparse2leaf_fromfile( obj, "", basepath)
    if (obj[L] > 0) cp_cover( o, SUBSEP Q2_1, obj, SUBSEP Q2_1)
    print jstr0(o)
}
