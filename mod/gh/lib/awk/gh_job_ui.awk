function use_ui_truefalse(status, text, indent){
    print "___X_CMD_UI_TF_INDENT=\"" indent "\" x ui tf " status " " text ": ;"
}

function handle(_kp, key, indent,      i, l, n, id){
    _kp = _kp kp(key)
    l = O[ _kp L]
    for (i=1; i<=l; ++i){
        n = juq( O[ _kp kp(i, "name")] )
        id = ( id=O[ _kp kp(i, "id") ] ) ? " (JOB_ID " id ")" : ""
        use_ui_truefalse( O[ _kp kp(i, "conclusion") ], jqu( n id ), indent )
        handle( _kp S jqu(i), "steps", indent "  " )
    }
}
END{
    print "printf \"%s %s:\\n\"" " " O[ kp(1, "jobs", 1, "head_branch")] " " O[ kp(1, "jobs", 1, "workflow_name") ] ";"
    handle(kp(1), "jobs", indent)
}
