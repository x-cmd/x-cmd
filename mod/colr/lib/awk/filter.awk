
BEGIN{
    if (criteria == "")     criteria = ENVIRON[ "criteria" ]
    carrl = split(criteria, carr, ",")
}

function meet( name,    j, e ){
    if (criteria != "") {
        for (j=1; j<=carrl; ++j){
            e = carr[j]
            if (e == "")  continue
            if (e ~ /^-/) {
                if (name ~ substr(e, 2))    return 0
                else if (name ~ e)          return 1
            }
            if (name ~ e)  return 1
        }
        return 0
    }
    return 1
}

END{
    for (i=0; i<=255; ++i) {
        if (meet( name0[i] ) == 0)   continue
        pcolorline( i )
        printf("\n")
    }
}
