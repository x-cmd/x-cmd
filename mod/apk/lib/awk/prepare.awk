
BEGIN{
    RS = "[\r]?\n"
}

function parse_iter( data, pkgname, tag ){
    r = ""
    while (1) {
        r = r $0 ""
        if (! getline)  break
        if ($0 == "")   break
    }

    data[ pkgname, tag ] = r
}

function parse(){
    while (getline) {
        if ($0 == "") break
        data[ data[ "L" ] ++ ] = pkgname = $1
        parse_iter( data, pkgname, "description" )

        if (! getline){ break; }; parse_iter( data, pkgname, "webpage" )
        if (! getline){ break; }; parse_iter( data, pkgname, "installed-size" )
        if (! getline){ break; }; parse_iter( data, pkgname, "depends-on" )
        if (! getline){ break; }; parse_iter( data, pkgname, "provide" )
        if (! getline){ break; }; parse_iter( data, pkgname, "auto-install-rule" )
        if (! getline){ break; }; parse_iter( data, pkgname, "license" )
    }
}

BEGIN{
    parse()
}

function rep( s, n,     i, r ){
    r = ""
    for (i=1; i<=n; ++i)    r = r s
    return r
}

END {
    print "end"
    l = data[ "L" ]
    print(l)

    fmt = rep( "%s\t", 7 ) "%s\n"

    printf( fmt, "name", "description", "webpage", "installed-size", "depends-on", "provide", "auto-install-rule", "license" )
    for (i=1; i<=l; ++i) {
        p = data[ i ]
        printf( fmt, p, data[ p, "description"], data[ p, "webpage"], data[ p, "installed-size"], data[ p, "depends-on"], data[ p, "provide"], data[ p, "auto-install-rule"], data[ p, "license"] )
    }
}
