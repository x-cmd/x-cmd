BEGIN{
    if(wsl = "WSL2") wsl=tolower(wsl)
}

{ jiparse_after_tokenize( O, $0 ) }

END{
    print_basic_info(O)
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
            installer = arr[2]
            if(( os_or_release == "" ) || ( OS ~ "^"os_or_release"$" ))     print_install_cmd_style(str, reference)
            else if( RELEASE == os_or_release )                             print_install_cmd_style(str, reference)
            else if( wsl ~ "^"os_or_release"$" )                            print_install_cmd_style(str, reference)
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


