{
    jiparse( o, $0 )
}

BEGIN{
    # "$WSROOT/.git/hooks/"
    if (GIT_HOOKS_DIR == "") exit_now("Please set the GITDIR.")
}

END{
    githook_gencode_hooks( o )
}

function githook_gencode_hooks( o,      i, k, h, l ){
    # githook_gencode_hook( o, "applypatch-msg" )

    # githook_gencode_hook( o, "commit-msg" )       # commitizen
    # githook_gencode_hook( o, "fsmonitor-watchman" )
    # githook_gencode_hook( o, "post-update" )

    # githook_gencode_hook( o, "pre-applypatch" )
    # githook_gencode_hook( o, "pre-commit" )
    # githook_gencode_hook( o, "pre-merge-commit" )

    # githook_gencode_hook( o, "pre-push" )
    # githook_gencode_hook( o, "pre-rebase" )
    # githook_gencode_hook( o, "pre-receive" )
    # githook_gencode_hook( o, "prepare-commit-msg" )

    # githook_gencode_hook( o, "push-to-checkout" )
    # githook_gencode_hook( o, "update" )

    k = "" SUBSEP "\"1\""
    l = o[ k L ]
    for (i=1; i<=l; ++i) {
        h = o[ k, i ]
        if (h == "\"pre-all-commit\"") {
            githook_gencode_hook_allcommit( o, h )
        } else {
            githook_gencode_hook( o, h )
        }
    }
}

function githook_gencode_hook( o, hookname,         l, i, m ){
    m = o[ "", "\"1\"", hookname ]

    if (m == "") return false

    f = GIT_HOOKS_DIR "/" juq(hookname)
    print juq(m) >f
    # print "chmod +x " f
}

function githook_gencode_hook_allcommit( o, hookname, l, i, m ){
    m = o[ SUBSEP "1" , hookname ]

    if (m == "") return false

    f = GIT_HOOKS_DIR "/pre-commit"
    print juq(m) >(GIT_HOOKS_DIR "/pre-commit")
    # print "chmod +x " f

    f = GIT_HOOKS_DIR "/pre-merge-commit"
    print juq(m) >(GIT_HOOKS_DIR "/pre-merge-commit")
    # print "chmod +x " f
}

