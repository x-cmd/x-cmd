

function diff_review(           kp, i){
    kp = SUBSEP jqu(1) SUBSEP jqu("reviewer")

    if ( ! is_field_has_define( LOCAL_OBJ, kp) ) return false

    if ( is_field_has_define( LOCAL_OBJ, kp SUBSEP jqu("assignee")) ) {
        if ( LOCAL_ASSIGNEE_LIST[ L ] != REMOTE_ASSIGNEE_LIST[ L ] ) return true
        for(i in LOCAL_ASSIGNEE_LIST)  if ( LOCAL_ASSIGNEE_LIST[ i ] != REMOTE_ASSIGNEE_LIST[ i ] )    return true
    }

    if ( is_field_has_define( LOCAL_OBJ, kp SUBSEP jqu("tester")) ) {
        if (LOCAL_TESTER_LIST[ L ] != REMOTE_TESTER_LIST[ L ] ) return true
        for(i in LOCAL_TESTER_LIST)    if ( LOCAL_TESTER_LIST[ i ] != REMOTE_TESTER_LIST[ i ] )        return true
    }

    return false
}


function gen_code_review(           kp, _assignee_str, _tester_str){
    kp = SUBSEP jqu(1) SUBSEP jqu("reviewer")
    if ( is_field_has_define( LOCAL_OBJ, kp SUBSEP jqu("assignee")) )   _assignee_str = gt_repo_review_get_str( LOCAL_ASSIGNEE_LIST )
    else _assignee_str = gt_repo_review_get_str( REMOTE_ASSIGNEE_LIST )

    if ( is_field_has_define( LOCAL_OBJ, kp SUBSEP jqu("tester")) )     _tester_str = gt_repo_review_get_str( LOCAL_TESTER_LIST )
    else _tester_str = gt_repo_review_get_str( REMOTE_TESTER_LIST )

    REVIEWER = "\n" sh_x("gt", "repo", "pr", "set", "--repo", LOCAL_REPO_NAME, "--assignees", _assignee_str, "--testers", _tester_str)
}

function gt_repo_review_assignee_get( o, arr,         kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_REVIEWER SUBSEP Q2_ASSIGNEE
    arr[L] = jlist_key_value2arr(o, kp, arr, true)
}

function gt_repo_review_assignee_add( o, username,          kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_REVIEWER SUBSEP Q2_ASSIGNEE
    jlist_put(o, kp, username)
}

function gt_repo_review_assignee_rm(o, username,            kp) {
    kp = SUBSEP Q2_1 SUBSEP Q2_REVIEWER SUBSEP Q2_ASSIGNEE
    return jlist_rm_value(o, kp, username)
}

function gt_repo_review_tester_get( o, arr,       kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_REVIEWER SUBSEP Q2_TESTER
    arr[L] = jlist_key_value2arr(o, kp, arr, true)
}

function gt_repo_review_tester_add( o, username,          kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_REVIEWER SUBSEP Q2_TESTER
    jlist_put(o, kp, username)
}

function gt_repo_review_tester_rm(o, username,          kp) {
    kp = SUBSEP Q2_1 SUBSEP Q2_REVIEWER SUBSEP Q2_TESTER
    return jlist_rm_value(o, kp, username)
}

function gt_repo_review_get_str(arr,       str, i) {
    for ( i in arr ) if ( i != L ) str = (( str != "" ) ? str "," : "" ) juq( i )
    return jqu(str)
}
