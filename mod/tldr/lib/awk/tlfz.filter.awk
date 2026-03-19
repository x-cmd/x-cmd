
BEGIN{
    if (filtermode=="darwin"){
        namefilter = "^(common|osx)"
    } else if (filtermode=="linux"){
        namefilter = "^(common|linux)"
    } else if (filtermode ~ "win"){
        namefilter = "^(common|dos|windows)"
    } else if (filtermode=="termux"){
        namefilter = "^(common|linux|android)"
    } else {
        # if (filtermode=="all"){
        namefilter = "^(android|cisco-ios|common|dos|freebsd|linux|netbsd|openbsd|osx|sunos|windows)"
    }

    EMO[ "common"       ] = "⚙️"
    EMO[ "android"      ] = "🤖"
    EMO[ "cisco-ios"    ] = "🌐"
    EMO[ "common"       ] = "⚙️"
    EMO[ "dos"          ] = "💾"
    EMO[ "freebsd"      ] = "😈"
    EMO[ "linux"        ] = "🐧"
    EMO[ "netbsd"       ] = "🏔️"
    EMO[ "openbsd"      ] = "🐡"
    EMO[ "osx"          ] = "🍎"
    EMO[ "sunos"        ] = "☀️"
    EMO[ "windows"      ] = "🟦"
}

{
    if (match( $1, namefilter ) ) {
        o = $1

        a = substr( $1, RSTART, RLENGTH )
        b = substr( $1, RLENGTH + 2 )

        if (match( b , ":[0-9]+$")) {
            c = substr( b, RSTART + 1, RLENGTH )
            b = substr( b, 1, RSTART - 1 )
        }

        name = a

        if ( a == "common" )       name = "\033[35m" "com" "\033[0;2m" "/"   "\033[0;35m"    b   "\033[0;2m"
        else if ( a == "android" ) name = "\033[32m" "and" "\033[0;2m" "/"   "\033[0;32;1m"  b   "\033[0;2m"
        else if ( a == "osx" )     name = "\033[34m" "osx" "\033[0;2m" "/"   "\033[0;34;1m"  b   "\033[0;2m"
        else if ( a == "windows" ) name = "\033[34m" "win" "\033[0;2m" "/"   "\033[0;34;1m"  b   "\033[0;2m"
        else if ( a == "linux" )   name = "\033[32m" "lin" "\033[0;2m" "/"   "\033[0;32;1m"  b   "\033[0;2m"
        else if ( a == "dos" )     name = "\033[35m" "dos" "\033[0;2m" "/"   "\033[0;35;1m"  b   "\033[0;2m"
        else                       name = "\033[34m" a     "\033[0;2m" "/"   "\033[0;34;1m"  b   "\033[0;2m"

        if (c != ""){
            name = name ":" c
        }

        $1 = ""

        printf("%-50s", name)

        print " " EMO[a] " " $0
    }
}
