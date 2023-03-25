

function l_push( o, kp, e ){
    o[ kp ] = e
}

function l_get( o, kp, k ){
    return o[ kp, k ]
}

function l_len( o, kp ){
    return o[ kp L ]
}

function l_add(o, kp, v){

}

function l_diff(o, kp, o2, kp2, a, d, m){

}

function gt_repo_member_add(a){

}

function d_put(o, kp, k, v) {
    o[ kp, k ] = v
}

function d_rm(o, kp, k){
    if (o[ kp, k ]) {

    }
}

function o_gen_code(){

}

function o_main( o, kp ){
    o[ kp, 1 ] = 1
    o[ kp, 2 ] = 2
    o[ kp, 3 ] = 3

    ABC_K="abc"

    d_put(o, ABC_K,     k, v )
    d_put(o, ABC_K,     k, v )

    GT_MEMBER = "\"repo\"" SUBSEP "\"member\""

    gt_repo_member_add("ljh")
    l_add(gt,REPO_MEMBER, "ljh")
    l_add(gt,REPO_MEMBER, "el")
    l_add(gt,REPO_MEMBER, "l")

    l_diff(gt,REPO_MEMBER,  local,REPO_MEMBER,      add, del, mod)

}
