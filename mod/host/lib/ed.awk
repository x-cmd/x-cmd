NF == 0   { next; }
$1 ~ "^#" { next; }

BEGIN{
    L = "\001"
    split(args, oparr, " ")
    oparr[ L ] = length(oparr)

    # rmarr[]: 记录需要删除的项，如 -www.google.com
    # setarr[]: 记录需要修改/添加的项，如 hub.x-cmd.com=192.168.3.1
    n=0
    for (i = 1; i <= oparr[ L ]; i++) {
        op = oparr[ i ]
        if (op ~ "^-"){
            rmarr[ substr(op, 2) ] = 1
        } else {
            split( op, a, "=" )
            setarr_key[ n++ ] = a[1]
            setarr[ a[1] ] = a[2]
        }
    }
}

(rmarr[ $2 ]) {
    _modified = 1
    next
}

(setarr[ $2 ]) {
    _modified = 1
    next
}

{
    print
}

END{
    L = "\001"
    setarr_key[ L ] = length(setarr_key)
    for (i = 0; i < setarr_key[ L ]; i++) {
        printf("%s\t%s\n", setarr[ setarr_key[ i ] ], setarr_key[ i ])
    }
}