BEGIN{
    NO_COLOR = ENVIRON[ "NO_COLOR" ]
    if (NO_COLOR != 1) {
        UI_LEFT     = "\033[36m"
        UI_RIGHT    = "\033[32m"
        UI_POST     = "\033[33m"
        UI_END      = "\033[0m"
    }


    bitbucket_text  = ENVIRON[ "bitbucket_text" ]
    codeberg_text   = ENVIRON[ "codeberg_text" ]
    github_text     = ENVIRON[ "github_text" ]
    gitlab_text     = ENVIRON[ "gitlab_text" ]
    ssh_text        = ENVIRON[ "ssh_text" ]

    print_status("proxy for bitbucket http protocl", bitbucket_text)
    print_status("proxy for codeberg http protocl", codeberg_text)
    print_status("proxy for github http protocl", github_text)
    print_status("proxy for gitlab http protocl", gitlab_text)
    print_status("proxy for ssh protocl service provider", ssh_text)

}

function print_status( k, v,        indent ) {
    k = UI_LEFT k UI_END
    v = UI_RIGHT v UI_END
    if ( v ~ "\n" ) {
        v = UI_POST "|\n" UI_END v
        gsub( "\n", "\n  ", v )
    }
    printf( "%s: %s\n", k, v)
}