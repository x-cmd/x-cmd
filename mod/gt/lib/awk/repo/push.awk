
function diff_push(         i){
    for( i in LOCAL_PUSH ) if ( is_field_has_define(LOCAL_PUSH, i) && ( LOCAL_PUSH[i] != REMOTE_PUSH[i] ) ) return true
    return false
}

function modify_push(          i, str){
    for(i in LOCAL_PUSH) {
        if ( LOCAL_PUSH[i] == "true" ) str = str " --" juq(i)
        else if ( ! is_field_null_or_false(LOCAL_PUSH, i)) str = str " --" juq(i) " " LOCAL_PUSH[i]
    }

    if ( diff_push() ) PUSH_STR = "\n" sh_x("gt", "repo", "push", "set", "--repo", LOCAL_REPO_NAME, str)
}

function gt_repo_push_get(o, arr,       kp, l, i, k){
    kp = SUBSEP Q2_1 SUBSEP Q2_PUSH
    l = arr_len( o, kp )
    for(i=1; i<=l; ++i){
        k = arr_get( o, kp SUBSEP i )
        arr[ k ] = arr_get( o, kp SUBSEP k )
    }
}