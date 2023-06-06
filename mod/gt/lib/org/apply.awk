
# Section: Parse $@ membership info
NR==1{  parse_replace_info($0); }
# EndSection

# Section: Parse local target yml info

NR==2{
    jiparse_and_replace_field_after_tokenize( LOCAL_OBJ, $0 );       JITER_CURLEN = 0

    gt_org_get_membership_list( LOCAL_OBJ, LOCAL_MEMBERSHIP_LIST )

    LOCAL_ORG_NAME           = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("org"))
}

# EndSection

# Section: Parse remote org info

NR==3{
    gt_api_init(REMOTE_OBJ)
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gt_api_to_name( REMOTE_OBJ, _);     delete _

    REMOTE_ORG_NAME           = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("name"))
}

# EndSection

# Section: Parse remote org membership info

NR==4{
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gt_api_to_membership(REMOTE_OBJ, _);    delete _

    gt_org_get_membership_list( REMOTE_OBJ, REMOTE_MEMBERSHIP_LIST )

}

# EndSection

# Section: Main: diff and generate code

END{
    if( LOCAL_ORG_NAME != REMOTE_ORG_NAME ) exit(1)
    modify_membership_level()

    print MEMBER_ADD_STR MEMBER_EDIT_STR MEMBER_RM_STR
}
# EndSection
