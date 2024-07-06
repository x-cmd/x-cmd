BEGIN{
    if (___X_CMD_HELP_LANGUAGE != "cn") {
        if (___X_CMD_HELP_LANGUAGE == "zh" ) ___X_CMD_HELP_LANGUAGE = "cn"
        else ___X_CMD_HELP_LANGUAGE = "en"
    }
    ___X_CMD_HELP_LANGUAGE = jqu(___X_CMD_HELP_LANGUAGE);
}

function aobj_get_value_with_local_language(o, kp, language){
    return o[ aobj_get_kp_with_local_language(o, kp, language) ]
}

function aobj_get_kp_with_local_language(o, kp, language){
    if (! aobj_is_null(o, kp SUBSEP language)) return kp SUBSEP language
    return kp SUBSEP "\"en\""
}

# Except getting option argument count
function aobj_cal_rest_argc_maxmin( obj, obj_prefix,       i, j, k, l, _min, _max, _arr, _arrl ){
    _min = 0
    _max = 0
    l = obj[ obj_prefix L ]
    for (i=1; i<=l; ++i) {
        k = juq(obj[ obj_prefix, i ])

        # #n or #n|...
        if (k ~ "^#n(([|].+))?$") {
            _max = 10000 # Big Number
            continue
        }

        if (k ~ "^#[a-zA-z]") continue

        _arrl = split(k, _arr, "|")
        for (j=1; j<=_arrl; ++j) NAME_ID[ obj_prefix, _arr[j] ] = jqu(k)

        if (k ~ "^#[0-9]+") {
            k = int( substr(k, 2) )
            if (aobj_is_required( obj, obj_prefix SUBSEP obj[ obj_prefix, i ] ) ) {
                if (_min < k) _min = k
            }
            if (_max < k) _max = k
        }
    }
    obj[ obj_prefix, L "restargc__min" ] = _min
    obj[ obj_prefix, L "restargc__max" ] = _max
}

function aobj_option_all_set( lenv_table, obj, obj_prefix,  i, l, k ){
    l = obj[ obj_prefix L ]
    for (i=1; i<=l; ++i) {
        k = obj[ obj_prefix, i ]
        if (k ~ "^\"[^-]") continue
        if ( aobj_is_subcmd(obj, obj_prefix SUBSEP k) ) continue

        if ( aobj_is_required(obj, obj_prefix SUBSEP k) ) {
            if ( lenv_table[ k ] == "" )  return false
        }
    }
    return true
}

function aobj_get_subcmdid_by_id( obj, obj_prefix, id ){
    if ( aobj_is_option(obj, obj_prefix SUBSEP id) ) return
    if ( juq(id) ~ /^[^-]/) return id
    if ( aobj_is_subcmd(obj, obj_prefix SUBSEP id) ) return id
    return
}

function aobj_get_id_by_name( obj, obj_prefix, name, _res ){
    if ("" != (_res = NAME_ID[ obj_prefix, name ]) )  return _res
    aobj_cal_rest_argc_maxmin( obj, obj_prefix )
    return NAME_ID[ obj_prefix, name ]
}

function aobj_is_required( obj, kp ){
    return (obj[ kp, "\"#required\"" ] == "true" )
}

function aobj_is_multiple( obj, kp ){
    return (obj[ kp, "\"#multiple\"" ] == "true" )
}

function aobj_is_subcmd( obj, kp ){
    return (obj[ kp, "\"#subcmd\"" ] == "true" )
}

function aobj_is_option( obj, kp ){
    return (obj[ kp, "\"#option\"" ] == "true")
}

function aobj_is_nospace( obj, kp ){
    return (obj[ kp, "\"#nospace\"" ] == "true")
}

function aobj_istrue( obj, kp ){
    return (obj[ kp ] == "true" )
}

function aobj_get_optargc( obj, obj_prefix, option_id,  _res, i, l, v ){
    obj_prefix = obj_prefix SUBSEP option_id
    if ( "" != (_res = obj[ obj_prefix L "argc" ]) ) return _res
    for (i=1; i<100; ++i) {     # 100 means MAXINT
        if (obj[ obj_prefix, jqu("#" i) ] == "") break
    }
    if (i != 1 ) return obj[ obj_prefix, option_id L "argc" ] = --i
    else {
        if ( obj[ obj_prefix ] == "[") return obj[ obj_prefix L "argc" ] = ( obj[ obj_prefix, option_id L ] > 0 )
        l = obj[ obj_prefix L]
        for (i=1; i<=l; ++i) {
            v = obj[ obj_prefix, i ]
            if ((v ~ "^\"#exec") || (v ~ "^\"#cand") || v ~ "^\"#regex") return obj[ obj_prefix L "argc" ] = 1
            if (v ~ "^\"#") continue
            return obj[ obj_prefix L "argc" ] = 1
        }
    }
    return 0
}

function aobj_get_minimum_rest_argc( obj, obj_prefix, rest_arg_id,  _res ){
    if ( ( _res = obj[ obj_prefix, L "restargc__min" ] ) != "" ) return _res

    aobj_cal_rest_argc_maxmin( obj, obj_prefix, rest_arg_id )
    return obj[ obj_prefix, L "restargc__min" ]
}

function aobj_get_maximum_rest_argc( obj, obj_prefix, rest_arg_id, _res ){
    if ( ( _res = obj[ obj_prefix, L "restargc__max" ] ) != "" ) return _res

    aobj_cal_rest_argc_maxmin( obj, obj_prefix, rest_arg_id )
    return obj[ obj_prefix, L "restargc__max" ]
}

function aobj_get( obj, obj_prefix ){
    return obj[ obj_prefix ]
}

function aobj_len( obj, obj_prefix ){
    return obj[ obj_prefix L ]
}

function aobj_get_special_value_id( obj_prefix, v ){
    return obj_prefix SUBSEP "\"#" v "\""
}

function aobj_get_special_value( obj, obj_prefix, v ){
    return obj[ obj_prefix SUBSEP "\"#" v "\""]
}

function aobj_get_description( obj, obj_prefix,         d, _kp, _kp_name, _n ){
    _kp_name = aobj_get_special_value_id( obj_prefix, "name" )
    _n = obj[ _kp_name ]
    if ( _n == "{" ) d = obj[ _kp_name, obj[ _kp_name, 1 ] ]
    if ( d =="null" ) d = aobj_get_value_with_local_language(obj, _kp_name, ___X_CMD_HELP_LANGUAGE)
    if ( d == "" ) {
        _kp = aobj_get_special_value_id( obj_prefix, "desc" )
        if ( (d = obj[ _kp ]) == "{" ) d = aobj_get_value_with_local_language(obj, _kp, ___X_CMD_HELP_LANGUAGE)
    }
    if ( ! aobj_str_is_null(d) ) return aobj_uq(d)
}


function aobj_get_cand_value( obj, _cand_kp,       v){
    v = aobj_get(obj, _cand_kp)
    if ( v == "{" ) v = aobj_get(obj, _cand_kp SUBSEP 1)
    return v
}

function aobj_get_default( obj, obj_prefix ){
    return aobj_get_special_value(obj, obj_prefix, "default")
}

function aobj_str_is_null( s ){
    return (( s == "") || ( s == "null") || ( s == "\"\""))
}

function aobj_is_null(obj, kp){
    return aobj_str_is_null( obj[kp] )
}

function aobj_uq(v) {
    v = ( (v ~ "^\"") ? juq(v) : v )
    return str_trim(v)
}

