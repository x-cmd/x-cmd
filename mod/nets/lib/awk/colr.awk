
function parse(){

}

BEGIN{
    FALSE = 0
    TRUE = 1
}

function is_startup_hint( s ){
    if (s ~ /^(Active)/) {  return TRUE ; }
    if ( s ~ /^Registered/) {   return TRUE; }
    return FALSE
}

function color( i ) {
    if ($i == "tcp4") {
        $i = "\033[32m" $i "\033[0m"
    } else if ($i == "tcp6") {
        # $i = "\033[36m" $i "\033[0m"
    } else if ($i ~ /[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+[.][0-9]+/) {
        $i = "\033[34m" $i "\033[0m"
    } else if ($i ~ /[*][.][0-9]+/) {
        $i = "\033[32m" $i "\033[0m"
    } else if ($i == "ESTABLISHED") {
        $i = "\033[34m" $i "\033[0m"
    } else if ($i == "LISTEN") {
        $i = "\033[32m" $i "\033[0m"
    }
}

function print_tab( data, num, i ){
    $0 = data

    for (i=1; i<num; i++){
        printf("%s\t", $i)
    }
    printf("%s\n", $num)
}

function consume_output( hint, numfield, header ){
    print hint
    print_tab( header, numfield )
    while (getline) {
        if (is_startup_hint( $0 )) { break }

        for (i=1; i<=numfield; i++) {
            color( i )
        }

        print_tab( $0, numfield )
    }
}


BEGIN{
    getline
    while (1) {
        hint = $0
        if (! getline ) { break }
        header = $0
        gsub(/Local[ ]+Address/, "Local-Address", header)
        gsub(/Foreign[ ]+Address/, "Foreign-Address", header)

        $0 = header # = tolower( header )

        numfield = NF

        consume_output( hint, numfield, header )
    }
}


