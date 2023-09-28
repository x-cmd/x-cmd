BEGIN{
    if (group != "") EMOJI_MODE = "group"
    else             EMOJI_MODE = "all"

}

{
    LINE = $0
    if (EMOJI_MODE == "all") {
        if (LINE ~ "^#" ) {
            if (LINE ~ "^# group:")         group_name = emoji_get_group_name(LINE)
            else if (LINE ~ "^# subgroup:") subgroup_name = emoji_get_subgroup_name(LINE)
            next
        }
    }
    else {
        if (FOUND_GROUP == 0) {
            if (LINE !~ "^# group:") next
            group_name = emoji_get_group_name(LINE)
            if( group_name ~ group ) {
                log_info( "emoji", "Display group => " group_name )
                FOUND_GROUP = 1
            }
            next
        }
        else {
            if ( subgroup == "" ) {
                if (LINE ~ "^# " ) {
                    if (LINE ~ "^# subgroup:") subgroup_name = emoji_get_subgroup_name(LINE)
                    else if (LINE ~ "^# .*subtotal:") exit
                    next
                }
            }
            else {
                if (FOUND_SUBGROUP == 0){
                    if (LINE !~ "# subgroup:.*") next
                    subgroup_name = emoji_get_subgroup_name(LINE)
                    if( subgroup_name ~ subgroup ) {
                        log_info( "emoji", "Display subgroup => " subgroup_name )
                        FOUND_SUBGROUP = 1
                    }
                    next
                }
                else {
                    if ((LINE ~ "^# subgroup:") || (LINE ~ "^# .*subtotal:")) exit
                }
            }
        }

    }

    # match

    # to json
    if (LINE == "") next
    print emoji_gen_str(LINE, group_name, subgroup_name)
    fflush()
}

function emoji_get_group_name(str){
    sub("^# group: ", "", str)
    return tolower(str_trim(str))
}

function emoji_get_subgroup_name(str){
    sub("^# subgroup: ", "", str)
    return tolower(str_trim(str))
}

function emoji_gen_str(str, group, subgroup,          unicode, desc, emoji, status, version){
    unicode  = jqu( str_trim(substr(str, 1, index(str, "  ")) ))

    match(str,"#.*E[0-9]")
    emoji = substr( str, RSTART, RLENGTH )
    gsub("^#| E[0-9]", "", emoji)
    emoji = jqu( str_trim(emoji))

    match(str,"; .*[ ]+#")
    status = jqu( str_trim(substr(str, RSTART+2,RLENGTH-3) ))

    match(str,"E[0-9]+[.][0-9]+ .*")
    version_desc = substr(str, RSTART,RLENGTH)
    version = jqu(substr(version_desc, 1,index(version_desc," ")-1))
    desc = jqu(substr(version_desc, index(version_desc," ")+1))
    group = jqu(group)
    subgroup = jqu(subgroup)

    return sprintf("{ \"unicode\" : %s , \"desc\" : %s , \"emoji\" : %s , \"status\" : %s , \"version\" : %s , \"group\" : %s , \"subgroup\" : %s }", \
        unicode, desc, emoji, status, version, group, subgroup )
}

