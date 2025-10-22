(NR > 10) {
    exit(0)
}
{
    if (match($0, "^description: ")) {
        name = FILENAME
        sub("/SKILL.md$", "", name)
        gsub(".*/", "", name)
        desc = substr($0, RSTART + RLENGTH)
        print name "\t" desc
        exit(0)
    }
}