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
    print( varname "=" wrap(value) )
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

BEGIN{
    option_len = 0
    flag_len = 0
}

function add( optname ){
    if (optname ~ /=\.\.\./) {
        gsub(/=\.\.\./, "", optname)
        option_len += 1
        option[ option_len ] = optname
        option[ optname ] = 1
    } else {
        flag_len += 1
        flag[ flag_len ] = optname
        flag[ optname ] = 1
    }
}

BEGIN {
    add( "-" )
    add( "--" )
    add( "--abort-on-uncaught-exception" )
    add( "-c" )
    add( "--completion-bash" )
    add( "--conditions=..." )
    add( "--cpu-prof" )
    add( "--cpu-prof-dir=..." )
    add( "--cpu-prof-interval=..." )
    add( "--cpu-prof-name=..." )
    add( "--diagnostic-dir=..." )
    add( "--disable-proto=..." )
    add( "--disallow-code-generation-from-strings" )
    add( "--enable-source-maps" )
    add( "-e" )
    add( "--experimental-abortcontroller" )
    add( "--experimental-import-meta-resolve" )
    add( "--experimental-json-modules" )
    add( "--loader" )
    add( "--experimental-policy=..." )
    add( "--experimental-repl-await" )
    add( "--es-module-specifier-resolution" )
    add( "--experimental-vm-modules" )
    add( "--experimental-wasi-unstable-preview1" )
    add( "--experimental-wasm-modules" )
    add( "--force-context-aware" )
    add( "--frozen-intrinsics" )
    add( "--heap-prof" )
    add( "--heap-prof-dir=..." )
    add( "--heap-prof-interval=..." )
    add( "--heap-prof." )
    add( "--heap-prof-name=..." )
    add( "--heapsnapshot-signal=..." )
    add( "-h" )
    add( "--huge-max-old-generation-size" )
    add( "--icu-data-dir=..." )
    add( "--input-type=..." )
    add( "--insecure-http-parser" )
    add( "--inspect[=[host:]port]" )
    add( "--inspect-brk[=[host:]port]" )
    add( "--debug-port" )
    add( "--inspect-publish-uid=..." )
    add( "-i" )
    add( "--interpreted-frames-native-stack" )
    add( "--jitless" )
    add( "--max-http-header-size=..." )
    add( "--no-deprecation" )
    add( "--no-force-async-hooks-checks" )
    add( "--no-warnings" )
    add( "--openssl-config=..." )
    add( "--pending-deprecation" )
    add( "--policy-integrity=..." )
    add( "--preserve-symlinks" )
    add( "--preserve-symlinks-main" )
    add( "-p" )
    add( "--prof" )
    add( "--prof-process" )
    add( "--redirect-warnings=..." )
    add( "--report-compact" )
    add( "--report-directory" )
    add( "--report-filename=..." )
    add( "--report-on-fatalerror" )
    add( "--report-on-signal" )
    add( "--report-signal=..." )
    add( "--report-uncaught-exception" )
    add( "-r" )
    add( "--throw-deprecation" )
    add( "--title=..." )
    add( "--tls-cipher-list=..." )
    add( "--tls-keylog=..." )
    add( "--tls-max-v1.2" )
    add( "--tls-max-v1.3" )
    add( "--tls-min-v1.0" )
    add( "--tls-min-v1.1" )
    add( "--tls-min-v1.2" )
    add( "--tls-min-v1.3" )
    add( "--trace-atomics-wait" )
    add( "--trace-deprecation" )
    add( "--trace-event-categories=..." )
    add( "--trace-event-file-pattern=..." )
    add( "--trace-exit" )
    add( "--trace-sigint" )
    add( "--trace-sync-io" )
    add( "--trace-tls" )
    add( "--trace-uncaught" )
    add( "--trace-warnings" )
    add( "--track-heap-objects" )
    add( "--unhandled-rejections=..." )
    add( "--use-bundled-ca" )
    add( "--use-largepages=..." )
    add( "--use-openssl-ca" )
    add( "--v8-options" )
    add( "--v8-pool-size=..." )
    add( "-v" )
    add( "--zero-fill-buffers" )
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

        if ( (elem == "--eval") || (elem == "-e") ) {
            exit(126)       # No path substitution
        }

        if (elem ~ /^-/) {

            if ( elem ~ /^-[^=]+=/ ) {
                addnow_nowrap( elem )

                gsub(/=[^$]$/, "", elem)
                if ( option[elem] != 1) {
                    panic_error("Expect to be an option")
                }
                continue
            }

            if ( option[elem] == 1) {
                addnow_nowrap( elem )
                i = i+1
                elem = revert( arg_arr[i] )
                addnow( elem )
                continue
            }

            if ( flag[elem] == 1) {
                addnow_nowrap( elem )
                continue
            }

            panic_error("Expect to be an option or flag")
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

