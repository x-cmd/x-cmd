# card.awk - x repo card YAML -> colored TTY display
#
# Reads the YAML output of `x repo card` on stdin and renders a
# colored, table-formatted view. recent: is shown as a table
# with windows as columns and metrics as rows.
#
# Color palette (ANSI):
#   bold cyan   section headers / repo name
#   bold yellow dates / windows
#   bold green  numbers
#   dim         separator lines
#   reset       end of color
#
# Set NO_COLOR env to disable color output (e.g. CI logs).
#
# Implementation note: `RS` is awk's built-in record-separator variable,
# so naming the reset color constant `RS` collides — awk treats its
# value as a regex, so `RS = "\033[0m"` becomes an unterminated `[0m]`
# character class. The constants are named `RST` (reset) / `BC` / `BY`
# / `BG` / `BD` to avoid that. The escape itself is still built
# indirectly (`E = "\033" "["`) so `[` never appears as a literal
# character in source.

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

    section   = ""
    in_window = ""

    g_sub["description"]  = ""
    g_sub["license"]      = ""
    g_sub["homepage"]     = ""
    g_sub["head"]         = ""
    g_sub["created"]      = ""
    g_sub["lastCommit"]   = ""
    g_sub["lastRelease"]  = ""
    g_sub["latestVersion"] = ""
    g_sub["archived"]     = "false"
    g_sub["star"]         = "0"
    g_sub["watcher"]      = "0"
    g_sub["fork"]         = "0"
    g_sub["release"]      = "0"
    g_sub["contributor"]  = "0"
    g_sub["pullRequest"]  = "0"
    g_sub["issue"]        = "0"
    g_sub["collectedAt"] = ""

    lang_count = 0

    recent_windows = ""
    n_windows = 0
}

/^about:$/      { section = "about";       next }
/^timeline:$/   { section = "timeline";    next }
/^popularity:$/ { section = "popularity";  next }
/^language:$/   { section = "language";    next }
/^recent:$/     { section = "recent"
                   in_window = ""
                   next
                 }
/^graphqlErrors:/ { next }
/^  - /          { next }

section == "about" {
    # description: literal block scalar `|` from card_yaml. The header
    # line is `  description:` followed by `  |` on the next line, then
    # each continuation line indented 4 spaces. Collect continuation
    # lines until we hit a line at the parent (2-space) indent — that
    # terminates the block and the line is the next key.
    if ($0 == "  description:") {
        in_desc = 1
        desc_lines = ""
        next
    }
    if (in_desc) {
        if (match($0, /^    /)) {
            line = substr($0, 5)   # strip 4-space indent
            desc_lines = (desc_lines == "" ? line : desc_lines "\n" line)
            next
        } else {
            # Out of block. Trim YAML's trailing newline and store.
            sub(/\n$/, "", desc_lines)
            g_sub["description"] = desc_lines
            in_desc = 0
            # Fall through to handle this line as a normal key.
        }
    }
    # license, homepage, head, archived, latestVersion, collectedAt
    if (match($0, /^  [a-zA-Z][a-zA-Z0-9]*: /)) {
        key = substr($0, 3, RLENGTH - 4)
        val = substr($0, RSTART + RLENGTH)
        if (key in g_sub) {
            gsub(/^"|"$/, "", val)
            g_sub[key] = val
        }
    }
    next
}

section == "timeline" {
    # created, lastCommit, lastRelease, latestVersion
    if (match($0, /^  [a-zA-Z][a-zA-Z0-9]*: /)) {
        key = substr($0, 3, RLENGTH - 4)
        val = substr($0, RSTART + RLENGTH)
        if (key in g_sub) {
            gsub(/^"|"$/, "", val)
            g_sub[key] = val
        }
    }
    next
}

section == "popularity" {
    # star, watcher, fork, release, contributor, pullRequest, issue
    # archived comes through here too; it's `true` / `false` unquoted in YAML.
    if (match($0, /^  [a-zA-Z][a-zA-Z0-9]*: /)) {
        key = substr($0, 3, RLENGTH - 4)
        val = substr($0, RSTART + RLENGTH)
        if (key in g_sub) {
            gsub(/^"|"$/, "", val)
            g_sub[key] = val
        }
    }
    next
}

