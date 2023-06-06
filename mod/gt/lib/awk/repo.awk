
BEGIN{
    Q2_1 = "\"" 1 "\""
    Q2_REPO = "\"repo\""
    Q2_COLLABORATOR = "\"collaborator\""
    Q2_ADMIN = "\"admin\""
    Q2_PUSH = "\"push\""
    Q2_PULL = "\"pull\""

    Q2_REVIEWER = "\"reviewer\""
    Q2_TESTER = "\"tester\""
    Q2_TESTERS = "\"testers\""
    Q2_ASSIGNEE = "\"assignee\""

    Q2_ACCESS = "\"access\""
    Q2_PUBLIC = "\"public\""
    Q2_PRIVATE = "\"private\""

    Q2_LOGIN = "\"login\""
    Q2_NAME = "\"name\""
    Q2_FULL_NAME = "\"full_name\""
    Q2_DEFAULE_BRANCH = "\"default_branch\""
}

# Section: YML => json ==(PARSE)==> o

# Section: parse: api.json => o


function gt_api_init(o){
    jdict_put(o, "", Q2_1, "{")
}

function gt_api_to_collaborator( o, obj,            kp, _kp_collaborator, _kp_permission, l, i, n ){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_COLLABORATOR, "{")

    _kp_collaborator = kp SUBSEP Q2_COLLABORATOR
    jdict_put(o, _kp_collaborator, Q2_ADMIN, "[")
    jdict_put(o, _kp_collaborator, Q2_PUSH, "[")
    jdict_put(o, _kp_collaborator, Q2_PULL, "[")


    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        n = obj[ kp, jqu(i), Q2_LOGIN ]
        _kp_permission = kp SUBSEP jqu(i) SUBSEP jqu("permissions")

        if ( obj[ _kp_permission, Q2_ADMIN ] == "true" ) {
            gt_repo_collaborator_admin_add( o, n )
            continue
        }
        if ( obj[ _kp_permission, Q2_PUSH ] == "true" ) {
            gt_repo_collaborator_push_add( o, n )
            continue
        }
        if ( obj[ _kp_permission, Q2_PULL ] == "true" ) {
            gt_repo_collaborator_pull_add( o, n )
            continue
        }
    }

}

function gt_api_to_review( o, obj,            _kp, kp, _kp_reviewr, l, i ){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_REVIEWER, "{")

    _kp_reviewr = kp SUBSEP Q2_REVIEWER
    jdict_put(o, _kp_reviewr, Q2_ASSIGNEE, "[")
    jdict_put(o, _kp_reviewr, Q2_TESTER, "[")


    _kp = kp SUBSEP Q2_ASSIGNEE
    l = obj[ _kp L ]
    for (i=1; i<=l; ++i) gt_repo_review_assignee_add( o, obj[ _kp, jqu(i), Q2_LOGIN ] )

    _kp = kp SUBSEP Q2_TESTERS
    l = obj[ _kp L ]
    for (i=1; i<=l; ++i) gt_repo_review_tester_add( o, obj[ _kp, jqu(i), Q2_LOGIN ] )

}

function gt_api_to_repo(o, obj,         kp){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_REPO, obj[ kp, Q2_FULL_NAME ])
}

function gt_api_to_access(o, obj,       kp){
    kp = SUBSEP Q2_1
    if ( obj[ kp, Q2_PRIVATE ] == "true" ) return jdict_put(o, kp, Q2_ACCESS, Q2_PRIVATE)
    if ( obj[ kp, Q2_PUBLIC ] == "true" ) return jdict_put(o, kp, Q2_ACCESS, Q2_PUBLIC )
}

function gt_api_to_default_branch(o, obj,       kp){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_DEFAULE_BRANCH, obj[ kp, Q2_DEFAULE_BRANCH ])
}

function gt_api_to_push( o, obj,        kp, l, i, k, _kp_push){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_PUSH, "{")

    _kp_push = kp SUBSEP Q2_PUSH
    l = obj[ kp L ]
    for(i=1; i<=l; ++i){
        k = obj[ kp, i ]
        jdict_put(o, _kp_push, k, obj[ kp, k ])
    }
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