
BEGIN{
    INSTALL_UI_END          = UI_END
    INSTALL_UI_FG_YELLOW    = UI_FG_YELLOW
    INSTALL_UI_FG_CYAN      = UI_FG_CYAN
    INSTALL_UI_FG_GREEN     = UI_FG_GREEN
    INSTALL_UI_FG_BLUE      = UI_FG_BLUE

    HAS_CONTENT = 0
    if(wsl == "WSL2") wsl=tolower(wsl)

    if (( ___X_CMD_LANG == "cn" ) || ( ___X_CMD_LANG == "zh" )) ___X_CMD_LANG = "cn"
    else ___X_CMD_LANG = "en"
}

{
    if($0 != "") HAS_CONTENT = 1
    jiparse_after_tokenize( O, $0 )
}

END{
    if(HAS_CONTENT == 0) exit(0)
    print_basic_info(O)
    RELEASE = install_juq(RELEASE)
    RELEASE = tolower(RELEASE)
    kp = SUBSEP "\"1\"" SUBSEP "\"rule\""
    print_install_cmd(O, kp)
}

function print_install_cmd(O, kp,          i, len, key, os_or_release, installer, str, j){
    len = O[ kp  L]
    j = 0

    for(i=1; i<=len; ++i){
        key = juq(O[ kp S i ])
        str = juq(O[ kp S "\""key"\"" S "\"cmd\"" ])
        reference = juq(O[ kp S "\""key"\"" S "\"reference\"" ])

        if( key == "/") {
            print_install_cmd_style(str, reference)
        }
        else if( key != "/"){
            split(key, arr, "/")
            os_or_release = arr[1]
            # TODO: If the system name contains a hyphen character (like opensuse-tumbleweed), it will be impossible to determine
            if ( (split(os_or_release, arr2, "-") == 1) && (os_or_release != "" ) )  os_or_release = os_or_release "-" ARCH
            installer = arr[2]
            if(( os_or_release == "" ) || ( OS "-" ARCH ~ "^"os_or_release ))        print_install_cmd_style(str, reference)
            else if( RELEASE "-" ARCH == os_or_release )                             print_install_cmd_style(str, reference)
            else if( wsl "-" ARCH ~ "^"os_or_release"$" )                            print_install_cmd_style(str, reference)
        }
    }
}


function print_basic_info(O,                homepage, desc, lang){

    homepage = juq(O[ SUBSEP "\"1\"" SUBSEP "\"homepage\"" ])
    lang = juq(O[ SUBSEP "\"1\"" SUBSEP "\"lang\"" ])
    desc = juq(O[ SUBSEP "\"1\"" SUBSEP "\"desc\"" SUBSEP "\""___X_CMD_LANG"\"" ])

    print_install_basic_info_style(NAME, homepage, desc, lang)
}

function install_juq(str){
    if(str ~ "^[\"]") return juq(str)
    else return str
}

function print_install_cmd_style(str, reference, install_name){
    str = str_trim(str)

    if (str ~ "\n") {
        gsub("\n", "\n    ", str)
        str = "|\n    " str
    }

    printf("- %s%s%s: %s\n  %s%s%s: %s\n", \
        INSTALL_UI_FG_CYAN,     "reference",    INSTALL_UI_END, reference, \
        INSTALL_UI_FG_YELLOW,   "cmd",          INSTALL_UI_END, str )
}

function print_install_basic_info_style(name, homepage, desc, lang){
    printf("- %s%s%s: %s\n- %s%s%s: %s\n- %s%s%s: %s\n- %s%s%s: %s\n\n", \
    INSTALL_UI_FG_GREEN,     "Name",          INSTALL_UI_END, name, \
    INSTALL_UI_FG_GREEN,     "Homepage",      INSTALL_UI_END, homepage, \
    INSTALL_UI_FG_GREEN,     "Description",   INSTALL_UI_END, desc,
    INSTALL_UI_FG_GREEN,     "Language",      INSTALL_UI_END, lang )
}

