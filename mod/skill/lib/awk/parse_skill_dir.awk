{
    folder_path = $0

    # Extract name from folder path (last component)
    # Remove trailing slash
    if (folder_path ~ /\/$/) {
        folder_path = substr(folder_path, 1, length(folder_path) - 1)
    }

    n = split(folder_path, parts, "/")
    name = parts[n]

    skill_md = folder_path "/SKILL.md"
    description = ""

    while ((getline line < skill_md) > 0) {
        if (tolower(line) ~ /^description:[ \t]*[|>][+-]?[ \t]*$/) {
            # Multi-line description using YAML block scalar
            # Extract block scalar indicator and the line up to it
            if (match(line, /[|>][+-]?[ \t]*$/)) {
                desc_part = substr(line, 1, RSTART - 1)
                block_ind = substr(line, RSTART, RLENGTH)
            }
            description = toupper(substr(desc_part, 1, 1)) substr(desc_part, 2) block_ind

            while ((getline line < skill_md) > 0) {
                # Continuation: empty line or whitespace-starting line
                if (line ~ /^$/ || line ~ /^[ \t]/) {
                    description = description "\n" line
                } else {
                    break
                }
            }
            break
        } else if (tolower(line) ~ /^description:[ \t]*/) {
            sub(/^[^:]+:[ \t]*/, "", line)
            gsub(/^"|"$/, "", line)
            description = line
            break
        }
    }
    close(skill_md)

    if (description == "") {
        next
    }

    print "---"
    printf "Name: %s\n", name
    printf "SKILL Path: %s\n", skill_md
    printf "Folder Path: %s\n", folder_path
    printf "Description: %s\n", description
}
