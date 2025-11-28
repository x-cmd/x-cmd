BEGIN {
    c_key    = "\033[1;33m"
    c_val    = "\033[0;37m"
    c_special = "\033[1;36m"
    c_reset  = "\033[0m"
    c_highlight = "\033[1;32m"
}
NR == 1 {
    for (i=1;i<=NF;i++) header[i]=$i
    next
}
$1 == id {
    # Main info section
    print c_key "ID:" c_reset "          " c_val $1 c_reset
    print c_key "Name:" c_reset "        " c_val $5 c_reset
    print c_key "Author:" c_reset "      " c_val $6 c_reset
    print c_key "License:" c_reset "     " c_val $4 c_reset
    print ""

    # Description section
    print c_key "Description:" c_reset
    print c_val wrap_text($7, 70) c_reset
    print ""

    # URLs section
    print c_key "URL:" c_reset
    print c_val $2 c_reset

    if ($3 != "") {
        print c_key "Reference:" c_reset
        print c_val $3 c_reset
    }
}

function wrap_text(text, width,     result, words, i, line, word) {
    if (length(text) <= width) return text

    split(text, words, " ")
    line = ""
    result = ""

    for (i = 1; i <= length(words); i++) {
        word = words[i]
        if (length(line) + length(word) + 1 > width) {
            if (result != "") result = result "\n"
            result = result line
            line = word
        } else {
            if (line != "") line = line " "
            line = line word
        }
    }

    if (line != "") {
        if (result != "") result = result "\n"
        result = result line
    }

    return result
}