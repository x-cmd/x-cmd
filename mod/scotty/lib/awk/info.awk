BEGIN{
    NO_COLOR = ENVIRON[ "NO_COLOR" ]
    if ( NO_COLOR != 1 ) {
        UI_KEY = "\033[1;34m"
        UI_VAL = "\033[1;32m"
        UI_END = "\033[0m"
    }

    stdout_yml_info( "x-cmd",   ENVIRON[ "_v_x_cmd" ] )
    stdout_yml_info( "shell",   ENVIRON[ "_v_shell" ] )
    stdout_yml_info( "awk",     ENVIRON[ "_v_awk" ] )
    stdout_yml_info( "sed",     ENVIRON[ "_v_sed" ] )
    stdout_yml_info( "grep",    ENVIRON[ "_v_grep" ] )
    stdout_yml_info( "find",    ENVIRON[ "_v_find" ] )
    stdout_yml_info( "busybox", ENVIRON[ "_v_busybox" ] )
    stdout_yml_info( "curl",    ENVIRON[ "_v_curl" ] )
    stdout_yml_info( "wget",    ENVIRON[ "_v_wget" ] )
    stdout_yml_info( "yq",      ENVIRON[ "_v_yq" ] )
    stdout_yml_info( "jq",      ENVIRON[ "_v_jq" ] )
    stdout_yml_info( "fzf",      ENVIRON[ "_v_fzf" ] )
    stdout_yml_info( "release", ENVIRON[ "_v_release" ] )
}

function stdout_yml_info( name, info,       kp ){
    printf("- %sname%s: %s%s%s\n", UI_KEY, UI_END, UI_VAL, name, UI_END)
    if ( info ~ "\n" ) {
        info = "|-\n" info
        gsub( "\n", "\n    ", info )
    } else if ( info ~ ":" ) {
        info = jqu(info)
    }

    print "  " UI_KEY "info" UI_END ": " UI_VAL info UI_END
}

