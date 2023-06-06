
function j2y_better_key( k ){
    if (k !~ /[:\t\n\v]/) {
        return juq(k)
    }
    return k
}

function j2y_list( obj, kp, indent,     l, i ){
    if ( (l = obj[ kp L ]) < 1) {   print "[]";  return;    }
    printf("%s", "- ")
    j2y_val( obj, kp SUBSEP "\"1\"" )
    for (i=2; i<=l; ++i) {
        printf("%s", indent "- ")
        j2y_val( obj, kp SUBSEP "\"" i "\"", indent "  " )
    }
}

# function DB( msg ){
#     print "<debug>:\t:" msg
# }

function j2y_dict( obj, kp, indent,     l, i ){
    if ( (l = obj[ kp L ]) < 1) {   print "{}";  return;    }

    k = obj[kp, 1 ]
    printf("%s", j2y_better_key(k) ": ")
    j2y_val( obj, kp SUBSEP k, indent "  " )
    for (i=2; i<=l; ++i) {
        k = obj[kp, i]
        if (obj[kp SUBSEP k] !~ "^[\\[\\{]$"){
            printf( "%s", indent j2y_better_key(k) ": " )
        } else {
            printf( "%s\n", indent j2y_better_key(k) ":" )
            printf( "%s", indent "  " )
        }

        j2y_val( obj, kp SUBSEP k, indent "  " )
    }
}

function j2y_val( obj, kp, indent,     l, i, v ){
    v = obj[ kp ]
    if (v == "{")           j2y_dict( obj, kp, indent )
    else if (v == "[")      j2y_list( obj, kp, indent )
    else                    print v
}

function j2y_all( obj, kp,              l, i ){
    l = obj[ kp L ]
    if (l < 1)  return
    # for (o in obj) print( o "\t|\t" obj[o] )

    j2y_val( obj, kp SUBSEP "\"" 1 "\"" )
    for (i=2; i<=l; ++i) {
        print "---"
        j2y_val( obj, kp SUBSEP "\""i"\"" )
    }
}
