
## Section: advise group and tap
BEGIN{
    ADVISE_NULL_TAG = SUBSEP "null"
    ADVISE_HAS_TAG  = SUBSEP "has_data"
    ADVISE_DEV_TAG_STR = "todo,inner"
    comp_advise_dev_tag_arr_init(___X_CMD_ADVISE_DEV_MOD = ENVIRON[ "___X_CMD_ADVISE_DEV_MOD" ], ADVISE_DEV_TAG_STR)
}

function comp_advise_dev_tag_arr_init( is_advise_dev_mod, str,        i, l ){
    if (is_advise_dev_mod) {
        delete ADVISE_DEV_TAG
        return
    }
    l = arr_cut( ADVISE_DEV_TAG, str, "," )
    for (i=1; i<=l; ++i) ADVISE_DEV_TAG[ SUBSEP jqu(ADVISE_DEV_TAG[i]) ] = 1
}

function comp_advise_push_group_of_obj(o, kp, arr_group, group_name,        i, l, key){
    arr_group[ ADVISE_HAS_TAG ] = true
    arr_push( arr_group, group_name )
    arr_group[ group_name L ] = l = o[ kp L ]
    for (i=1; i<=l; ++i){
        key = o[ kp, "\""i"\"" ]
        arr_group[ "GROUP_NAME", key, (++ arr_group[ "GROUP_NAME", key L ]) ] = group_name
        arr_group[ group_name, "\""i"\"" ] = key
    }
}

function comp_advise_push_group_of_value(o, kp, arr_group, group_name, value,         i, l, _keypath, _tag, _gloup_namel){
    arr_group[ ADVISE_HAS_TAG ] = true
    _gloup_namel = arr_group[ "GROUP_NAME", value L ]
    if ( comp_advise_parse_has_tag(o, kp, value)) {
        l = _gloup_namel
        for (i=1; i<=l; ++i){
            jlist_rm_value( arr_group, arr_group[ "GROUP_NAME", value, i ], value )
        }

        _keypath = kp SUBSEP value SUBSEP "\"#tag\""
        l = aobj_len( o, _keypath )
        for (i=1; i<=l; ++i) {
            _tag = o[ _keypath, "\""i"\"" ]
            if ( ! aobj_len(arr_group, _tag) ) arr_push( arr_group, _tag )
            jlist_put(arr_group, _tag, value)
        }
        return
    } else if ( _gloup_namel > 0 ) {
        return
    }

    arr_group[ 0 ] = group_name
    arr_group[ group_name ] = "["
    jlist_put(arr_group, group_name, value)
}

function comp_advise_parse_has_tag(o, kp, key,          _keypath){
    _keypath = kp SUBSEP key SUBSEP "\"#tag\""
    if (aobj_is_null(o, _keypath)) return false
    return true
}

function comp_advise_parse_group(o, kp, subcmd_group, option_group, flag_group,         i, l, v, s, k){
    l = aobj_len( o, kp )
    for (i=1; i<=l; ++i){
        v = aobj_get( o, kp SUBSEP i )
        s = juq(v)
        if ( match(s, "^#subcmd:") ) {
            k = jqu(substr( s, RLENGTH + 1 ))
            comp_advise_push_group_of_obj(o, kp SUBSEP v, subcmd_group, k)
        }
        else if ( match(s, "^#option:") ) {
            k = jqu(substr( s, RLENGTH + 1 ))
            comp_advise_push_group_of_obj(o, kp SUBSEP v, option_group, k)
        }
        else if ( match(s, "^#flag:") ) {
            k = jqu(substr( s, RLENGTH + 1 ))
            comp_advise_push_group_of_obj(o, kp SUBSEP v, flag_group, k)
        }
    }

    for (i=1; i<=l; ++i){
        v = aobj_get( o, kp SUBSEP i )
        if ( v ~ "^\"#" ) continue
        else if (aobj_is_option(o, kp SUBSEP v) || ((v ~ "^\"-") && (!aobj_is_subcmd(o, kp SUBSEP v)))) {
            if (aobj_get_optargc( o, kp, v ) > 0) comp_advise_push_group_of_value( o, kp, option_group, ADVISE_NULL_TAG, v)
            else comp_advise_push_group_of_value( o, kp, flag_group, ADVISE_NULL_TAG, v )
        }
        else comp_advise_push_group_of_value( o, kp, subcmd_group, ADVISE_NULL_TAG, v )
    }
}

function comp_advise_remove_dev_tag_of_arr_group(o, kp, arr_group,          i, j, l, _l, k ){
    l = ADVISE_DEV_TAG[L]
    for (i=1; i<=l; ++i){
        k = jqu(ADVISE_DEV_TAG[i])
        _l = arr_group[ k L ]
        for (j=1; j<=_l; ++j) jdict_rm(o, kp, arr_group[ k, "\""j"\"" ])
    }
}

# EndSection

# Section: prepare argument
function comp_advise_prepare_argarr( argstr, args, sep,       l ){
    if ( argstr == "" ) return
    sep = (sep != "") ? sep : " "
    gsub( "(^[\002]+)|([\002]+$)", "" , argstr)
    l = split(argstr, args, sep)
    args[L] = l
}

# EndSection

## Section: advise ref filepath

function comp_advise_get_ref(obj, kp,        r, msg, i, l){
    while ( (r = jref_get(obj, kp) ) != false ) {
        if (r == "[") {
            l = obj[ kp, "\"$ref\"" L ]
            for (i=1; i<=l; ++i)
                if ((msg = comp_advise_get_ref_inner(obj, kp, juq(obj[ kp, "\"$ref\"", "\""i"\"" ]))) != true) return msg
            continue
        }
        if ((msg = comp_advise_get_ref_inner(obj, kp, juq(r))) != true) return msg
    }
    return true
}

function comp_advise_get_ref_inner(obj, kp, filepath,       _, msg){
    if (aobj_str_is_null(filepath)) return "Not found referenced file"
    if ( filepath ~ "^x-cmd-advise://" ) msg = "\nTry to => `x advise man update x-cmd`"
    filepath = comp_advise_get_ref_adv_jso_filepath( filepath )
    jref_rm(obj, kp)
    jiparse2leaf_fromfile( _, kp, filepath )
    if ( cat_is_filenotfound() ) return "Not found such advise jso file => " filepath msg # " kp["kp"]"
    # cp_cover(obj, kp, _, kp)
    cp(obj, kp, _, kp)
    return true
}

function comp_advise_locate_obj_prefix( obj, args,       msg, i, j, l, argl, optarg_id, obj_prefix ){
    obj_prefix = SUBSEP "\"1\""   # Json Parser
    argl = args[L]
    for (i=1; i<=argl; ++i){
        if ((msg = comp_advise_get_ref(obj, obj_prefix)) != true) {
            log_error( "advise", msg )
            exit(1)
            return
        }

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

# EndSection
