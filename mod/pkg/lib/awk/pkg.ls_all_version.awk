BEGIN{
    OSARCH = "\"" ENVIRON[ "osarch" ] "\""
}

(O[2] == OSARCH ){
    cur_version = juq(O[1])
    if ( juq(O[1]) != last_version) print cur_version
    last_version = cur_version
}