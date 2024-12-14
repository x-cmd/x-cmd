
function printrow( i ){
    for (i=1; i<NF; ++i) printf("%s" OFS, $i)
    printf("%s\n", $NF)
}

function getline_or_exit( ){
    if (! getline) exit
}

function handletable( type, printheader,    i ){
    if (printheader) {
        printf("%s" OFS, "type")
        for (i=1; i<NF; ++i) {
            if ( $i != "Network" )  printf("%s" OFS, $i)
        }
        printf("%s\n", $NF)
    }
    getline_or_exit()

    while ( $0 !~ /=+/) {
        printf("%s" OFS, type)
        printrow( )
        getline_or_exit()
    }
}

function handleipv6table( type, printheader,        i ){
    getline_or_exit()

    while ( $0 !~ /=+/) {
        printf("%s" OFS, type)
        interface = $1
        metric = $2
        destination = $3
        gateway = $4
        if ( gateway == "" )    getline gateway
        gsub("^[ ]+", "", gateway)
        printf("%s" OFS "%s" OFS "%s" OFS "%s" OFS "%s", destination, "", gateway, interface, metric)
        printf "\n"
        getline_or_exit()
    }
}

BEGIN {

    while ($0 !~ /^Active Routes:/) getline_or_exit()
    getline_or_exit()

    handletable( "ipv4", 1 )

    while ($0 !~ /^Active Routes:/) getline_or_exit()
    getline_or_exit()

    handleipv6table( "ipv6", "" )
}

