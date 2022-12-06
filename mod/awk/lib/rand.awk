BEGIN{
    if (RAND_SEED == "") srand()
    else                 srand( RAND_SEED )
}

function rand_int( s, e ){

}

function rand_str(){

}

function rand_ip(){
    return rand_int(0, 255) "." rand_int(0, 255) "." rand_int(0, 255) "." rand_int(0, 255)
}

function rand_uuid(){

}

