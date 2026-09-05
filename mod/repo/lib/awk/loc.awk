BEGIN {
    if (ENVIRON["NO_COLOR"] != "") {
        BC = BY = BG = BD = RST = ""
    } else {
        E = "\033" "["
        BC = E "1;36m"
        BY = E "1;33m"
        BG = E "1;32m"
        BD = E "2m"
        RST = E "0m"
    }

    section = ""
    cur_lang = ""
    n_lang = 0
    stale = 0
    path = ""
    collected = ""
}

/^path: /        { path = substr($0, 7);      next }
/^collectedAt: / { collected = substr($0, 14); next }
/^stale: true$/  { stale = 1;                 next }

/^loc:$/   { section = "loc";   cur_lang = ""; next }
/^total:$/ { section = "total";                next }

section == "loc" {
    if (match($0, /^  [^ ].*:$/)) {
        cur_lang = substr($0, 3, RLENGTH - 3)
        lang[n_lang++] = cur_lang
    } else if (cur_lang != "" && match($0, /^    [a-zA-Z]+: /)) {
        key = substr($0, 5, RLENGTH - 6)
        v[cur_lang, key] = substr($0, RSTART + RLENGTH) + 0
    }
    next
}

section == "total" {
    if (match($0, /^  [a-zA-Z]+: /)) {
        key = substr($0, 3, RLENGTH - 4)
        tot[key] = substr($0, RSTART + RLENGTH) + 0
    }
    next
}

END {
    if (n_lang == 0) {
        print "  (no countable source found)"
        exit
    }

    maxlen = 8
    for (i = 0; i < n_lang; i++) {
        if (length(lang[i]) > maxlen) maxlen = length(lang[i])
    }
    rule = strrep("-", maxlen + 2 + 10 + 2 + 10 + 2 + 10 + 2 + 8)

    print ""
    if (path != "") {
        print BC "  " path RST
    }
    if (collected != "") {
        print BD "  collected " collected (stale ? "  (not refreshed; counted as-is on disk)" : "") RST
    }
    print ""

    printf "  " BY "%-" maxlen "s" RST "  " BY "%10s  %10s  %10s  %8s" RST "\n", \
        "language", "code", "comments", "blanks", "files"
    print "  " BD rule RST
    for (i = 0; i < n_lang; i++) {
        nm = lang[i]
        printf "  %-" maxlen "s  " BG "%10s  %10s  %10s  %8s" RST "\n", nm, \
            fmt(v[nm, "code"]), fmt(v[nm, "comments"]), fmt(v[nm, "blanks"]), fmt(v[nm, "files"])
    }
    print "  " BD rule RST
    printf "  %-" maxlen "s  " BG "%10s  %10s  %10s  %8s" RST "\n", "total", \
        fmt(tot["code"]), fmt(tot["comments"]), fmt(tot["blanks"]), fmt(tot["files"])
    print ""
}

function fmt(s,    out, i, len, c, n) {
    out = ""
    s = "" (s + 0)
    len = length(s)
    n = 0
    for (i = len; i >= 1; i--) {
        c = substr(s, i, 1)
        if (n > 0 && n % 3 == 0) out = "," out
        out = c out
        n++
    }
    return out
}

function strrep(s, n,    i, out) {
    out = ""
    for (i = 0; i < n; i++) out = out s
    return out
}
