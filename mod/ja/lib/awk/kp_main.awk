{
    ___X_CMD_JA_AWK_KP_MAIN_STATE = 1 - ___X_CMD_JA_AWK_KP_MAIN_STATE
    if (___X_CMD_JA_AWK_KP_MAIN_STATE == 0) {
        V = $0
        _v_reset = 0
    } else {
        KP = $0
        D = split(KP, O, "\001")
        K = O[ D ]
        _k_reset = 0
        next
    }
}