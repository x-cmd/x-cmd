# Section: jiparse
BEGIN{
    JITER_LEVEL = 0
    JITER_STACK_FOR_GRID_CHECK[ 0 ] = ""   #  keypath
}

# Section: jiter init save load
function jiter_save( obj ) {
    obj[ "FA_KEYPATH" ] = JITER_FA_KEYPATH
    obj[ "STATE" ]      = JITER_STATE
    obj[ "LAST_KP" ]    = JITER_LAST_KP
    obj[ "LEVEL" ]      = JITER_LEVEL
    obj[ "CURLEN" ]     = JITER_CURLEN
    obj[ "LAST_KL" ]    = JITER_LAST_KL
}

function jiter_init( keypath_prefix ) {
    JITER_FA_KEYPATH    = keypath_prefix
    JITER_STATE         = T_ROOT
    JITER_LAST_KP       = ""
    JITER_LEVEL         = 0
    JITER_CURLEN        = 0
    JITER_LAST_KL       = ""
}

function jiter_load( obj ){
    JITER_FA_KEYPATH    = obj[ "FA_KEYPATH" ]
    JITER_STATE         = obj[ "STATE" ]
    JITER_LAST_KP       = obj[ "LAST_KP" ]
    JITER_LEVEL         = obj[ "LEVEL" ]
    JITER_CURLEN        = obj[ "CURLEN" ]
    JITER_LAST_KL       = obj[ "LAST_KL" ]
}

