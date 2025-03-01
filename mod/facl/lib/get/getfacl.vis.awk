function visualize(d,      l, i, arr, key, default_key) {
    l = split($0, arr, ":")

    if ($0 ~ "default") {
        for (i = 1; i <= L; i++) {
            key = facl[i 1] facl[i 2]
            default_key = arr[2] arr[3]
            if (key == default_key) {
                facl[i 4] = arr[4]
                continue
            }
        }
        return
    } else {
        for (i = 1; i <= l; i++) {
            facl[L i] = arr[i]
        }
        L++
    }
}

function printfacl( file, L,        i ) {
    printf( "%s\n", FILE_STYLE file END_STYLE )
    for (i = 1; i < L; i++) {
        _SCOPE = facl[i 1]
        _VALUE = facl[i 2]
        _ACL   = facl[i 3]
        _DACL  = facl[i 4]
        if ( ( _SCOPE == "user" )  && ( _VALUE == "" ) )     _VALUE = _OWNER
        if ( ( _SCOPE == "group" ) && ( _VALUE == "" ) )     _VALUE = _GROUP
        printf( PRINT_FMT, SCOPE_STYLE _SCOPE END_STYLE, SCOPE_STYLE _VALUE END_STYLE, ACL_STYLE _ACL END_STYLE, DACL_STYLE _DACL END_STYLE )
    }
}

function handle(file,      i) {
    L = 1
    while (1) {
        if ($0 ~ "# file: ") {
            if (file != "" ) {
                printfacl( file, L )
                delete facl
                L = 1
                file = ""
                print LINE_STYLE "-----------------------------"  END_STYLE
            }
            file = substr($0, index($0, ":") + 2)
        }

        if ($0 ~ "# owner: ")  _OWNER = substr($0, index($0, ":") + 2)
        if ($0 ~ "# group: ")  _GROUP = substr($0, index($0, ":") + 2)

        if (($0 !~ "^#") && ($0 ~ ":"))       visualize(L, $0)

        if (!getline)   { printfacl( file, L );  return }
    }
}

BEGIN{
    if(NO_COLOR != 1){
        LINE_STYLE  = "\033[30m"
        FILE_STYLE  = "\033[33m"
        SCOPE_STYLE = "\033[36m"
        ACL_STYLE   = "\033[35m"
        DACL_STYLE  = "\033[32m"
        END_STYLE   = "\033[0m"
    }

    PRINT_FMT = (format == "tsv") ? \
        "%s\t%s\t%s\t%s\n" : \
        "%s,%s,%s,%s\n"

    printf "\n"
    handle()
}
