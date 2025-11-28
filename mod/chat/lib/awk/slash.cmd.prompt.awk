{
    if ( (! HAS_FRONTMATTER) && ( $0 ~ "^---+$" )) {
        HAS_FRONTMATTER = 1
        while( getline ){
            str = str $0 "\n"
            if ( $0 ~ "^---+" ) {
                str = ""
                break
            }
        }
    } else if ( $0 != "" ) {
        str = $0
        while( getline ){
            str = str $0 "\n"
        }
    }
}
END{
    str = str_replace_varname( str )
    str = str_replace_cmd( str )
    str = str_replace_file( str )
    print str
}

function str_replace_varname( src,         _name, ans ){
    ans = ""
    while (match(src, "%{[A-Za-z0-9_]+}%")) {
        _name = substr(src, RSTART+2, RLENGTH-4)
        _name = ENVIRON[ _name ]
        _name = str_truncate(_name)
        ans = ans substr(src, 1, RSTART-1) _name
        src = substr(src, RSTART+RLENGTH)
    }
    return ans src
}

function str_replace_cmd( src,         ans, _cmd, t ){
    ans = ""
    while (match(src, "!`[^`]+`")) {
        _cmd = substr(src, RSTART+2, RLENGTH-3)
        _cmd | getline t
        close( _cmd )
        t = str_truncate(t)
        ans = ans substr(src, 1, RSTART-1) \
            "<command-execution cmd: " _cmd " >\n" t "</command-execution>\n"
        src = substr(src, RSTART+RLENGTH)
    }
    return ans src
}

function str_replace_file( src,         ans, _file, t ){
    ans = ""
    while (match(src, "@([^ ]+)")) {
        _file = substr(src, RSTART+1, RLENGTH-1)
        t = cat( _file )
        t = str_truncate(t)
        ans = ans substr(src, 1, RSTART-1) \
            "<file-references file: " _file " >\n" t "</file-references>\n"
        src = substr(src, RSTART+RLENGTH)
    }
    return ans src
}

function str_truncate( str,            l, ls, rs ){
    l = length(str)
    if ( l <= 2048 ) return str

    ls = substr(func_stderr, 1, 512)
    if ( match( ls, "^[^-a-zA-Z0-9+&@#/%?=~_|!:,.; ]+" ) ) {
        ls = substr(ls, 1, RSTART-1)
    }

    rs = substr(func_stderr, l-512, 512)
    if ( match( rs, "^[^-a-zA-Z0-9+&@#/%?=~_|!:,.; ]+" ) ) {
        rs = substr(rs, RSTART+RLENGTH)
    }
    return "(truncated)\n" ls "\n<<< omitted " (loutput - 1024) " bytes >>>\n" rs
}
