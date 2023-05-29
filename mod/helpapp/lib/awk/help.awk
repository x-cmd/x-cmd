{ if ($0 != "") jiparse_after_tokenize(obj, $0); }
END{
    ARGSTR = ENVIRON[ "ARGSTR" ]
    HELP_ARG_SEP = ENVIRON[ "HELP_ARG_SEP" ]
    TH_HETHEME_THEME_COLOR0 = ENVIRON[ "___X_CMD_HELP_THEME_COLOR_CODE_0" ]
    TH_HETHEME_THEME_COLOR1 = ENVIRON[ "___X_CMD_HELP_THEME_COLOR_CODE_1" ]
    TH_HETHEME_DESC_COLOR0  = ENVIRON[ "___X_CMD_HELP_DESC_COLOR_CODE_0" ]
    TH_HETHEME_DESC_COLOR1  = ENVIRON[ "___X_CMD_HELP_DESC_COLOR_CODE_1" ]

    prepare_argarr(ARGSTR, HELP_ARG_SEP)
    obj_prefix = locate_obj_prefix( obj, args )

    if (obj_prefix == "") exit(0)
    print_helpdoc_init(NO_COLOR, WEBSRC_REGION, TH_HETHEME_THEME_COLOR0, TH_HETHEME_THEME_COLOR1, TH_HETHEME_DESC_COLOR0, TH_HETHEME_DESC_COLOR1)
    printf( "%s", print_helpdoc( obj, obj_prefix, COLUMNS ) )
}

# Section: prepare argument
function prepare_argarr( argstr, sep,       l ){
    if ( argstr == "" ) return
    gsub( "(^[\002]+)|([\002]+$)", "" , argstr)
    l = split(argstr, args, sep)
    args[L] = l
}
# EndSection

function panic( s ){
    log_error( "help", s )
    exit(1)
}
