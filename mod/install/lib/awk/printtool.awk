BEGIN{
    HAS_CONTENT = 0
    if(wsl == "WSL2") wsl=tolower(wsl)
}

{
    if($0 != "") HAS_CONTENT = 1
    jiparse_after_tokenize( O, $0 )
}

END{
    if(HAS_CONTENT == 0) exit(0)
    RELEASE = install_juq(RELEASE)
    RELEASE = tolower(RELEASE)
    kp = SUBSEP "\"1\"" SUBSEP "\"rule\""
    get_all_tools(O, kp)
}

function get_all_tools(O, kp,          i, len, key, os_or_release, installer, arr, arr2){
    len = O[ kp  L]

    for(i=1; i<=len; ++i){
        key = juq(O[ kp S i ])

        if( key == "/") {
            print "/"
        }
        else if( key != "/"){
            split(key, arr, "/")
            os_or_release = arr[1]
            if ( (split(os_or_release, arr2, "-") == 1) && (os_or_release != "" ) )  os_or_release = os_or_release "-" ARCH
            installer = arr[2]
            if(( os_or_release == "" ) || ( OS "-" ARCH ~ "^"os_or_release ))        print installer
            else if( RELEASE "-" ARCH == os_or_release )                             print installer
            else if( wsl "-" ARCH ~ "^"os_or_release"$" )                            print installer
        }
    }
}

function install_juq(str){
    if(str ~ "^[\"]") return juq(str)
    else return str
}
