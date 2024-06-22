
$0=="---"{
    l = 0
    pcolor( a )
    next
}

{
    a[ ++l ] = $0
}

function p( a ){
    printf("%s:\n", a[ 1 ])
    printf("  Size:    %s\n", a[ 2 ])
    printf("  Uid:     %s\n", a[ 3 ])
    printf("  Gid:     %s\n", a[ 4 ])
    printf("  Type:    %s\n", a[ 5 ])
    printf("  Perm:    %s\n", a[ 6 ])
    printf("  Acc:     %s\n", a[ 7 ])
    printf("  Modify:  %s\n", a[ 8 ])
    printf("  Create:  %s\n", a[ 9 ])
}

function pcolor( a ){
    if ( a[1] ~ /^'[^']+'$/ )    a[1] = substr( a[1], 2, length(a[1])-2 )
    printf("%s:\n", "\033[0;36m"a[ 1 ]"\033[0m")
    printf("\033[0;36m""  Size:    %s\n""\033[0m", "\033[0;35m"a[ 2 ]"\033[0m")
    printf("\033[0;36m""  Uid:     %s\n""\033[0m", "\033[0;35m"a[ 3 ]"\033[0m")
    printf("\033[0;36m""  Gid:     %s\n""\033[0m", "\033[0;35m"a[ 4 ]"\033[0m")
    printf("\033[0;36m""  Type:    %s\n""\033[0m", "\033[0;32m"a[ 5 ]"\033[0m")
    printf("\033[0;36m""  Per:     %s\n""\033[0m", "\033[0;32m"a[ 6 ]"\033[0m")
    printf("\033[0;36m""  Acc:     %s\n""\033[0m", "\033[0;32m"a[ 7 ]"\033[0m")
    printf("\033[0;36m""  Modify:  %s\n""\033[0m", "\033[0;32m"a[ 8 ]"\033[0m")
    printf("\033[0;36m""  Create:  %s\n""\033[0m", "\033[0;32m"a[ 9 ]"\033[0m")
}
