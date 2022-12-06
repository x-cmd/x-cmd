
function gt_repo_collaborator_admin_get( o, arr,        kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_ADMIN
    arr[L] = jlist_key_value2arr(o, kp, arr, Q2_ADMIN )
}

function gt_repo_collaborator_admin_add( o, username,          kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_ADMIN
    jlist_put(o, kp, username)
}

function gt_repo_collaborator_admin_rm( o, username,            kp ) {
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_ADMIN
    return jlist_rm( o, kp, username)
}

function gt_repo_collaborator_push_get( o, arr,        kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_PUSH
    arr[L] = jlist_key_value2arr(o, kp, arr, Q2_PUSH)
}

function gt_repo_collaborator_push_add( o, username,            kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_PUSH
    jlist_put(o, kp, username)
}

function gt_repo_collaborator_push_rm( o, username,            kp ) {
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_PUSH
    return jlist_rm( o, kp, username)
}

function gt_repo_collaborator_pull_get( o, arr,        kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_PULL
    arr[L] = jlist_key_value2arr(o, kp, arr, Q2_PULL)
}

function gt_repo_collaborator_pull_add( o, username,         kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_PULL
    jlist_put(o, kp, username)
}

function gt_repo_collaborator_pull_rm( o, username,            kp) {
    kp = SUBSEP Q2_1 SUBSEP Q2_COLLABORATOR SUBSEP Q2_PULL
    return jlist_rm( o, kp, username)
}

function gt_repo_get_collaborator_list( o, arr){
    gt_repo_collaborator_pull_get(o, arr)
    gt_repo_collaborator_push_get(o, arr)
    gt_repo_collaborator_admin_get(o, arr)
}

function modify_collaborator_level(           old, new, i, _kp_collaborator){
    _kp_collaborator = SUBSEP jqu(1) SUBSEP jqu("collaborator")
    if ( ! is_field_has_define( LOCAL_OBJ, _kp_collaborator) ) return false

    for (i in LOCAL_COLLABORATOR_LIST) {
        if ( i == L ) continue
        old = REMOTE_COLLABORATOR_LIST[ i ]
        new = LOCAL_COLLABORATOR_LIST[ i ]
        if (old == "")       gen_code_collaborator_add(i, new )
        else if (old != new) gen_code_collaborator_edit( i, new )
    }

    for (i in REMOTE_COLLABORATOR_LIST) {
        if ( i == L ) continue
        _kp = _kp_collaborator SUBSEP REMOTE_COLLABORATOR_LIST[i]
        if (( LOCAL_COLLABORATOR_LIST[ i ] == "" ) && is_field_has_define( LOCAL_OBJ, _kp )) gen_code_collaborator_rm(i)
    }
}

function gen_code_collaborator_add(username, role){
    COLLAB_ADD_STR = COLLAB_ADD_STR    "\n" sh_x("gt", "repo", "collaborator", "add", "--repo", LOCAL_REPO_NAME, "--permission", role, username)
}
function gen_code_collaborator_edit(username, role){
    COLLAB_EDIT_STR = COLLAB_EDIT_STR  "\n" sh_x("gt", "repo", "collaborator", "edit", "--repo", LOCAL_REPO_NAME, "--permission", role, username)
}
function gen_code_collaborator_rm(username){
    COLLAB_RM_STR = COLLAB_RM_STR      "\n" sh_x("gt", "repo", "collaborator", "rm", "--repo", LOCAL_REPO_NAME, "--yes", username)
}
