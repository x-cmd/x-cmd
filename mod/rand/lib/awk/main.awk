
BEGIN {

    if ( SUBCMD == "email" ) {
        for (i=1; i<=COUNT; ++i)    print rand_email()
    } else if ( SUBCMD == "str" ) {
        for (i=1; i<=COUNT; ++i)    print rand_str( ARG1 )
    } else if ( SUBCMD == "ip" ) {
        for (i=1; i<=COUNT; ++i)    print rand_ip()
    } else if ( SUBCMD == "alphanum" ) {
        for (i=1; i<=COUNT; ++i)    print rand_alphanum( ARG1 )
    } else if ( SUBCMD == "alpha" ) {
        for (i=1; i<=COUNT; ++i)    print rand_alpha( ARG1 )
    } else if ( SUBCMD == "lower" ) {
        for (i=1; i<=COUNT; ++i)    print rand_lower( ARG1 )
    } else if ( SUBCMD == "upper" ) {
        for (i=1; i<=COUNT; ++i)    print rand_upper( ARG1 )
    }

}

