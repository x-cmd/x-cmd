
BEGIN{
    FS = "\t"
}

{
    id      = $1
    pop     = $2
    vote    = $3
    name    = $4
    version = $5
    desc    = $6

    outofdate = $7

    maintainer = $8
    submitter = $9

    first = $10
    modified = $11

    url = $12
    baseid= $13
    base = $14
    urlpath = $15

    if (max_pop < pop)  max_pop = pop

    if ( pop == 0 ) {
        s0 += 1
    } else if ( pop < 0.01 ) {
        s1 += 1
    } else if ( pop < 0.1 ) {
        s2 += 1
    } else if ( pop < 1 ) {
        s3 += 1
    } else if ( pop < 2 ) {
        s4 += 1
    } else if ( pop < 5 ) {
        s5 += 1
    } else {
        s6 += 1
    }

}

END{

    printf("MaxPop            : %15.6f\n\n", max_pop )

    printf("%s : %8d\n", "[ 5.    , +∞    )"   , s6 )
    printf("%s : %8d\n", "[ 2.    , 5     )"   , s5 )
    printf("%s : %8d\n", "[ 1.    , 2     )"   , s4 )
    printf("%s : %8d\n", "[ 0.1   , 1     )"   , s3 )
    printf("%s : %8d\n", "[ 0.01  , 0.1   )"   , s2 )
    printf("%s : %8d\n", "[ 0.001 , 0.01  )"   , s1 )
    printf("%s : %8d\n", "[ 0     , 0.001 )"   , s0 )

    printf("\nTotal             : %8d\n", NR )

}
