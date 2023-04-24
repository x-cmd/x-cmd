
BEGIN{
    Q2_1 = "\"" 1 "\""

    Q2_MEMBER = "\"member\""
    Q2_ACCESS_LEVEL="\"access_level\""
    Q2_OWNER = "\"owner\""
    Q2_MAINTAINER = "\"maintainer\""
    Q2_DEVELOPER = "\"developer\""
    Q2_REPORTER = "\"reporter\""
    Q2_GUEST = "\"guest\""

    Q2_VISIBILITY = "\"visibility\""
    Q2_PUBLIC = "\"public\""
    Q2_PRIVATE = "\"private\""
    Q2_INTERNAL = "\"internal\""

    Q2_LOGIN = "\"username\""
    Q2_REPO = "\"repo\""
    Q2_PATH_WITH_NAMESPACE = "\"path_with_namespace\""
    Q2_DEFAULE_BRANCH = "\"default_branch\""
}

# Section: YML => json ==(PARSE)==> o

# Section: parse: api.json => o


function gl_api_init(o){
    jdict_put(o, "", Q2_1, "{")
}

function gl_api_to_member( o, obj,            kp, _kp_member, _kp_permission, l, i, n ){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_MEMBER, "{")

    _kp_member = kp SUBSEP Q2_MEMBER
    jdict_put(o, _kp_member, Q2_OWNER, "[")
    jdict_put(o, _kp_member, Q2_MAINTAINER, "[")
    jdict_put(o, _kp_member, Q2_DEVELOPER, "[")
    jdict_put(o, _kp_member, Q2_REPORTER, "[")
    jdict_put(o, _kp_member, Q2_GUEST, "[")

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        n = obj[ kp, jqu(i), Q2_LOGIN ]
        access = obj[ kp, jqu(i), Q2_ACCESS_LEVEL ]
        if ( access == 50 ) {
            gl_repo_member_add( o, n, Q2_OWNER)
        } else if ( access == 40 ) {
            gl_repo_member_add( o, n, Q2_MAINTAINER)
        } else if ( access == 30 ) {
            gl_repo_member_add( o, n, Q2_DEVELOPER)
        } else if ( access == 20 ) {
            gl_repo_member_add( o, n, Q2_REPORTER)
        } else if ( access == 10 ) {
            gl_repo_member_add( o, n, Q2_GUEST)
        }
    }

}

function gl_api_to_name(o, obj,         kp, v, l){
    kp = SUBSEP Q2_1
    v = o[ kp, Q2_REPO ]
    if ( v == "" ) {
        o[ kp L ] = l = o[ kp L ] + 1
        o[ kp, l ] = Q2_REPO
    }
    o[ kp, Q2_REPO ] = obj[ kp , Q2_PATH_WITH_NAMESPACE ]
}

function gl_api_to_visibility(o, obj,       kp){
    kp = SUBSEP Q2_1
    if ( obj[ kp, Q2_VISIBILITY ] == Q2_PRIVATE ) return jdict_put(o, kp, Q2_VISIBILITY, Q2_PRIVATE)
    if ( obj[ kp, Q2_VISIBILITY ] == Q2_PUBLIC ) return jdict_put(o, kp, Q2_VISIBILITY, Q2_PUBLIC )
}

function gl_api_to_default_branch(o, obj,       kp){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_DEFAULE_BRANCH, obj[ kp, Q2_DEFAULE_BRANCH ])
}

function is_field_has_define(obj, kp){
    return ( obj[ kp ] != "" )
}

function is_field_null_or_false(obj, kp){
    return ( (obj[ kp] == "false") || (obj[ kp] == "null") || (obj[ kp] == "") )
}

function is_field_true_or_false(obj, kp){
    return ( (obj[ kp ] == "true") || (obj[ kp ] == "false") )
}