function jiget( item, arrl, arr){
    if ( JITER_EQARR_PRINT == 0) {
        if ( jiter_eqarr( item, arrl, arr ) != true ) return false
        jiter_init()
        JITER_EQARR_PRINT = 1
    }
    jiter_skip( item )
    if ( item ~ /^[tfn"0-9+-]/ ) printf("%s\n", item) #/"
    if ( JITER_SKIP_LEVEL > 0 ) return false
    JITER_EQARR_PRINT = 0
    return true
}

function jiget_unquote( item, arrl, arr){
    if ( JITER_EQARR_PRINT == 0) {
        if ( jiter_eqarr( item, arrl, arr ) != true ) return false
        jiter_init()
        JITER_EQARR_PRINT = 1
    }
    jiter_skip( item )
    if ( item ~ /^[tfn"0-9+-]/ ) printf("%s\n", juq(item)) #/"
    if ( JITER_SKIP_LEVEL > 0 ) return false
    JITER_EQARR_PRINT = 0
    return true
}

function jiget_after_tokenize( item, keypath,     _arr, _arrl, _par, _parl){
    keypath = substr(jpath(keypath), 2)
    _parl = split(keypath, _par, S)
    _arrl = json_split2tokenarr( _arr, item )
    for (i=1; i<=_arrl; ++i) {
        jiget( _arr[i], _parl, _par)
    }
}

function jiget_after_tokenize_unquote( item, keypath,     _arr, _arrl, _par, _parl){
    keypath = substr(jpath(keypath), 2)
    _parl = split(keypath, _par, S)
    _arrl = json_split2tokenarr( _arr, item )
    for (i=1; i<=_arrl; ++i) {
        jiget_unquote( _arr[i], _parl, _par)
    }
}

# EndSection

# Notice: Intentionaly left JITER_STACK_FOR_GRID_CHECK undeleted for efficenty, for the memory leak of JITER_STACK_FOR_GRID_CHECK is slight.

# Section: EqArr
function jiter_eqarr_print( item, arrl, arr, sep1, sep2 ){
    if ( JITER_EQARR_PRINT == 0) {
        if ( jiter_eqarr( item, arrl, arr ) != true ) return false
        jiter_init()
        JITER_EQARR_PRINT = 1
    }
    jiter_skip( item )
    printf("%s" sep1, item)
    if ( JITER_SKIP_LEVEL > 0 ) return false
    JITER_EQARR_PRINT = 0
    printf(sep2)
    return true
}

function jiter_eqarr_parse( obj, item, arrl, arr ){
    if ( JITER_EQARR_PARSE == 0) {
        if ( jiter_eqarr( item, arrl, arr ) != true ) return false
        jiter_init()
        JITER_EQARR_PARSE = 1
    }
    jiter_skip( item )
    jiparse( obj, item )

    if (JITER_SKIP_LEVEL > 0) return false
    JITER_EQARR_PARSE = 0
    return true
}

function jiter_eqarr( item, arrl, arr,    _ret, _curlevel, _tgt ){
    if ( JITER_SKIP_LEVEL == 0 ) {
        _ret = jiter_for_current_key( item, JITER_STACK_FOR_GRID_CHECK )

        if ( _ret == "" ) return false
        _curlevel = (JITER_CURLEN == 0) ? JITER_LEVEL : JITER_LEVEL + 1
        _tgt = arr[ _curlevel ]
        if ( ( _tgt == "" ) || ( _tgt == _ret ) ) {           # diff
            if ( _curlevel == arrl ) return true
            return false
        }
    }
    jiter_skip( item )
    if  (( JITER_SKIP_LEVEL == 0 ) && ( JITER_CURLEN == 0 )) jiter_for_current_key( item, JITER_STACK_FOR_GRID_CHECK )  # Roll back
    return false
}
# EndSection

# Section: RegexArr
function jiter_regexarr_print( item, arrl, arr, sep1, sep2 ){
    if ( JITER_REGEXARR_PRINT == 0) {
        if ( jiter_regexarr( item, arrl, arr ) != true ) return false
        jiter_save( JITER_STACK_FOR_GRID_CHECK )   # diff
        jiter_init()
        JITER_REGEXARR_PRINT = 1
    }
    jiter_skip( item )
    printf("%s" sep1, item)

    if ( JITER_SKIP_LEVEL > 0 ) return false
    JITER_REGEXARR_PRINT = 0
    jiter_load( JITER_STACK_FOR_GRID_CHECK )   # diff
    if ( JITER_CURLEN == 0 ) jiter_regexarr( item, arrl, arr )  # Roll back # diff
    printf(sep2)
    return true
}

function jiter_regexarr_parse( obj, item, arrl, arr ){
    if ( JITER_REGEXARR_PARSE == 0) {
        if ( jiter_regexarr( item, arrl, arr ) != true ) return false
        jiter_save( JITER_STACK_FOR_GRID_CHECK )   # diff
        jiter_init()
        JITER_REGEXARR_PARSE = 1
    }
    jiparse( obj, item )

    if (JITER_LEVEL > 0) return false
    JITER_REGEXARR_PARSE = 0
    jiter_load( JITER_STACK_FOR_GRID_CHECK )   # diff
    if ( JITER_CURLEN == 0 ) jiter_regexarr( item, arrl, arr )   # Roll back    # diff
    return true
}

function jiter_regexarr( item, arrl, arr,    _ret, _curlevel ){
    if ( JITER_SKIP_LEVEL == 0 ) {
        _ret = jiter_for_current_key( item, JITER_STACK_FOR_GRID_CHECK )

        if ( _ret == "" ) return false
        _curlevel = (JITER_CURLEN == 0) ? JITER_LEVEL : JITER_LEVEL + 1
        if ( match( _ret, arr[ _curlevel ] ) != 0 ) {           # diff
            if ( _curlevel == arrl ) return true
            return false
        }
    }
    jiter_skip( item )
    if  (( JITER_SKIP_LEVEL == 0 ) && ( JITER_CURLEN == 0 )) jiter_for_current_key( item, JITER_STACK_FOR_GRID_CHECK )  # Roll back
    return false
}
# EndSection

# Section: jiter_for_current_key
function jiter_for_current_key( item, stack,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/) #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {
            _res = JITER_LAST_KP
            JITER_LAST_KP = ""
            return JITER_CURKEY = _res
        }
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            return JITER_CURKEY = "\"" JITER_CURLEN "\""
        }
        JITER_LAST_KP = item
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_LEVEL T_LEN ] = JITER_CURLEN
            _res = "\"" JITER_CURLEN "\""
        } else {
            stack[ JITER_LEVEL T_LEN ] = JITER_CURLEN
            _res = JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        stack[ ++JITER_LEVEL ] = item
        return JITER_CURKEY = _res
    } else {
        JITER_STATE = stack[ --JITER_LEVEL ]
        JITER_CURLEN = stack[ JITER_LEVEL T_LEN ]
    }
    return JITER_CURKEY = ""
}

