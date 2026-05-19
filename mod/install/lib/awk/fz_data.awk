BEGIN {
    FS = "\t"
    YELLOW = "\033[33m"
    GREEN  = "\033[32m"
    CYAN   = "\033[36m"
    BLUE   = "\033[34m"
    DIM    = "\033[2m"
    RST    = "\033[0m"
}


{
    name = $1
    rest = ""
    for (i = 2; i <= NF; i++) {
        if ($i == "") continue
        if      (i == 2) rest = rest " " GREEN  $i RST
        else if (i == 3) rest = rest " " CYAN   $i RST
        else if (i == 4) rest = rest " " BLUE   $i RST
        else if (i == 5) rest = rest " " DIM    $i RST
        else if (i == 6) rest = rest " " DIM    $i RST
        else             rest = rest " " DIM    $i RST
    }

    printf "%s%s%s%s\n", YELLOW, name, RST, rest
}
