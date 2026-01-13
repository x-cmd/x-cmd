

BEGIN{
    RS = "(\r)|(\n)|(\r\n)"
}

function print_allinone( name, fp,               count, last, line, data, linecount){
    if ($1 !~ namefilter_all) return 0

    printf("%s\t", name)

    last = data = ""
    count = 0
    linecount = 0

    while (getline line <fp) {
        if ( (last == line) && (line !~ /^[\s]*$/) ) break
        if ( linecount > 50 ) break
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

function print_keyinfo( name, fp,               count, last, line, linedata, linecount ){
    if (name !~ namefilter_all) return 0

    last = ""
    count = 0

    linedata = ""
    linecount = 0

    while (getline line <fp) {
        linecount ++
        if ( (last == line) && (line !~ /^[\s]*$/) ) break
        if ( linecount > 50 ) break

        if ( line ~ "^- " ){
            linedata = sprintf( "%s:%02d\t", name, ++count )
            lineinfo = line
        } else if ( line ~ "^`" ) {
            print linedata "\t" line " " lineinfo
        }
        last = line
    }
}

{
    name = $1
    fp = root "/" name

    namefilter_all = "^(android|cisco-ios|common|dos|freebsd|linux|netbsd|openbsd|osx|sunos|windows)"

    if ( mode == "allin1"){
        print_allinone( name, fp )
    } else if (mode == "keyinfo") {
        print_keyinfo( name, fp )
    }
}

