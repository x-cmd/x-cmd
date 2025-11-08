BEGIN{
    skillid = ENVIRON[ "skillid" ]
}
(NR > 10) {
    exit(0)
}
{
    if (match($0, "^description: ")) {
        desc = substr($0, RSTART + RLENGTH)
        print skillid "\t" desc
        exit(0)
    }
}
