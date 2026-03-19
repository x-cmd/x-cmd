BEGIN {
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    RESET = "\033[0m"
}

{
    colr_enable = COLR

    if (colr_enable != "") {
        current_color = BLUE
        if ($0 ~ /^URL/ || $0 ~ /^Votes/ || $0 ~ /^Popularity/ || $0 ~ /^First Submitted/ ) {
            current_color = YELLOW
        }
        else if ($0 ~ /^Licenses/ || $0 ~ /^Maintainer/ || $0 ~ /^Last Modified/ ) {
            current_color = MAGENTA
        }
        else if ($0 ~ /^Description/) {
            current_color = GREEN
        }
        printf( "%s\n", current_color $0 RESET)
    } else {
        printf( "%s\n", $0)

    }
}
