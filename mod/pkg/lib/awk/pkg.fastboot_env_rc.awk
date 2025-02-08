BEGIN{
    global_dir = ___X_CMD_PKG_ROOT_SPHERE "/" sphere_name "/l/j/h"
    global_bin = shqu1( global_dir "/bin" )
    global_lib = shqu1( global_dir "/lib" )
    global_man = shqu1( global_dir "/man" )

    initstr = "PATH=" global_bin ":${PATH}"

    if ( osarch ~ "^drawin" ) {
        initstr = initstr "\n[ \"$DYLD_LIBRARY_PATH\" != \"${DYLD_LIBRARY_PATH#*"global_lib":}\" ] || DYLD_LIBRARY_PATH=" global_lib ":${DYLD_LIBRARY_PATH}"
    } else {
        initstr = initstr "\n[ \"$LD_LIBRARY_PATH\" != \"${LD_LIBRARY_PATH#*"global_lib":}\" ] || LD_LIBRARY_PATH=" global_lib ":${LD_LIBRARY_PATH}"
    }

    initstr = initstr "\n[ \"$MANPATH\" != \"${MANPATH#*"global_man":}\" ] || MANPATH=" global_man ":${MANPATH}"
}

function shqu1( s ){
    gsub("'", "'\\''", s)
    return "'" s "'"
}

($2 == "path"){
    if ( $3 == "unshift" ) prefix_p = $4 ":" prefix_p
    else if ( $3 == "append" ) suffix_p = suffix_p ":" $4
}
($2 == "var"){
    str = str "export " $3 "=" shqu1($4) "\n"
}
END{
    print initstr

    if (( prefix_p != "" ) || ( suffix_p != "" )){
        print "PATH=" shqu1( prefix_p ) "\"${PATH}\"" shqu1( suffix_p)
    }

    print str
}
