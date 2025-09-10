# /.
# /usr
# /usr/bin
# /usr/bin/curl
# /usr/share
# /usr/share/doc
# /usr/share/doc/curl
# /usr/share/doc/curl/changelog.Debian.gz
# /usr/share/doc/curl/changelog.gz
# /usr/share/doc/curl/copyright
# /usr/share/man
# /usr/share/man/man1
# /usr/share/man/man1/curl.1.gz
# /usr/share/zsh
# /usr/share/zsh/vendor-completions
# /usr/share/zsh/vendor-completions/_curl


# BEGIN{
#     FS = "/"
# }

# {
#     l = split( $0, arr, "/" )
#     printf("  \033[0;2m/")
#     for (i=2; i<=l-1; ++i) {
#         printf("%s/", arr[i])
#     }
#     printf("\033[0;36m%s\n", arr[l])
# }

{
    res = res "\n" $0
}

BEGIN {
    INDENT = "  "
}

function handle( astr ){
    l = split( astr, arr, "\n" )

    is_folder[ "" ] = 1

    for (i=3; i<=l; ++i) {
        if ( index( arr[i], arr[i-1] )) {
            is_folder[ arr[i-1] ] = 1
        }
    }

    for (i=2; i<=l; ++i) {
        e = arr[i]
        if (is_folder[ e ]) {
            # printf( INDENT "\033[0;2m%s\n", e)
            continue
        }

        if (e == "/.") continue

        el = split( e, earr, "/" )
        printf("  \033[0;2m/")
        for (j=2; j<=el-1; ++j) {
            printf("%s/", earr[j])
        }
        printf("\033[0;36m%s\n", earr[el])
    }
}

END {
    handle( res )
}