section == "language" {
    # Accept both `"Name": N` (quoted, the card_yaml form) and bare `Name: N`
    # so a future change in card_yaml quoting style doesn't silently drop
    # the whole LANGUAGES section. The leading 1-space prefix between `"`
    # and `:` skips past the quote so substr(3, RLENGTH-4) still isolates
    # the bare language name.
    if (match($0, /^  "?[A-Za-z0-9+._ -]+"?: /)) {
        # Position of `:` in the match: if the line has a quoted key
        # (`"Name": N`), the match ends one char past `:` so val is " N",
        # and the trim has to account for that. For bare keys the trim is
        # the same — the difference is the key string itself, which we
        # extract from position 3 (after the two leading spaces).
        lang_name[lang_count] = $0
        sub(/^  "?/, "", lang_name[lang_count])
        sub(/"?[ \t]*:.*$/, "", lang_name[lang_count])
        lang_bytes[lang_count] = $0
        sub(/.*: */, "", lang_bytes[lang_count])
        lang_bytes[lang_count] = lang_bytes[lang_count] + 0
        lang_count++
    } else if (match($0, /^totalBytes: /)) {
        total_line = substr($0, RSTART + RLENGTH) + 0
    }
    next
}

{
    if (match($0, /^  last[0-9]+[a-z]:$/)) {
        win = substr($0, 3, RLENGTH - 3)
        in_window = win
        n_windows++
        recent_windows = (recent_windows == "" ? win : recent_windows "|" win)
    } else if (in_window != "" && match($0, /^    [a-zA-Z]+: /)) {
        key = substr($0, 5, RLENGTH - 6)
        val = substr($0, RSTART + RLENGTH) + 0
        win_metric[in_window, key] = val
    }
    next
}

END {
    n = BC "=============================================================" RST
    print ""
    print n
    print BC "  " g_sub["description"] " / " (g_sub["license"] != "NOASSERTION" ? g_sub["license"] : "") RST
    print n
    print ""

    print BC "  ABOUT" RST
    print "      License:       " (g_sub["license"] != "NOASSERTION" ? g_sub["license"] : "-")
    print "      Homepage:      " (g_sub["homepage"] == "" ? "-" : g_sub["homepage"])
    ver = g_sub["latestVersion"]
    if (ver != "") {
        print "      Latest ver:    " ver
    }
    if (g_sub["head"] != "") {
        print "      Head:          " g_sub["head"]
    }
    if (g_sub["collectedAt"] != "") {
        print BD "      Collected:     " g_sub["collectedAt"] RST
    }
    print ""

    print BC "  TIMELINE" RST
    print "      Created:       " BY g_sub["created"]            RST
    print "      Last commit:   " BY g_sub["lastCommit"]         RST
    print "      Last release:  " BY g_sub["lastRelease"]        RST
    print ""

    print BC "  POPULARITY" RST
    print "      Stars:        " BG fmt(g_sub["star"])        RST
    print "      Watchers:     " BG fmt(g_sub["watcher"])     RST
    print "      Forks:        " BG fmt(g_sub["fork"])        RST
    print "      Releases:     " BG fmt(g_sub["release"])     RST
    print "      Contributors: " BG fmt(g_sub["contributor"]) RST
    print "      Pull reqs:    " BG fmt(g_sub["pullRequest"]) RST
    print "      Issues:       " BG fmt(g_sub["issue"])       RST
    if (g_sub["archived"] == "true") {
        print "      " BC "ARCHIVED" RST
    }
    print ""

    if (lang_count > 0) {
        print BC "  LANGUAGES" RST
        maxlen = 0
        for (i = 0; i < lang_count; i++) {
            if (length(lang_name[i]) > maxlen) maxlen = length(lang_name[i])
        }
        for (i = 0; i < lang_count; i++) {
            pct = (total_line > 0) ? (lang_bytes[i] * 100.0 / total_line) : 0
            printf "      %-" maxlen "s  " BG "%10d bytes" RST "  " BD "%5.1f%%" RST "\n", lang_name[i], lang_bytes[i], pct
        }
        print ""
    }

    if (n_windows > 0) {
        print BC "  RECENT ACTIVITY" RST
        n = split(recent_windows, ws, "|")
        n_metrics = split("release|mergedPR|openPR|closedIssue|openIssue|commit", metric_list, "|")
        maxwinlen = 0
        for (i = 1; i <= n; i++) {
            if (length(ws[i]) > maxwinlen) maxwinlen = length(ws[i])
        }
        maxmetriclen = 0
        for (m = 1; m <= n_metrics; m++) {
            if (length(metric_list[m]) > maxmetriclen) maxmetriclen = length(metric_list[m])
        }
        # Header row: row-label cell "window" + each metric as a column header
        printf "      " BY "%-" maxwinlen "s" RST "  ", "window"
        for (m = 1; m <= n_metrics; m++) {
            printf "  " BY "%" maxmetriclen "s" RST, metric_list[m]
        }
        print ""
        print "      " BD strrep("-", maxwinlen + 2 + n_metrics * (maxmetriclen + 2)) RST
        # Data rows: one per window, with values for each metric column
        for (i = 1; i <= n; i++) {
            printf "      %-" maxwinlen "s  ", ws[i]
            for (m = 1; m <= n_metrics; m++) {
                v = win_metric[ws[i], metric_list[m]] + 0
                printf "  " BG "%" maxmetriclen "d" RST, v
            }
            print ""
        }
        print ""
    }

    print ""
}

function fmt(s,    out, i, len, c, n) {
    # Walk right-to-left; after every 3 digits seen from the right,
    # prepend a comma before the next digit. The earlier version
    # walked left-to-right while prepending (which both reversed the
    # digits and placed the comma one step early), so e.g. "35485"
    # came out as "584,53" instead of "35,485".
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
