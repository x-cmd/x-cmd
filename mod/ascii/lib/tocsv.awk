NR==1{
    esc[ NR-1 ] = "^@"
}

NR<=27{
    esc[ NR-1 ] = "^" sprintf("%c", NR-1)
}
NR==128{
    esc[ NR-1 ] = "^?"
}

{
    if (match($1, /\^.$/)) {
        esc[ NR-1 ] = substr($1, RSTART)
        a[ NR-1 ] = substr($1, 1, RSTART-1)
    } else {
        a[ NR-1 ] = $1
    }

    zh[ NR-1 ] = ($2 == "") ? $1 : $2
    $1=""
    $2=""
    en[ NR-1 ] = ($0 == "") ? a[NR-1] : $0
}

function chr( o ){
    return sprintf("%c", 64 + o)
}

END {
    printf("%s,%s,%s,%s,%s,%s\n", "Dec", "Hex", "Oct", "ctrl",  "Acronym", "Description")
    for (i=0; i<=127; ++i) {
        CTRL = ((i>=1) && (i<=26)) ? ("ctrl-" chr(i)) : ""
        if (i==34)      a[i] = "\"\"\"\""
        else if (i==39) a[i] = "\"'\""
        DESC = (___X_CMD_WEBSRC_REGION == cn) ? zh[i] : en[i]
        printf( "%d,0x%02x,%03o,%s,%s,%s\n", i, i, i, CTRL, a[i], DESC )
    }
}
