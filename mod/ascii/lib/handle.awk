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
    printf("%s\t%s\t%s\t%10s\t%-10s\t%s\n", "Dec", "Hex", "Oct", "ctrl",  "Acronym", "Description")
    for (i=0; i<=127; ++i) {
        CTRL = ((i>=1) && (i<=26)) ? ("ctrl-" chr(i)) : "     "

        if (___X_CMD_WEBSRC_REGION == cn){
            printf("%d\t0x%02x\t%03o\t%10s\t%-10s\t%s\n", i, i, i, CTRL, a[i], zh[i])
        } else {
            printf("%d\t0x%02x\t%03o\t%10s\t%-10s\t%s\n", i, i, i, CTRL, a[i], en[i])
        }
    }
}
