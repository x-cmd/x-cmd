
function trim( s ){
    gsub("(^[\t ]+)|([\t ]+)$", "", s)
    return s
}

BEGIN{
    data = ENVIRON[ "data" ]
    arrl = split(data, arr, "\n")
    for (i=1; i<=arrl; ++i) {
        $0 = arr[i]
        id = $1; $1 = ""
        all[ id ] = id
        all[ id, "ver" ] = $NF; $NF = ""
        all[ id, "name" ] = trim( $0 )
    }
}

BEGIN{
    printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", "id", "name", "version", "size", "release", "min", "by", "from")
}

{
    while (getline) {
        if ($0 == "--------") break
        if ($0 == "") break
        if ($1 == "By:") {
            $1 = "";    by = trim( $0 )
        } else if ($1 == "Released:") {
            $1 = "";    release = trim( $0 )
        } else if ($1 == "Size:") {
            $1 = "";    size = trim( $0 )
        } else if ($1 == "From:") {
            $1 = "";    from = trim( $0 )
        } else if ($1 == "Minimum") {
            $1 = $2 = ""; minos = trim( $0 )
        } else {
            desc = $0
        }

    }

    arrl = split(from, arr, "/")
    id = int(substr(arr[ arrl ], 3))

    ver = all[id, "ver"]
    gsub("[)(]", "", ver)
    name = all[id, "name"]

    printf( "%s\t%s\t%s\t", id, name, ver )
    printf( "%s\t%s\t%s\t%s\t%s\n", size, release, minos, by, from  )
}
