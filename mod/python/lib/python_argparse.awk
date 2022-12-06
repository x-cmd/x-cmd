BEGIN{
    str1=0
    str2=""
    now=""
    RS="\001"
}

function addnow(arg){
    now = now " " wrap(arg)
}

function addnow_nowrap(arg){
    now = now " " arg
}

function print_code(varname, value){
    print( "local " varname "=" wrap(value) )
}

function revert(a){
    gsub("\004", "\n", a)
    return a
}

function wrap(a){
    gsub("\"", "\\\"", a)
    return "\"" a "\""
}

function exit_now(code){
    EXIT_CODE = code
    exit code
}

function panic_error(msg){
    print "\033[0;91merror: \033[0m" msg "\nFor more information try \033[36m--help\033[0m" > "/dev/stderr"
    exit_now(1)
}


{
    gsub("\n$", "", $0)
    gsub("\n", "\004", $0)
    arg_arr_len = split($0, arg_arr, ARG_SEP)

    for (i=1; i<=arg_arr_len; ++i) {
        elem = revert( arg_arr[i] )

        if (str1 != 0) {
            addnow( elem )
            continue
        }

        if (elem == "-") {
            addnow_nowrap( elem )
            exit(126)       # No path substitution
        }

        # Just pass through
        if ( (elem == "-c") || (elem == "-m") ){
            i = i + 1
            elem = revert( arg_arr[i] )
            exit(126)       # No path substitution
        }

        # Add to the first part
        if ((elem == "-Q") || (elem == "-W")) {
            addnow_nowrap( elem )
            i = i + 1
            elem = revert( arg_arr[i] )
            addnow( elem )
            continue
        }

        if (elem == "-OO") {
            addnow_nowrap( elem )
            continue
        }

        if (elem ~ /^-/) {
            letter=substr(elem, 2)
            if ( index(letter, "bBdEhiORsStuvx3") > 0 ) {
                addnow_nowrap( elem )
                continue
            } else {
                panic_error("Very wrong")
            }
        } else {
            if (str1 == 0) {
                print_code( "FP", elem )

                str1 = now
                now = ""
            } else {
                panic_error("Should NEVER happened.")
            }
        }

    }

    str2 = now
    print_code( "S1", str1 )
    print_code( "S2", str2 )
}

