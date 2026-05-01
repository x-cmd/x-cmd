NR>1{
    printf "\n%s\n%s\n", "+++", $1
    printf "{\"lang\":%s,\"homepage\":%s,\"desc\":{\"cn\":%s,\"en\":%s},\"rule\":%s}\n", jqu($3), jqu($4), jqu($5), jqu($6), $8
}