# nameserver[0] : 114.114.114.114
#   nameserver[1] : 192.168.3.1
#   nameserver[2] : fd00:7860:5bac:de7a:7a60:5bff:feac:de7a

{
    if (match($1, /^nameserver\[/)){
        idx = int(substr($1, RSTART+RLENGTH))
        nameserver[idx] = $3
    }
}

END{
    for (i=0; i<=5; i++) {
        if (nameserver[i] == "") break
        printf("%s: %s\n", i, nameserver[i])
    }
}
