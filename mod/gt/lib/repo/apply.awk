
# Section: Parse $@ collaborator info
NR==1{
    if( $0 == "\001\002\003" ) exit(1)
    parse_replace_info($0, REPLACE_OBJ)
}
# EndSection

# Section: Parse local target yml info

NR==2{
    jiparse_after_tokenize( LOCAL_OBJ, $0 );       JITER_CURLEN = 0
    apply_fields_replace( LOCAL_OBJ, REPLACE_OBJ )

    if( is_field_has_define( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("xrc") ) ) { print "\033[31mCurrent only *.yml declare configure support xrc option field\033[0m" >"/dev/stderr"; exit(1) }

    gt_repo_get_collaborator_list( LOCAL_OBJ, LOCAL_COLLABORATOR_LIST )
    gt_repo_review_assignee_get( LOCAL_OBJ, LOCAL_ASSIGNEE_LIST )
    gt_repo_review_tester_get( LOCAL_OBJ, LOCAL_TESTER_LIST )
    gt_repo_push_get( LOCAL_OBJ, LOCAL_PUSH )

    LOCAL_REPO_NAME           = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("repo"))
    LOCAL_REPO_ACCESS         = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("access"))
    LOCAL_REPO_DEFAULT_BRANCH = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("default_branch"))
}

# EndSection

# Section: Parse remote repo collaborator info

NR==3{
    gt_api_init(REMOTE_OBJ)
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gt_api_to_collaborator(REMOTE_OBJ, _);    delete _

    gt_repo_get_collaborator_list( REMOTE_OBJ, REMOTE_COLLABORATOR_LIST )

}

# EndSection

# Section: Parse remote repo info

NR==4{
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gt_api_to_repo( REMOTE_OBJ, _)
    gt_api_to_review( REMOTE_OBJ, _)
    gt_api_to_access( REMOTE_OBJ, _)
    gt_api_to_default_branch( REMOTE_OBJ, _);   delete _

    gt_repo_review_assignee_get( REMOTE_OBJ, REMOTE_ASSIGNEE_LIST )
    gt_repo_review_tester_get( REMOTE_OBJ, REMOTE_TESTER_LIST )

    REMOTE_REPO_NAME           = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("repo"))
    REMOTE_REPO_ACCESS         = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("access"))
    REMOTE_REPO_DEFAULT_BRANCH = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("default_branch"))
}

# EndSection

# Section: Parse remote repo push info

NR==5{
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gt_api_to_push( REMOTE_OBJ, _);   delete _
    gt_repo_push_get( REMOTE_OBJ, REMOTE_PUSH )
}

# EndSection

# Section: Main: diff and generate code

END{
    if( LOCAL_REPO_NAME != REMOTE_REPO_NAME ) exit(1)
    modify_collaborator_level()
    modify_push()
    modify_access()
    modify_default_branch()
    if (diff_review()) gen_code_review()

    print COLLAB_ADD_STR  COLLAB_EDIT_STR  COLLAB_RM_STR   REVIEWER  PUSH_STR  ACCESS_STR  DEFAULT_BRANCH_STR
    # print jstr(REMOTE_OBJ)
}


function modify_access(){
    if ( ! is_field_has_define( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("access")) ) return
    if (LOCAL_REPO_ACCESS != REMOTE_REPO_ACCESS) ACCESS_STR = "\n" sh_x("gt", "repo", "edit", "--access", LOCAL_REPO_ACCESS, LOCAL_REPO_NAME)
}

function modify_default_branch(){
    if ( ! is_field_has_define( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("default_branch")) ) return
    if(LOCAL_REPO_DEFAULT_BRANCH != REMOTE_REPO_DEFAULT_BRANCH) DEFAULT_BRANCH_STR = "\n" sh_x("gt", "repo", "edit", "--default_branch", LOCAL_REPO_DEFAULT_BRANCH, LOCAL_REPO_NAME)
}

# EndSection
