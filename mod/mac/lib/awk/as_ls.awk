BEGIN{
    printf( "%s\t%s\t%s\n", "id", "name", "version" )
}

function trim( s ){
    gsub("(^[\t ]+)|([\t ]+)$", "", s)
    return s
}

{
    id = $1
    version = $NF
    $1 = $NF = ""
    name = trim($0)

    printf( "%s\t%s\t%s\n", id, name, version )
}

