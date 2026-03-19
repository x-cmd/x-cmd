BEGIN{
    if ( url ~ "^cask") IS_CASK = 1
    else IS_CASK = 0
    KP = SUBSEP "\"1\""
}

END{
    catagory = juq(O[ KP S "\"category\""])
    total_items = juq(O[ KP S "\"total_items\""])
    start_date = juq(O[ KP S "\"start_date\""])
    end_date = juq(O[ KP S "\"end_date\""])
    total_count = juq(O[ KP S "\"total_count\""])

    formulae_l = O[ KP S "\"formulae\"" L]


    for(i=1; i<=formulae_l; ++i){
        key = O[ KP S "\"formulae\"" S "\""i"\"" ]
        formulae_len = O[ KP S "\"formulae\"" S key L]

        for(j=1; j<=formulae_len; ++j){
            formulae_kp = KP S "\"formulae\"" S key S "\""j"\""
            if ( IS_CASK == 1)  formula = O[ formulae_kp S "\"cask\""]
            else                formula = O[ formulae_kp S "\"formula\""]
            count = O[ formulae_kp S "\"count\""]
            gsub(",", "", count)
            print formula"," count
        }
    }
    # printf("[total_items: %s],[total_count: %s]\n", total_items, total_count)
}
