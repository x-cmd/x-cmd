BEGIN{
    Q2_REPLACE_LIST = "\"replace-list\"";
    REPLACE_LIST_KP = SUBSEP Q2_1 SUBSEP Q2_REPLACE_LIST
}

# Section: parse replace info obj
function parse_replace_info(text, replace_obj){
    if ( text == "") return
    else if ( text ~ "^replace:" ) {
        parse_replace_info_from_list( substr(text, length("replace:")+1), replace_obj )
    } else {
        jiparse_after_tokenize( _, text); JITER_CURLEN = 0
        parse_replace_info_from_obj(_, replace_obj);          delete _
    }
}

function parse_replace_info_from_list(str, replace_obj,        l, i, a, _id){
    jlist_put(replace_obj, "", "{")
    jdict_put(replace_obj, SUBSEP Q2_1, Q2_REPLACE_LIST, "{")
    l = split(str, a, ",")
    for (i=1; i<=l; ++i){
        _id = index(a[i], "=")
        jdict_put(replace_obj, REPLACE_LIST_KP, jqu(substr(a[i], 1, _id-1)), jqu(substr(a[i], _id+1 )))
    }
}

function parse_replace_info_from_obj(obj, replace_obj){
    jlist_put(replace_obj, "", "{")
    jdict_put(replace_obj, SUBSEP Q2_1, Q2_REPLACE_LIST, "{")
    jmerge_force___value(replace_obj, REPLACE_LIST_KP, obj, REPLACE_LIST_KP)
}
# EndSection

# Section: replace fields
function replace_main(o, kp, obj,       key, k, v, l, i, value){
    key = o[ kp ]
    k = REPLACE_LIST_KP SUBSEP key
    v = obj[ k ]
    if (v == "" )    return
    if (v != "[")    return o[kp] = v
    if ( ! match(kp, SUBSEP "\"[0-9]+\"$") ) return

    IS_REPLACE_ARR = true
    kp = substr( kp, 1, RSTART-1)
    l = obj[ k L ]
    for (i=1; i<=l; ++i){
        value = obj[ k, "\""i"\"" ]
        # arr push
        if( ! jlist_has(o, kp, value)) jlist_put(o, kp, value)
    }
    jlist_rm_value(o, kp, key)
}
function replace_list(o, kp, obj,          l, i){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        replace_value(o, kp SUBSEP "\""i"\"", obj)
        if (IS_REPLACE_ARR == true) { i--; l--; IS_REPLACE_ARR = false; }
    }
}
function replace_dict(o, kp, obj,          l, i){
    l = o[ kp L]
    for (i=1; i<=l; ++i) replace_value(o, kp SUBSEP o[ kp, i ], obj)
}
function replace_value(o, kp, obj,         t){
    t = o[ kp ]
    if (t == "{")      return replace_dict(o, kp, obj)
    else if (t == "[") return replace_list(o, kp, obj)
    else               return replace_main(o, kp, obj)
}
function replace(o, obj,            l, i){
    l = o[L]
    for (i=1; i<=l; ++i) replace_value(o, SUBSEP "\""i"\"", obj)
}
# EndSection

function apply_fields_replace(obj, replace_obj,         _){
    if (obj[ REPLACE_LIST_KP L] > 0) {
        parse_replace_info_from_obj(obj, _)
        jmerge_force(replace_obj, _)
        jdict_rm(obj, SUBSEP Q2_1, Q2_REPLACE_LIST)
    }
    replace(obj, replace_obj)
    # print jstr(obj)
}