{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    X_envy_compile_kp       = ENVIRON[ "X_envy_compile_kp" ]
    X_envy_compile_perfix   = ENVIRON[ "X_envy_compile_perfix" ]
    X_envy_compile_local    = ENVIRON[ "X_envy_compile_local" ]
    X_envy_compile_override = ENVIRON[ "X_envy_compile_override" ]
    X_envy_compile_backup   = ENVIRON[ "X_envy_compile_backup" ]

    yml_parse( yml_text, o )
    envy_load( o, var, X_envy_compile_kp )

    print envy_gen_code( var, X_envy_compile_perfix, X_envy_compile_local, X_envy_compile_override, X_envy_compile_backup )
}