# EndSection

# Section: target handler for print
# There is no jiter_handle_print, because if you want to format the output, pipe to another formatter
function jiter_print_rmatch( item, keypath, sep1, sep2,   _ret ){
    if (JITER_PRINT_RMATCH == 0){
        _ret = jiter( item, JITER_STACK_FOR_GRID_CHECK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath) == 0 ) return false
        jiter_save( JITER_STACK_FOR_GRID_CHECK )
        jiter_init()
        JITER_PRINT_RMATCH = 1
    }

    jiter_skip( item )
    printf("%s" sep1, item)

    if ( JITER_SKIP_LEVEL > 0 ) return false
    JITER_PRINT_RMATCH = 0
    jiter_load( JITER_STACK_FOR_GRID_CHECK )
    if ( JITER_CURLEN == 0 ) jiter( item, JITER_STACK_FOR_GRID_CHECK )  # Roll back
    printf(sep2)
    return true
}

function jiter_print_eqarr_after_tokenize( item, keypath, sep1, sep2,     _arr, _arrl, _par, _parl){
    keypath = substr(jpath(keypath), 2)
    _parl = split(keypath, _par, S)
    _arrl = json_split2tokenarr( _arr, item )
    for (i=1; i<=_arrl; ++i) {
        jiter_eqarr_print( _arr[i], _parl, _par, sep1, sep2)
    }
}


function jiter_target_rmatch_val( item, keypath_regex ){
    _ret = jiter( item, JITER_STACK_FOR_GRID_CHECK )
    if ( _ret == "" ) return
    if ( match(_ret, keypath_regex) == 0 ) return
    return item
}

function jiter_target_rmatch( obj, item, keypath_regex ){
    if ( JITER_TARGET_RMATCH_SWITCH == 0 ) {
        _ret = jiter( item, JITER_STACK_FOR_GRID_CHECK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath_regex) == 0 ) return false
        jiter_save( JITER_SAVE )
        jiter_init()
        JITER_TARGET_RMATCH_SWITCH = 1
    }

    jiparse( obj, item )
    if (JITER_LEVEL > 0) return false
    JITER_TARGET_RMATCH_SWITCH = 0
    jiter_load( JITER_SAVE )
    if ( JITER_CURLEN == 0 ) jiter( item, JITER_STACK_FOR_GRID_CHECK )  # Roll back
    return true
}
# EndSection

# Section: jiter core and jiter_skip and jileaf
function jileaf( obj, item, sep1, sep2, _kp ){
    _kp = jiter( item, obj )
    if (( item !~ /^[\[\{]$/ ) && ( item !~ /^[}]]$/ )) {
        printf("%s%s%s%s", _kp, sep1, item, sep2)
    }
}

function jiter_skip( item ){
    if (item ~ /^[\[\{]$/) {
        JITER_SKIP_LEVEL += 1
    } else if (item ~ /^[]}]$/) {
        JITER_SKIP_LEVEL -= 1
    }
    return JITER_SKIP_LEVEL
}

