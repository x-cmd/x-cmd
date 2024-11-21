
{
    word[ tolower($1) ] = $2
    word[ tolower($2) ] = $2
    word[ tolower($4) ] = $2

    original[ tolower($1) ] = $1
    original[ tolower($2) ] = $2
    original[ tolower($4) ] = $4

}

END{
    kwal = split( kws, kwa, "," )

    for (i=1; i<=kwal; ++i){
        kw = kwa[i]
        for (j in word) {
            if ( index( j, kw) > 0 ) {
                printf("%s %s\n", word[j], original[j])
                break
            }
        }
    }
}
