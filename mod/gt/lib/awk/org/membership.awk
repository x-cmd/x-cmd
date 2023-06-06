
function gt_org_membership_admin_get( o, arr,        kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBERSHIP SUBSEP Q2_ADMIN
    arr[L] = jlist_key_value2arr(o, kp, arr, Q2_ADMIN)
}

function gt_org_membership_admin_add( o, username,          kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBERSHIP SUBSEP Q2_ADMIN
    jlist_put(o, kp, username)
}

function gt_org_membership_admin_rm( o, username,            kp ) {
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBERSHIP SUBSEP Q2_ADMIN
    return jlist_rm_value( o, kp, username)
}

function gt_org_membership_member_get( o, arr,        kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBERSHIP SUBSEP Q2_MEMBER
    arr[L] = jlist_key_value2arr(o, kp, arr, Q2_MEMBER)
}

function gt_org_membership_member_add( o, username,            kp ){
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBERSHIP SUBSEP Q2_MEMBER
    jlist_put(o, kp, username)
}

function gt_org_membership_member_rm( o, username,            kp ) {
    kp = SUBSEP Q2_1 SUBSEP Q2_MEMBERSHIP SUBSEP Q2_MEMBER
    return jlist_rm_value( o, kp, username)
}


function gt_org_get_membership_list( o, arr){
    gt_org_membership_admin_get(o, arr)
    gt_org_membership_member_get(o, arr)
}

function modify_membership_level(           old, new, i, _kp_membership){
    _kp_membership = SUBSEP jqu(1) SUBSEP jqu("membership")
    if ( ! is_field_has_define( LOCAL_OBJ, _kp_membership) ) return false

    for (i in LOCAL_MEMBERSHIP_LIST) {
        if ( i == L ) continue
        old = REMOTE_MEMBERSHIP_LIST[ i ]
        new = LOCAL_MEMBERSHIP_LIST[ i ]
        if (old == "")       gen_code_membership_add(i, new )
        else if (old != new) gen_code_membership_edit( i, new )
    }

    for (i in REMOTE_MEMBERSHIP_LIST) {
        if ( i == L ) continue
        _kp = _kp_membership SUBSEP REMOTE_MEMBERSHIP_LIST[i]
        if (( LOCAL_MEMBERSHIP_LIST[ i ] == "" ) && is_field_has_define( LOCAL_OBJ, _kp )) gen_code_membership_rm(i)
    }
}

function gen_code_membership_add(username, role){
    MEMBER_ADD_STR = MEMBER_ADD_STR   "\n" sh_x("gt", "org", "membership", "add", "--org", LOCAL_ORG_NAME, "--permission", role, username)
}
function gen_code_membership_edit(username, role){
    MEMBER_EDIT_STR = MEMBER_EDIT_STR "\n" sh_x("gt", "org", "membership", "edit", "--org", LOCAL_ORG_NAME, "--permission", role, username)
}
function gen_code_membership_rm(username){
    MEMBER_RM_STR = MEMBER_RM_STR     "\n" sh_x("gt", "org", "membership", "rm", "--org", LOCAL_ORG_NAME, "--yes", username)
}
