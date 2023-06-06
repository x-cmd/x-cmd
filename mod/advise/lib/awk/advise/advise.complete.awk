
# shellcheck shell=bash

# get the candidate value
function advise_get_ref_and_group(obj, kp,        msg, subcmd_group, option_group, flag_group){
    if ((msg = comp_advise_get_ref(obj, kp)) != true) return advise_panic( msg )
    comp_advise_parse_group(obj, kp, subcmd_group, option_group, flag_group)
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, subcmd_group)
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, option_group)
    comp_advise_remove_dev_tag_of_arr_group(obj, kp, flag_group)
    return true
}

function advise_get_candidate_code( curval, genv, lenv, obj, kp,        _candidate_code, i, j, l, v, _option_id, _cand_key, _cand_l, _cand_kp, _desc, _arr_value, _arr_valuel ) {
    l = aobj_len(obj, kp)
    gsub("\\\\", "\\\\", curval)
    for (i=1; i<=l; ++i) {
        _option_id = aobj_get(obj, kp SUBSEP i)
        if ( _option_id == "\"#cand\"" ) {
            _cand_key = kp SUBSEP _option_id
            _cand_l = aobj_len(obj, _cand_key)
            for (j=1; j<=_cand_l; ++j) {
                _cand_kp = _cand_key SUBSEP "\""j"\""
                v = aobj_get_cand_value( obj, _cand_kp)
                _desc = ( ZSHVERSION != "" ) ? aobj_get_description(obj, _cand_kp SUBSEP v) : ""
                if (v ~ "^\"") v = juq(v)
                if( v !~ curval ) continue
                jdict_put( CAND, "CODE", jqu(v), jqu(_desc) )
            }
        }
        if ( _option_id ~ "^\"#") continue

        _desc = ( ZSHVERSION != "" ) ? aobj_get_description(obj, kp SUBSEP _option_id) : ""
        _arr_valuel = split( juq( _option_id ), _arr_value, "|" )
        for ( j=1; j<=_arr_valuel; ++j) {
            v =_arr_value[j]
            if (v !~ "^"curval) continue
            if ( ! aobj_is_multiple(obj, kp SUBSEP _option_id) && (lenv[ _option_id ] != "")) continue
            if (( curval == "" ) && ( v ~ "^-" )) if ( ! aobj_is_subcmd(obj, kp SUBSEP _option_id ) ) continue
            if (( curval == "-" ) && ( v ~ "^--." )) continue
            jdict_put( CAND, "CODE", jqu(v), jqu(_desc) )
        }
    }
    return _candidate_code
}

function advise_complete___generic_value( curval, genv, lenv, obj, kp, _candidate_code,         _exec_val, _regex_id, _regexl, _regex_key, i ){

    _candidate_code = _candidate_code advise_get_candidate_code( curval, genv, lenv, obj, kp )

    _exec_val = aobj_get_special_value(obj, kp, "exec")
    if ( _exec_val != "" ) jdict_put( CAND, "EXEC", _exec_val, "null" )

    _regex_id = aobj_get_special_value_id( kp, "regex" )
    _regexl   = aobj_len(obj, _regex_id)
    for ( i=1; i<=_regexl; ++i ) {
        _regex_key = aobj_get(obj, _regex_id SUBSEP i)
        if (curval ~ "^"juq( _regex_key )"$" ) return advise_complete___generic_value(curval, genv, lenv, obj, _regex_id SUBSEP _regex_key , _candidate_code)
    }
}

# Just show the value
function advise_complete_option_value( curval, genv, lenv, obj, obj_prefix, option_id, arg_nth ){
    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix SUBSEP option_id SUBSEP "\"#" arg_nth "\"")
}

# Just tell me the arguments
function advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, nth, _candidate_code,      _kp ){
    _kp = obj_prefix SUBSEP "\"#" nth "\""
    if ( advise_get_ref_and_group(obj, _kp) && (aobj_get(obj, _kp) != "")) return advise_complete___generic_value( curval, genv, lenv, obj, _kp, _candidate_code )

    _kp = obj_prefix SUBSEP "\"#n\""
    if ( advise_get_ref_and_group(obj, _kp) && (aobj_get(obj, _kp) != "")) return advise_complete___generic_value( curval, genv, lenv, obj, _kp, _candidate_code )

    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix )
}

# Most complicated #1
function advise_complete_option_name_or_argument_value( curval, genv, lenv, obj, obj_prefix,          _candidate_code, i, k, l, _required_options ){

    _candidate_code = advise_get_candidate_code( curval, genv, lenv, obj, obj_prefix )
    if ( ( curval == "" ) || ( curval ~ /^-/ ) || (aobj_option_all_set( lenv, obj, obj_prefix ))) {
        advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, 1, _candidate_code)
        return true
    }

    l = aobj_len(obj, obj_prefix)
    for (i=1; i<=l; ++i) {
        k = aobj_get(obj, obj_prefix SUBSEP i)
        if (k ~ "^\"[^-]") continue
        if ( aobj_is_subcmd(obj, obj_prefix SUBSEP k ) ) continue
        if ( ! aobj_is_required(obj, obj_prefix SUBSEP k) ) continue
        if ( lenv_table[ k ] == "" ) _required_options = (_required_options == "") ? k : _required_options ", " k
    }
    return advise_panic("Required options [ " _required_options " ] should be set")

}
