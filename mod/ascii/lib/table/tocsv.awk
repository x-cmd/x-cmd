BEGIN{
    DELIMETER = ENVIRON["DELIMETER"]
    if (DELIMETER=="")  DELIMETER = ","
}

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
    desc_en = str_trim_left($0)
    en[ NR-1 ] = (desc_en == "") ? a[NR-1] : desc_en
}

function chr( o ){
    return sprintf("%c", 64 + o)
}

END {
    printf("%s" DELIMETER "%s" DELIMETER "%s" DELIMETER "%s" DELIMETER "%s" DELIMETER "%s", "Dec", "Oct", "Hex", "Ctrl",  "Acronym", "Description")
    if (lang == "zh") printf(DELIMETER "%s\n", "Description-zh")
    else printf "\n"

    if (topic == "all")          range = re_range(0, 127)
    else if (topic == "dev")     range = re_range(0, 31)
    else if (topic == "ctrl")    range = re_range(0, 26)
    else if (topic == "num")     range = re_range(48, 57)
    else if (topic == "upper")   range = re_range(65, 90)
    else if (topic == "lower")   range = re_range(97, 122)
    else if (topic == "letter")  range = re_range(65, 90) "|" re_range(97, 122)

    for (i=0; i<=127; ++i) {
        if (! match(i, "^"range"$")) continue
        CTRL = ((i>=1) && (i<=26)) ? ("ctrl-" chr(i)) : ""
        if (i==34)          en[i] = a[i] = "\"\"\"\""
        else if (i==39)     en[i] = a[i] = "\"'\""
        else if (i==44)     en[i] = a[i] = "\",\""
        DESC_ZH = zh[i]
        DESC_EN = en[i]
        printf( "%d " DELIMETER "%03o" DELIMETER "0x%02x" DELIMETER "%s" DELIMETER "%s" DELIMETER "%s", i, i, i, CTRL, a[i], DESC_EN )
        if (lang == "zh") printf(DELIMETER "%s\n", DESC_ZH)
        else printf "\n"
    }
}
