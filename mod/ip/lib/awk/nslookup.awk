$1=="Non-authoritative"{
    START = 1
}

(START==1)&&($1=="Name:"){
    # print $2
}


(START==1)&&($1=="Address:"){
    print $2
}