function jiter( item, stack,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/) #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {
            _res = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
            return _res
        }
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            return JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        }
        JITER_LAST_KP = item
        # return JITER_FA_KEYPATH S JITER_CURLEN
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        stack[ JITER_FA_KEYPATH ] = item
        stack[ ++ JITER_LEVEL ] = JITER_FA_KEYPATH
        return JITER_FA_KEYPATH
    } else {
        stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_FA_KEYPATH = stack[ --JITER_LEVEL ]
        JITER_STATE = stack[ JITER_FA_KEYPATH ]
        JITER_CURLEN = stack[ JITER_FA_KEYPATH T_LEN ]
    }
    return ""
}
# EndSection

# Section: jiparse
function jiparse_after_tokenize( obj, text,       _arr, _arrl, i){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse( obj, _arr[i] )
    }
}

function jiparse( obj, item ){
    if (item ~ /^[,:]?$/) return
    if (item ~ /^[tfn"0-9+-]/)   #"        # (item !~ /^[\{\}\[\]]$/)
    {
        if ( JITER_LAST_KP != "" ) {
            obj[ JITER_FA_KEYPATH SUBSEP JITER_LAST_KP ] = item
            JITER_LAST_KP = ""
        } else {
            JITER_CURLEN = JITER_CURLEN + 1
            if (JITER_STATE != "{") {
                obj[ JITER_FA_KEYPATH SUBSEP "\"" JITER_CURLEN "\"" ] = item
            } else {
                JITER_LAST_KP = item
                obj[ JITER_FA_KEYPATH SUBSEP JITER_CURLEN ] = item
            }
        }
    } else if (item ~ /^[\[\{]$/) {
        if ( JITER_STATE != "{" ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH SUBSEP "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH SUBSEP JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = item
        obj[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else {
        obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN

        JITER_FA_KEYPATH = obj[ --JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH L ]
    }
    return JITER_LEVEL
}

# EndSection

# Section: jiparse2leaf
function jiparse2leaf_after_tokenize( obj, text,       _arr, _arrl, i){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse2leaf_iter( obj, _arr[i] )
    }
}

function jiparse2leaf_init( initkp ){
    JITER_DEFAULT_KEYPATH = initkp
}

function jiparse2leaf_iter( obj, item ){
    if (item ~ /^[,:]?$/) return
    if (item ~ /^[tfn"0-9+-]/)   #"        # (item !~ /^[\{\}\[\]]$/)
    {
        if ( JITER_LAST_KP != "" ) {
            obj[ JITER_FA_KEYPATH SUBSEP JITER_LAST_KP ] = item
            JITER_LAST_KP = ""
        } else {
            JITER_CURLEN = JITER_CURLEN + 1
            if (JITER_STATE != "{") {
                obj[ JITER_FA_KEYPATH SUBSEP "\"" JITER_CURLEN "\"" ] = item
            } else {
                JITER_LAST_KP = item
                obj[ JITER_FA_KEYPATH SUBSEP JITER_CURLEN ] = item
            }
        }
    } else if (item ~ /^[\[\{]$/) {
        if ( JITER_DEFAULT_KEYPATH != "" ) {
            JITER_CURLEN = JITER_CURLEN + 1
            JITER_FA_KEYPATH = JITER_DEFAULT_KEYPATH
            obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_DEFAULT_KEYPATH = ""
        } else if ( JITER_STATE != "{" ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH SUBSEP "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH SUBSEP JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = item
        obj[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else {
        obj[ JITER_FA_KEYPATH L ] = JITER_CURLEN

        JITER_FA_KEYPATH = obj[ --JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH L ]
    }
    return JITER_LEVEL
}

function jiparse2leaf_fromfile( obj, kp, filepath,     c, r ){
    CAT_FILENOTFOUND = false
    JITER_CURLEN = 0
    jiparse2leaf_init( kp )
    while ((c=(getline <filepath))==1) jiparse2leaf_after_tokenize(obj, $0)
    if (c == -1)    CAT_FILENOTFOUND = true
    close( filepath )
    JITER_CURLEN = 0
}

# EndSection

