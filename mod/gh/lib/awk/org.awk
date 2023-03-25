
BEGIN{
    Q2_1 = "\"" 1 "\""
    Q2_MEMBERSHIP = "\"membership\""
    Q2_ADMIN = "\"admin\""
    Q2_MEMBER = "\"member\""

    Q2_LOGIN = "\"login\""
    Q2_NAME = "\"name\""
}

# Section: YML => json ==(PARSE)==> o

# Section: parse: api.json => o


function gh_api_init(o){
    jdict_put(o, "", Q2_1, "{")
}

function gh_api_to_membership( o, obj, role,            kp, _kp_membership, _kp_permission, l, i, n ){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_MEMBERSHIP, "{")

    _kp_membership = kp SUBSEP Q2_MEMBERSHIP
    jdict_put(o, _kp_membership, role, "[")

    l = obj[ kp L ]
    for (i=1; i<=l; ++i){
        n = obj[ kp, jqu(i), Q2_LOGIN ]

        if ( role == Q2_ADMIN ) {
            gh_org_membership_admin_add( o, n )
            continue
        }
        if ( role == Q2_MEMBER ) {
            gh_org_membership_member_add( o, n )
            continue
        }
    }

}

function gh_api_to_name(o, obj,         kp){
    kp = SUBSEP Q2_1
    jdict_put(o, kp, Q2_NAME, obj[ kp, Q2_LOGIN ])
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

