
BEGIN{
    print "user,tty,host,timerange"
}

$0~"^reboot"{
    if ($2=="time"){
        user = $1 " " $2
        $1 = $2 = ""
        gsub("^ *","",$0)
        timerange = $0
    } else {
        user = $1
        pts = $2
        if ($3=="boot")     pts= $2 " " $3
        host = $4
        $1 = $2 = $3 = $4 = ""
        gsub("^ *","",$0)
        timerange = $0
    }
    print user "," pts "," host "," timerange
    next
}

$0~"^shutdown time"{
    user = $1 " " $2
    $1 = $2 = ""
    gsub("^ *","",$0)
    timerange = $0
}

$0==""{
    exit(0)
}

{
    user = $1
    pts = $2
    if ( length($3) != 3 ) {
        host = $3
        $3 = ""
    } else {
        if ( ($3 ~ /[A-Z][a-z][a-z]/) && ($4 ~ /[A-Z][a-z][a-z]/) ) {
            if ( $5 ~ /[1-9]+/ )  host = ""
        } else {
            host = $3
            $3 = ""
        }
    }
    $1 = $2 = ""
    gsub("^ *","",$0)
    timerange = $0
    print user "," pts "," host "," timerange
}


