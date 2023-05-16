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

END {
    printf("%s\t%s\t%s\t%s\n", "Hex", "Oct", "Char/Acronym", "Description")
    for (i=0; i<=127; ++i) {
        if (___X_CMD_WEBSRC_REGION == cn){
            printf("0x%02x\t%03o\t%-10s\t%s\n", i, i, a[i], zh[i])
        } else {
            printf("0x%02x\t%03o\t%-10s\t%s\n", i, i, a[i], en[i])
        }
    }
}
