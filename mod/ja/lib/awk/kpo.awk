BEGIN {
    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
    S = SUBSEP
    T = "\002"
    L = "\003"
}

# Section: jiter
# function jiter_init( keypath_prefix ) {
BEGIN {
    JITER_FA_KEYPATH    = keypath_prefix
    JITER_STATE         = T_ROOT
    JITER_LAST_KP       = ""
    depth                   = 0
    JITER_CURLEN        = 0

    JITER_OFFSET_FULLKP = 10000
}

function jiter( item,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/) #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {    # handle <primitive value> inside {}
            _res = JITER_FA_KEYPATH S JITER_LAST_KP
            O[ depth ] = JITER_LAST_KP
            O[ _res ] = item
            key = JITER_LAST_KP
            JITER_LAST_KP = ""
            return _res
        }
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != "{" ) {
            _res = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
            O[ depth ] = JITER_CURLEN
            O[ _res ] = item
            key = JITER_CURLEN
            return _res
        }
        O[ depth ] = item       # handle <key> inside {}
        O[ JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" ] = item
        JITER_LAST_KP = item
        # return JITER_FA_KEYPATH S JITER_CURLEN
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != "{" ) {
            JITER_CURLEN = JITER_CURLEN + 1
            O[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
            O[ depth ++ ] = JITER_CURLEN
            key = JITER_CURLEN
        } else {
            O[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            O[ ++ depth ] = JITER_LAST_KP   # Notice: Not ++ depth. `O[ depth ] = item` been done during key processing.
            key = JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        O[ JITER_FA_KEYPATH ] = item
        O[ depth + JITER_OFFSET_FULLKP ] = JITER_FA_KEYPATH
        return JITER_FA_KEYPATH
    } else {
        O[ JITER_FA_KEYPATH L ] = JITER_CURLEN
        _res = JITER_FA_KEYPATH
        O[ depth -- ] = ""
        key = O[ depth ]
        JITER_FA_KEYPATH = O[ depth + JITER_OFFSET_FULLKP ]
        JITER_STATE = O[ JITER_FA_KEYPATH ]
        JITER_CURLEN = O[ JITER_FA_KEYPATH L ]
        return _res
    }
    return ""
}
# EndSection

{
    if ( (KP = jiter( $0 )) == "" ) next
    K=key;  V=$0;
    D = ( $0 ~ /^[\[\{]$/) ? depth - 1 : depth

    _k_reset = 0; # k_reset()
    _v_reset = 0; # v_reset()
}
