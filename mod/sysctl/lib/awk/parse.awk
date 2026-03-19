
BEGIN{
    printf( "%s\t%s\n" , "variable", "value" )
}

$2!="="{
    key = $1
    $1 = ""
    gsub( "(^[ ]+)|([ ]+$)", "", $0 )
    gsub( ":", "", key )
    printf( "%s\t%s\n" , key, $0 )
    next
}

{
    key = $1
    $1 = $2 = ""
    gsub( "(^[ ]+)|([ ]+$)", "", $0 )
    printf( "%s\t%s\n" , key, $0 )
}
