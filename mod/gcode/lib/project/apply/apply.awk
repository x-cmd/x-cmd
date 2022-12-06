# Section: Parse $@ member info
NR==1{  parse_replace_info($0); }
# EndSection

# Section: Parse local target yml info
# print jstr()
NR==2{
    jiparse_and_replace_field_after_tokenize( LOCAL_OBJ, $0 );       JITER_CURLEN = 0

    gcode_project_get_member_list( LOCAL_OBJ, LOCAL_COLLABORATOR_LIST )
    LOCAL_REPO_NAME           = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("project"))
    LOCAL_REPO_ACCESS         = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("visibility"))
    LOCAL_REPO_DEFAULT_BRANCH = arr_get( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("default_branch"))
}

# EndSection

# Section: Parse remote project member info

NR==3{
    gcode_api_init(REMOTE_OBJ)
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gcode_api_to_member(REMOTE_OBJ, _);    delete _

    gcode_project_get_member_list( REMOTE_OBJ, REMOTE_COLLABORATOR_LIST )
}

# EndSection

# Section: Parse remote project info

NR==4{
    jiparse_after_tokenize( _, $0 );    JITER_CURLEN = 0;
    gcode_api_to_name( REMOTE_OBJ, _)
    gcode_api_to_visibility( REMOTE_OBJ, _)
    gcode_api_to_default_branch( REMOTE_OBJ, _);   delete _

    REMOTE_REPO_NAME           = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("project"))
    REMOTE_REPO_ACCESS         = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("visibility"))
    REMOTE_REPO_DEFAULT_BRANCH = arr_get( REMOTE_OBJ, SUBSEP jqu(1) SUBSEP jqu("default_branch"))
}

# EndSection

# Section: Main: diff and generate code

END{
    if( LOCAL_REPO_NAME != REMOTE_REPO_NAME ) exit(1)
    modify_member_level()
    modify_visibility()
    modify_default_branch()

    print COLLAB_ADD_STR  COLLAB_EDIT_STR  COLLAB_RM_STR   ACCESS_STR  DEFAULT_BRANCH_STR
    # print jstr(LOCAL_OBJ)
}


function modify_visibility(){
    if ( ! is_field_has_define( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("visibility")) ) return
    if (LOCAL_REPO_ACCESS != REMOTE_REPO_ACCESS) ACCESS_STR = "\n" sh_x("gcode", "project", "edit", "--visibility", LOCAL_REPO_ACCESS, LOCAL_REPO_NAME)

}

function modify_default_branch(){
    if ( ! is_field_has_define( LOCAL_OBJ, SUBSEP jqu(1) SUBSEP jqu("default_branch")) ) return
    if(LOCAL_REPO_DEFAULT_BRANCH != REMOTE_REPO_DEFAULT_BRANCH) DEFAULT_BRANCH_STR = "\n" sh_x("gcode", "project", "edit", "--default_branch", LOCAL_REPO_DEFAULT_BRANCH, LOCAL_REPO_NAME)

}

# EndSection
