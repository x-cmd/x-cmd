{
    jiparse( o, $0 )
}

END{

    root = SUBSEP jqu(1)

    rm_profile_name = ENVIRON["rm_profile_name"]
    rm_profile_name_jqu = jqu( rm_profile_name )

    root = root SUBSEP jqu("profile")
    if (( l = o[ root L ] ) == "") l = 0
    for (i=1; i<=l; ++i) {
        if (o[ root, jqu(i), jqu("name") ] == rm_profile_name_jqu) {
            jlist_rm_idx( o, root, i )
            # when remove the profile
            # if the profile is the current profile
            # then set the current profile to the first profile
            # If no profile, then set the current profile to ""
            current_name = o[ SUBSEP jqu(1), jqu("current") ]
            if ( rm_profile_name_jqu == current_name ) {
                next_current_name = o[ root, jqu(1), jqu("name") ]
                jdict_put( o, SUBSEP jqu(1), jqu("current"), next_current_name )
            }

            print jstr( o )
            exit(0)
        }
    }

    exit(1)
}
