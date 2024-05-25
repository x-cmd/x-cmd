BEGIN{
    Q2_1 = SUBSEP "\"1\""
    o[ L ] = 1
    o[ Q2_1 ] = "["
    # jlist_put( o, "", "[" )

    _v_x_cmd    = ENVIRON[ "_v_x_cmd" ]
    _v_shell    = ENVIRON[ "_v_shell" ]
    _v_awk      = ENVIRON[ "_v_awk" ]
    _v_sed      = ENVIRON[ "_v_sed" ]
    _v_grep     = ENVIRON[ "_v_grep" ]
    _v_find     = ENVIRON[ "_v_find" ]
    _v_busybox  = ENVIRON[ "_v_busybox" ]
    _v_release  = ENVIRON[ "_v_release" ]

    add_info( o, "x-cmd",   ENVIRON[ "_v_x_cmd" ] )
    add_info( o, "shell",   ENVIRON[ "_v_shell" ] )
    add_info( o, "awk",     ENVIRON[ "_v_awk" ] )
    add_info( o, "sed",     ENVIRON[ "_v_sed" ] )
    add_info( o, "grep",     ENVIRON[ "_v_grep" ] )
    add_info( o, "find",     ENVIRON[ "_v_find" ] )
    add_info( o, "busybox",     ENVIRON[ "_v_busybox" ] )
    add_info( o, "release",     ENVIRON[ "_v_release" ] )


    print jstr(o)

}

function add_info( o, name, info,       kp ){
    jlist_put( o, Q2_1, "{" )
    kp = Q2_1 SUBSEP "\"" o[ Q2_1 L ] "\""
    jdict_put( o, kp, "\"name\"", jqu(name) )
    jdict_put( o, kp, "\"info\"", jqu(info) )
}

