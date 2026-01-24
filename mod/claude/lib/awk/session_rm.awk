BEGIN {
    FS = "|"

    C_RESET  = "\033[0m"
    C_DIM    = "\033[38;5;242m"
    C_TEXT   = "\033[38;5;253m"
    C_ACCENT = "\033[38;5;135m"
    C_SIZE   = "\033[38;5;240m"

    print ""
}

function truncate(str, max) {
    if (length(str) > max) return substr(str, 1, max-3) "..."
    return str
}

$1 == "META" {
    display = $2
    project = $3

    date_str = $4

    sub(ENVIRON["HOME"], "~", project)

    printf "  %s>%s Target Session  %s%s%s\n", C_ACCENT, C_RESET, C_TEXT, sid, C_RESET
    print ""

    printf "    %s%-9s%s %s\n", C_DIM, "Topic",   C_RESET, display
    printf "    %s%-9s%s %s\n", C_DIM, "Project", C_RESET, project
    printf "    %s%-9s%s %s\n", C_DIM, "Created", C_RESET, date_str

    print ""
    has_meta = 1
}

$1 == "FILE" {
    fpath = $2
    fsize = $3
    is_dir = $4

    display_name = fpath
    sub(ENVIRON["HOME"], "~", display_name)

    if (is_dir == "1") icon = "📂"
    else icon = "📄"

    file_count++
    rows[file_count] = sprintf("    %s  %s%-7s%s %s", icon, C_SIZE, fsize, C_RESET, display_name)
}

END {
    if (has_meta != 1) {
            print "  " C_DIM "Session ID not found in index." C_RESET
            print ""
    }

    if (file_count > 0) {
        for (i=1; i<=file_count; i++) {
            print rows[i]
        }
    } else {
        printf "    %s(No physical files)%s\n", C_DIM, C_RESET
    }
}
