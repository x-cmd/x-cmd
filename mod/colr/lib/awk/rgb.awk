
function regulate(e){
    if (e ~ "[%]$") {
        return int(substr(e, 1, length(e) - 1)) * 255 / 100
    }
    return int(e)
}

BEGIN{
    epsilon = ENVIRON[ "X_epsilon" ]
    if (epsilon == "")  epsilon = 25
    print "Using epsilon = " epsilon

    if (criteria == "")     criteria = ENVIRON[ "criteria" ]
    carrl = split(criteria, carr, ",")
    carr[1] = regulate(carr[1])
    carr[2] = regulate(carr[2])
    carr[3] = regulate(carr[3])

    printf("rgb: %s %s %s\n", carr[1], carr[2], carr[3])
}

function dist(a, b, c,      e ) {
    e = a * a + b * b + c * c
    return sqrt( e / 3 )
}

function meet( i,    e ){
    return dist(r[i] - carr[1], g[i] - carr[2], b[i] - carr[3])
}

END{
    for (i=0; i<=255; ++i) {
        e = meet( i )
        if (e > epsilon) continue
        if (e < 1) {
            printf("\033[4;1m")
            pcolorline( i )
            printf(" === %s \n", e)
        } else {
            pcolorline( i )
            printf(" ~~~ %3.2f%% \n", e * 100 / 255)
        }
    }
}
