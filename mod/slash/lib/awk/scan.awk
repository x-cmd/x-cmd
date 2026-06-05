BEGIN {
    FS = "\t"
    search_name = ENVIRON["SEARCH_NAME"]
    output_mode = ENVIRON["OUTPUT_MODE"]
    cfgfp = ENVIRON["CFGFP"]
    if (output_mode == "") output_mode = "all"

    # Load existing status from config file
    if (cfgfp != "") {
        while ((getline line < cfgfp) > 0) {
            if (line ~ /^[a-zA-Z0-9_-]+:$/) {
                sub(/:$/, "", line)
                cur_name = line
            } else if (line ~ /^  status:/) {
                sub(/^  status: /, "", line)
                if (cur_name != "") status[cur_name] = line
            }
        }
        close(cfgfp)
    }
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
        if (status[cmdname] == "disable") print "  status: disable"
        else print "  status: enable"
        print "  type: " type
    } else if (output_mode == "advise") {
        if (status[cmdname] == "disable") next
        # Extract description from YAML frontmatter
        desc = ""
        in_fm = 0
        while ((getline line < fp) > 0) {
            if (line ~ /^---$/) {
                if (in_fm) break
                in_fm = 1
                continue
            }
            if (!in_fm) break
            if (line ~ /^description:/) {
                sub(/^description:[ \t]*/, "", line)
                gsub(/^["']|["']$/, "", line)
                desc = line
                # Handle YAML multiline strings (| or >)
                if (desc == "|" || desc == ">") {
                    desc = ""
                    while ((getline line < fp) > 0) {
                        # Stop at end of frontmatter or next YAML key
                        if (line ~ /^---$/ || line ~ /^[a-zA-Z_][a-zA-Z0-9_]*:/) break
                        # Remove leading indentation
                        sub(/^[ \t]+/, "", line)
                        # Skip empty lines at the start of block
                        if (desc == "" && line == "") continue
                        # Concatenate into single line
                        if (desc == "") desc = line
                        else desc = desc " " line
                    }
                }
                break
            }
        }
        close(fp)
        # Use filepath when description is missing, empty, or YAML multiline marker
        if (desc == "" || desc == "|" || desc == ">") desc = fp
        # Escape colons in description to avoid breaking name:desc format
        gsub(/:/, "\\:", desc)
        print cmdname ":" desc
    } else {
        print cmdname "\t" type "\t" fp
    }
}
