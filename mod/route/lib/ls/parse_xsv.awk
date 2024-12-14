
function printrow( i ){
    for (i=1; i<NF; ++i) printf("%s" OFS, $i)
    printf("%s\n", $NF)
}

function getline_or_exit( ){
    if (! getline) exit
}

function handletable( type, printheader, i ){
    num = NF

    if (printheader) {
        printf("%s" OFS, "type")
        printrow( )
    }
    getline_or_exit()

    while ($0 != "") {
        printf("%s" OFS, type)
        printrow( )
        getline_or_exit()
    }
}

BEGIN {

    while ($0 !~ /(^[^:]+:|^Kernel)/) getline_or_exit()
    getline_or_exit()

    handletable( "ipv4", 1 )

    while ($0 !~ /^[^:]+:/) getline_or_exit()
    getline_or_exit()

    handletable( "ipv6", "" )
}

