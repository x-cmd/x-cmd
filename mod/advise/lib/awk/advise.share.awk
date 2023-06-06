
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

function comp_advise_key_has_in_group(arr_group, key,      i, l){
    l = aobj_len( arr_group )
    for (i=1; i<=l; ++i) if (jlist_has( arr_group, arr_group[i], key )) return true
    return false
}

function comp_advise_parse_tag_unit(o, kp, key, arr_group,          i, l, _tag, _keypath){
    _keypath = kp SUBSEP key SUBSEP "\"#tag\""
    if (aobj_is_null(o, _keypath)) return
    l = aobj_len( arr_group )
    for (i=1; i<=l; ++i) jlist_rm_value( arr_group, arr_group[i], key )
    l = aobj_len( o, _keypath )
    for (i=1; i<=l; ++i) {
        _tag = o[ _keypath, "\""i"\"" ]
        if ( ! aobj_len(arr_group, _tag) ) arr_push( arr_group, _tag )
        jlist_put(arr_group, _tag, key)
    }
}

function comp_advise_parse_tag(o, kp, arr_group,       i, l, j, _key){
    l = arr_len(arr_group, ADVISE_NULL_TAG)
    for (i=1; i<=l; ++i) {
        _key = arr_group[ ADVISE_NULL_TAG, "\""i"\"" ]
        comp_advise_parse_tag_unit(o, kp, _key, arr_group)
        if (comp_advise_key_has_in_group(arr_group, _key))
            if ( jlist_rm_idx(arr_group, ADVISE_NULL_TAG, i--) ) l--
    }
}

function comp_advise_push_group_of_obj(arr_group, key, o, kp){
    arr_group[ ADVISE_HAS_TAG ] = true
    jcp_cover(arr_group, key, o, kp)
}

function comp_advise_push_group_of_value(arr_group, key, value,         l){
    arr_group[ ADVISE_HAS_TAG ] = true
    arr_group[ 0 ] = key
    arr_group[ key ] = "["
    jlist_put(arr_group, key, value)
}

function comp_advise_parse_group(o, kp, subcmd_group, option_group, flag_group,         i, l, v, s, k){
    l = aobj_len( o, kp )
    for (i=1; i<=l; ++i){
        v = aobj_get( o, kp SUBSEP i )
        s = juq(v)
        if ( match(s, "^#subcmd:") ) {
            k = jqu(substr( s, RLENGTH + 1 ))
            arr_push( subcmd_group, k )
            comp_advise_push_group_of_obj(subcmd_group, k, o, kp SUBSEP v)
        }
        else if ( match(s, "^#option:") ) {
            k = jqu(substr( s, RLENGTH + 1 ))
            arr_push( option_group, k )
            comp_advise_push_group_of_obj(option_group, k, o, kp SUBSEP v)
        }
        else if ( match(s, "^#flag:") ) {
            k = jqu(substr( s, RLENGTH + 1 ))
            arr_push( flag_group, k )
            comp_advise_push_group_of_obj(flag_group, k, o, kp SUBSEP v)
        } else if (( s ~ "^-" ) && ( ! aobj_istrue(o, aobj_get_special_value_id(kp SUBSEP v, "subcmd")) )) {
            if (aobj_get_optargc( o, kp, v ) > 0) comp_advise_push_group_of_value( option_group, ADVISE_NULL_TAG, v)
            else comp_advise_push_group_of_value( flag_group, ADVISE_NULL_TAG, v )
        }
        else if ( s !~ "^#" ) comp_advise_push_group_of_value( subcmd_group, ADVISE_NULL_TAG, v )
    }
    comp_advise_parse_tag(o, kp, subcmd_group)
    comp_advise_parse_tag(o, kp, option_group)
    comp_advise_parse_tag(o, kp, flag_group)
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

# Section: advise filepath

function comp_advise_get_ref_adv_jso_filepath( str,         _id ) {
    if (match(str, "^x-advise://")) {
        str = substr( str, RLENGTH+1 )
        if ( str ~ "/" ) return ___X_CMD_ROOT_ADV "/" str
        return ___X_CMD_ROOT_ADV "/" str "/advise.jso"
    }
    else if (match(str, "^x-cmd-advise://")) {
        str = substr( str, RLENGTH+1 )
        if ( str ~ "/" ) return ___X_CMD_ADVISE_MAN_XCMD_FOLDER "/" str
        return ___X_CMD_ADVISE_MAN_XCMD_FOLDER "/" str "/advise.t.jso"
    }
    return str
}

function comp_advise_get_ref(obj, kp,        r, filepath, _){
    while ( (r = jref_get(obj, kp) ) != false ) {
        filepath = comp_advise_get_ref_adv_jso_filepath( juq(r) )
        jref_rm(obj, kp)
        jiparse2leaf_fromfile( _, kp, filepath )
        if ( cat_is_filenotfound() ) return "Not found such advise jso file - " filepath
        cp_cover(obj, kp, _, kp)
        delete _
    }
    return true
}

# EndSection
