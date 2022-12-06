
BEGIN{
    Q2_1 = "\"" 1 "\""
    Q2_MEMBERSHIP = "\"membership\""
    Q2_ADMIN = "\"admin\""
    Q2_MEMBER = "\"member\""

    Q2_LOGIN = "\"login\""
    Q2_NAME = "\"name\""
    Q2_FULL_NAME = "\"full_name\""
}

# Section: YML => json ==(PARSE)==> o

# Section: parse: api.json => o


function gt_api_init(o){
    jdict_put(o, "", Q2_1, "{")
}

function gt_api_to_membership( o, obj,            kp, _kp_membership, _kp_permission, l, i, n ){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_MEMBERSHIP, "{")

    _kp_membership = kp SUBSEP Q2_MEMBERSHIP
    jdict_put(o, _kp_membership, Q2_ADMIN, "[")
    jdict_put(o, _kp_membership, Q2_MEMBER, "[")

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        n = obj[ kp, jqu(i), Q2_LOGIN ]
        _kp_permission = kp SUBSEP jqu(i) SUBSEP jqu("member_role")

        if ( obj[ _kp_permission ] == Q2_ADMIN ) {
            gt_org_membership_admin_add( o, n )
            continue
        }
        if ( obj[ _kp_permission ] == Q2_MEMBER ) {
            gt_org_membership_member_add( o, n )
            continue
        }
    }

}

function gt_api_to_name(o, obj,         kp){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_NAME, obj[ kp, Q2_NAME ])
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