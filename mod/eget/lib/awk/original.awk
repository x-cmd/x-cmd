#!/usr/bin/awk -f
# eget asset detection — original tier algorithm (zyedidia/eget style).
#
# Run as: awk -f share.awk -f original.awk
#
# Categorizes assets into tiers, not scored:
#   T1 matches:    OS + Arch both match
#   T2 candidates: OS matches (Arch may not)
#   T3 all:        everything (non-junk)
# Picks the narrowest tier with at least one entry; multiple in the
# same tier → prefer the one whose filename contains the repo name,
# else first-listed.

BEGIN {
    # Tier selection uses boolean matches, not weighted scores, so
    # override share.awk's defaults to 1/0 instead of 20/-20.
    OS_HIT  = 1
    OS_MISS = 0

    n_match = 0; n_cand = 0; n_all = 0
}

$1 == "tag" || NF == 0 { next }

{
    read_columns($0)
    name  = name
    lname = tolower(name)

    if (ends_with_any(lname, arr_skip, n_skip)) next
    if (is_skippable_source(lname))             next
    if (!filter_match(lname, target_filt))      next

    line = name "\t" url "\t" size "\t" digest

    # All (T3) — every non-junk, non-filtered asset.
    n_all++
    all_lines[n_all] = line

    if (os_score(lname) == 1) {
        n_cand++
        cand_lines[n_cand] = line
        if (arch_score(lname) == 1) {
            n_match++
            match_lines[n_match] = line
        }
    }
}

END {
    if (verbose) {
        printf "original: matches=%d candidates=%d all=%d\n", n_match, n_cand, n_all > "/dev/stderr"
    }

    # Pick the narrowest tier with results. Multi-match ties: prefer
    # one with the repo name in the filename; else first-listed.
    if (n_match == 1) {
        printf "%s\n", match_lines[1]; exit 0
    }
    if (n_match > 1) {
        chosen = pick_repo_named(match_lines, n_match)
        printf "%s\n", (chosen != "" ? chosen : match_lines[1]); exit 0
    }
    if (n_cand == 1) {
        printf "%s\n", cand_lines[1]; exit 0
    }
    if (n_cand > 1) {
        chosen = pick_repo_named(cand_lines, n_cand)
        printf "%s\n", (chosen != "" ? chosen : cand_lines[1]); exit 0
    }
    if (n_all >= 1) {
        chosen = pick_repo_named(all_lines, n_all)
        printf "%s\n", (chosen != "" ? chosen : all_lines[1]); exit 0
    }

    exit 1
}

# Among lines[] of length n, return the first whose filename contains
# target_repo (case-insensitive). Empty string if none.
function pick_repo_named(lines, n,    i, ln) {
    if (target_repo == "") return ""
    for (i = 1; i <= n; i++) {
        ln = tolower(lines[i])
        if (index(ln, target_repo) > 0) return lines[i]
    }
    return ""
}
