BEGIN {
    if (ENVIRON["NO_COLOR"] != "") {
        BC = BY = BG = BD = BR = RST = ""
    } else {
        E = "\033" "["
        BC = E "1;36m"
        BY = E "1;33m"
        BG = E "1;32m"
        BD = E "2m"
        BR = E "1;31m"
        RST = E "0m"
    }

    section = ""
    cur_check = ""
    n_check = 0
    overall = -1
    sc_date = ""
    repo_name = ""
    repo_commit = ""
    sc_version = ""
}

/^date: / {
    sub(/^date: "?/, "")
    sub(/"$/, "")
    sc_date = $0
    next
}

/^score: / {
    overall = substr($0, 8) + 0
    next
}

/^repo:$/     { section = "repo";     next }
/^scorecard:$/ { section = "scorecard"; next }
/^checks:$/   { section = "checks";   next }

section == "repo" {
    if (match($0, /^  name: /))   { repo_name   = substr($0, 9);  next }
    if (match($0, /^  commit: /)) { repo_commit = substr($0, 11); next }
}

section == "scorecard" {
    if (match($0, /^  version: /)) { sc_version = substr($0, 12); next }
}

section == "checks" {
    if (match($0, /^  - name: /)) {
        cur_check = substr($0, 11)
        check[n_check] = cur_check
        n_check++
    } else if (cur_check != "" && match($0, /^    score: /)) {
        check_score[cur_check] = substr($0, 12) + 0
    } else if (cur_check != "" && match($0, /^    reason: /)) {
        line = substr($0, 13)
        check_reason[cur_check] = (line == "null" || line == "~" || line == "") ? "" : line
    }
}

END {
    print ""
    print BC "  OpenSSF Scorecard" RST
    if (repo_name != "") {
        print BD "  " repo_name (repo_commit != "" ? "  (" substr(repo_commit, 1, 7) ")" : "") RST
    }
    if (sc_version != "" || sc_date != "") {
        line = ""
        if (sc_version != "") line = line "scorecard " sc_version
        if (sc_date != "")    line = line "  collected " sc_date
        print BD "  " line RST
    }
    if (overall >= 0) {
        col = (overall >= 7) ? BG : (overall >= 4) ? BY : BR
        printf "  Overall:           " col "%.1f / 10" RST "\n", overall
    }
    print ""

    if (n_check == 0) {
        print "  (no checks found)"
        exit
    }

    maxlen = 5
    for (i = 0; i < n_check; i++) {
        if (length(check[i]) > maxlen) maxlen = length(check[i])
    }

    printf "  " BY "%-" maxlen "s  %5s  %s" RST "\n", "check", "score", "reason"
    print "  " BD strrep("-", maxlen + 2 + 5 + 2 + 60) RST
    for (i = 0; i < n_check; i++) {
        nm = check[i]
        s = check_score[nm] + 0
        col = (s >= 7) ? BG : (s >= 4) ? BY : BR
        printf "  %-" maxlen "s  " col "%5d" RST "  %s\n", nm, s, check_reason[nm]
    }
    print ""
}

function strrep(s, n,    i, out) {
    out = ""
    for (i = 0; i < n; i++) out = out s
    return out
}
