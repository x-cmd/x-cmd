BEGIN{
    if (RAND_SEED == "") srand()
    else                 srand( RAND_SEED )

    EMAIL_PROVIDER_L = 5
    EMAIL_PROVIDER[1] = "@gmail.com"
    EMAIL_PROVIDER[2] = "@yahoo.com"
    EMAIL_PROVIDER[3] = "@x-cmd.com"
    EMAIL_PROVIDER[4] = "@qq.com"
    EMAIL_PROVIDER[5] = "@icloud.com"
}

function rand_int( s, e ){
    return int(rand() * (e-s+1)) + s
}

function rand_str(len, s, e,    i, r){
    if (len == "") len = 8
    if (s == "")   s = 33
    if (e == "")   e = 126
    r = ""
    for (i=1; i<=len; i++) {
        r = r sprintf("%c", rand_int(s, e))
    }
    return r
}

function rand_ip(){
    return rand_int(0, 255) "." rand_int(0, 255) "." rand_int(0, 255) "." rand_int(0, 255)
}

function rand_from_arr( arr, l ){
    return arr[ rand_int(1, l) ]
}

function rand_email(){
    return rand_str( rand_int(6, 20), 97, 122 ) rand_from_arr( EMAIL_PROVIDER, EMAIL_PROVIDER_L )
}

function rand_alphanum(len,    i, r, n){
    if (len == "") len = 8
    r = ""
    for (i=1; i<=len; i++) {
        n = rand_int(0, 61)
        if (n < 10)       r = r sprintf("%c", n + 48)       # 0-9
        else if (n < 36)  r = r sprintf("%c", n - 10 + 65)  # A-Z
        else              r = r sprintf("%c", n - 36 + 97)  # a-z
    }
    return r
}

function rand_alpha(len,    i, r, n){
    if (len == "") len = 8
    r = ""
    for (i=1; i<=len; i++) {
        n = rand_int(0, 51)
        if (n < 26)  r = r sprintf("%c", n + 65)   # A-Z
        else         r = r sprintf("%c", n - 26 + 97)  # a-z
    }
    return r
}

function rand_lower(len,    i, r){
    if (len == "") len = 8
    r = ""
    for (i=1; i<=len; i++) {
        r = r sprintf("%c", rand_int(97, 122))
    }
    return r
}

function rand_upper(len,    i, r){
    if (len == "") len = 8
    r = ""
    for (i=1; i<=len; i++) {
        r = r sprintf("%c", rand_int(65, 90))
    }
    return r
}

function rand_uuid(){

}

