BEGIN{
    HAS_CONTENT = 0
    if(wsl = "WSL2") wsl=tolower(wsl)
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

    if (IS_RUN == 1 ){
        print "\\"
        printf("'x open %s'", juq(O[SUBSEP "\"1\"" SUBSEP "\"homepage\""]))
        print " \\"
        print "'Exit'"
    }
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
            if ( (split(os_or_release, arr2, "-") == 1) && (os_or_release != "" ) )  os_or_release = os_or_release "-" ARCH
            installer = arr[2]
            if(( os_or_release == "" ) || ( OS "-" ARCH ~ "^"os_or_release ))        print_install_cmd_style(str, reference)
            else if( RELEASE "-" ARCH == os_or_release )                             print_install_cmd_style(str, reference)
            else if( wsl "-" ARCH ~ "^"os_or_release"$" )                            print_install_cmd_style(str, reference)
        }
    }
}


function print_basic_info(O,    region,   homepage, desc, lang){
    if( REGION == "cn") region = "cn"
    else region = "en"

    homepage = juq(O[ SUBSEP "\"1\"" SUBSEP "\"homepage\"" ])
    lang = juq(O[ SUBSEP "\"1\"" SUBSEP "\"lang\"" ])
    desc = juq(O[ SUBSEP "\"1\"" SUBSEP "\"desc\"" SUBSEP "\""region"\"" ])

    print_install_basic_info_style(NAME, homepage, desc, lang)
}

function install_juq(str){
    if(str ~ "^[\"]") return juq(str)
    else return str
}


