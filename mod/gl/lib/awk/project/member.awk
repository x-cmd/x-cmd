
function gl_project_member_get(o, arr, tmp_list,        l,a,kp ){
   l = split(tmp_list, a, ",")
    for (i=1; i<=l; ++i){
        kp = SUBSEP Q2_1 SUBSEP Q2_MEMBER SUBSEP  "\""a[i]"\""
        arr[L] = jlist_key_value2arr(o, kp, arr, "\""a[i]"\"")
    }
}

function gl_project_member_add( o, username, access,          kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBER SUBSEP access
    jlist_put(o, kp, username)
}

function gl_project_member_rm( o, username, access,          kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBER SUBSEP access
    return jlist_rm_value( o, kp, username)
}

function gl_project_get_member_list( o, arr){
    gl_project_member_get(o,arr,"owner,maintainer,developer,reporter,guest")
}

function modify_member_level(           old, new, i, _kp_member){
    _kp_member = SUBSEP jqu(1) SUBSEP jqu("member")
    if ( ! is_field_has_define( LOCAL_OBJ, _kp_member) ) return false
    for (i in LOCAL_COLLABORATOR_LIST) {
        if ( i == L ) continue
        old = REMOTE_COLLABORATOR_LIST[ i ]
        new = LOCAL_COLLABORATOR_LIST[ i ]
        if (old == "")       gen_code_member_add(i, new )
        else if (old != new) gen_code_member_edit( i, new )
    }

    for (i in REMOTE_COLLABORATOR_LIST) {
        if ( i == L ) continue
        _kp = _kp_member SUBSEP REMOTE_COLLABORATOR_LIST[i]
        if (( LOCAL_COLLABORATOR_LIST[ i ] == "" ) && is_field_has_define( LOCAL_OBJ, _kp )) gen_code_member_rm(i)
    }
}

function gen_code_member_add(username, role){
    COLLAB_ADD_STR = COLLAB_ADD_STR    "\n" sh_x("gl", "project", "member", "add", "--project", LOCAL_REPO_NAME, "--access_level", role, username)
}
function gen_code_member_edit(username, role){
    COLLAB_EDIT_STR = COLLAB_EDIT_STR  "\n" sh_x("gl", "project", "member", "edit", "--project", LOCAL_REPO_NAME, "--access_level", role, username)
}
function gen_code_member_rm(username){
    COLLAB_RM_STR = COLLAB_RM_STR      "\n" sh_x("gl", "project", "member", "rm", "--project", LOCAL_REPO_NAME, "--yes", username)
}
