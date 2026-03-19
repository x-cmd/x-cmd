
function outputline(  dir,  o ){
    # comm
    # stat
    # status

    o[0] = 0

    while (getline < dir "/comm") {

    }

    while (getline < dir "/stat"){
        o[ "cpu" ] = ""
        # get the data and output to csv
    }

    # while (getline < dir "/status"){
    #     o[ "cpu" ] = ""
    #     # get the data and output to csv
    # }

    printf("%s,", o["cpu"])
}

{
    outputline( $0 )
}
