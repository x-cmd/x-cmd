BEGIN {
    FS = "\t"
    search_name = ENVIRON["SEARCH_NAME"]
    output_mode = ENVIRON["OUTPUT_MODE"]
    if (output_mode == "") output_mode = "all"
}

{
    type = $1
    fp = $2

    # Extract basename without .md
    n = split(fp, arr, "/")
    basename = arr[n]
    sub(/\.md$/, "", basename)

    if (type == "command") {
        cmdname = basename
    } else {
        # skill: read YAML frontmatter for trigger
        trigger = ""
        in_fm = 0
        while ((getline line < fp) > 0) {
            if (line ~ /^---$/) {
                if (in_fm) break
                in_fm = 1
                continue
            }
            if (!in_fm) break
            if (line ~ /^trigger:/) {
                sub(/^trigger:[ \t]*/, "", line)
                gsub(/^["']|["']$/, "", line)
                trigger = line
                break
            }
        }
        close(fp)
        if (trigger == "") {
            if (basename == "SKILL" && n >= 2) trigger = arr[n-1]
            else trigger = basename
        }
        sub(/^\//, "", trigger)
        cmdname = trigger
    }

    if (search_name != "" && cmdname != search_name) next
    if (seen[cmdname]++) next

    if (output_mode == "path") {
        print fp
        if (search_name != "") exit 0
    } else if (output_mode == "yml") {
        print cmdname ":"
        print "  fp: " fp
        print "  status: enable"
        print "  type: " type
    } else {
        print cmdname "\t" type "\t" fp
    }
}
