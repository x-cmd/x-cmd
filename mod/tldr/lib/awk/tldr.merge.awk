

BEGIN{
    RS = "(\r)|(\n)|(\r\n)"
}

function get_page_content( name, arr,         fp ){
    if ( lang == "en" ) return cat_to_arr( root "/pages.en/" name, arr )

    fp = root "/pages." lang "/" name
    cat_to_arr( fp, arr )
    if ( cat_is_filenotfound() ) {
        return cat_to_arr( root "/pages.en/" name, arr )
    }
}

function print_allinone( name,               fparr, i, l, count, last, line, data, linecount){
    if (name !~ namefilter_all) return 0

    printf("%s\t", name)

    get_page_content( name, fparr )
    l = fparr[ L ]
    for (i=1; i<=l; ++i) {
        line = fparr[ i ]
        if ( (last == line) && (line !~ /^[\s]*$/) ) break
        last = line

        count ++
        if (count != 1) {
            if (line !~ /^[\s ]*$/) {
                data = data "\t" line
            }
        }
    }

    print data
}

function print_keyinfo( name,               fparr, i, l, count, last, line, linedata, linecount ){
    if (name !~ namefilter_all) return 0

    get_page_content( name, fparr )
    l = fparr[ L ]
    for (i=1; i<=l; ++i) {
        line = fparr[ i ]
        if ( (last == line) && (line !~ /^[\s]*$/) ) break
        if ( line ~ "^- " ){
            linedata = sprintf( "%s:%d\t", name, ++count )
            lineinfo = line
        } else if ( line ~ "^`" ) {
            print linedata "\t" line " " lineinfo
        }
        last = line
    }
}

{
    name = $1
    namefilter_all = "^(android|cisco-ios|common|dos|freebsd|linux|netbsd|openbsd|osx|sunos|windows)"

    if ( mode == "allin1"){
        print_allinone( name )
    } else if (mode == "keyinfo") {
        print_keyinfo( name )
    }
}

