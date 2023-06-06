{
    jiparse( o, $0 )
}

END{
    gitconfig_gencode_config( o, SUBSEP "\"1\"" )
}

function gitconfig_gencode_config( o, kp, config_key,     l, i, k, v, _ck ) {
    l = o[ kp L ]
    config_key = (config_key == "") ? "" : (config_key ".")
    for (i=1; i<=l; ++i) {
        k = o[ kp, i ]
        v = o[ kp, k ]
        if (v == "{") {
            gitconfig_gencode_config( o, kp SUBSEP k, config_key juq(k) )
        } else if (v == "[") {
            exit_now("Error happened.")
        } else {
            printf("git config --local %s %s\n", config_key juq(k), v)
        }
    }
}
