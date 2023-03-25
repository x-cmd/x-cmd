
BEGIN{
    # parse the environment  key
    arrl = split(ENVIRON["argstr"], arr, "\001")
    for (i=1; i<=arrl; ++i) {       # Notice: first line is empty
        e = arr[i]
        if (e ~ /^--/) {
            if (++i > arrl) exit_now(64)

            envkp[ ++l ]  = normalize_kp(substr(e, 3, length(e) - 2))
            envval[ l ] = jqu( arr[i] )
        } else {
            str_divide_( arr[i], "=" )
            envkp[ ++l ]  = normalize_kp(x_1)
            envval[ l ] = jqu( x_2 )
        }

        # PLAN: Add more op in the future, like abc+=3 ...
        # PLAN: Add yml parser so we can insert an yml object
    }
    envkp[ L ] = envval[ L ] = l
}

{ if ($0 != "") jiparse_after_tokenize(o, $0); }

END{
    if (EXIT_CODE != -1) exit(EXIT_CODE)

    l = envkp[ L ]
    for (i=1; i<=l; ++i) {
        kp = envkp[ i ]
        if (o[ kp ] == "") set_obj_data_structure_of_keypath(o, kp)
        o[ kp ] = envval[ i ]
    }
    print ystr(o)
}

