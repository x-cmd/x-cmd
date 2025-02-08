$0=="---"{
    l = 0
    p( a )
    next

    if (SEP == "") SEP = ","
}

BEGIN {
    printf("%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s\n", "name", "size", "uid", "gid", "type", "perm", "acc", "modify", "create")
}

{
    a[ ++l ] = $0
}

function p( a ){
    if ( a[1] ~ /^'[^']+'$/ )    a[1] = substr( a[1], 2, length(a[1])-2 )
    printf("%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s" SEP "%s\n", a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9])
}
