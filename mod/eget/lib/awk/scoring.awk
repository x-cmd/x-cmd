#!/usr/bin/awk -f
# eget asset scoring — single-pass awk implementation.
#
# Run as: awk -f share.awk -f scoring.awk
#
# Reads one asset per line on stdin, TSV. Accepts both column orders
# (the integer column is the size):
#   name\turl\tsize\tdigest       (select_, lib/download:129)
#   name\tsize\turl                (seatrial snapshot)
#
# Writes the best-scoring asset (same TSV shape) to stdout, or exits 1
# if no asset reaches the score threshold.
#
# Scoring weights (override defaults from share.awk if needed):
#   STD_NAME_BONUS  = 100
#   OS_HIT          = 20
#   OS_MISS         = -20
#   ARCH_HIT        = 15
#   ARCH_MISS       = -15
#   HARD_CONFLICT   = -50    # OS hit AND arch miss: asset cannot run here
#   ARCHIVE_BONUS   = 5      # .tar.gz / .tgz / .tar.bz2 / .tar.xz / .tar / .zip
#   PYZ_BONUS       = 3      # .pyz (Python zipapp)
#   PKG_PENALTY     = -5     # .deb / .rpm (system package formats)
#   SIZE_BONUS      = 2      # file < SIZE_BONUS_MAX bytes
#   SIZE_BONUS_MAX  = 50000000
#   REPO_BONUS      = 3      # filename contains repo name
#   THRESHOLD       = 5

BEGIN {
    STD_NAME_BONUS  = 100
    OS_HIT           = 20
    OS_MISS          = -20
    ARCH_HIT         = 15
    ARCH_MISS        = -15
    HARD_CONFLICT    = -50    # OS hit AND arch miss: asset cannot run here
    WRONG_PLATFORM   = -50    # OS miss AND arch hit: wrong OS but right arch — same fatal class
    ARCHIVE_BONUS    = 5
    PYZ_BONUS        = 3
    PKG_PENALTY      = -5
    SIZE_BONUS       = 2
    SIZE_BONUS_MAX   = 50000000
    REPO_BONUS       = 3
    THRESHOLD        = 5

    best_score = -999999
    best_line  = ""
}

$1 == "tag" || NF == 0 { next }

{
    read_columns($0)
    name  = name       # propagate from helper
    lname = tolower(name)

    if (ends_with_any(lname, arr_skip, n_skip))     next
    if (is_skippable_source(lname, target_os))        next

    # .exe: Windows PE binary. PAR::Packer .exe projects (cloc,
    # copyparty, ssh-audit, …) ship only this form with no
    # OS/Arch token in the name — scoring would pick it on every
    # target (score = archive bonus? no + size + repo = 5,
    # just clears threshold), but a PE can't actually run on
    # darwin/linux without Mono. Skip on non-win targets; keep
    # on win target (Windows users run it directly).
    if (lname ~ /\.exe$/ && target_os != "win") next

    score = 0

    if (stdname_match(lname))                        score += STD_NAME_BONUS
    os_hit   = os_score(lname);                       score += os_hit
    arch_hit = arch_score(lname);                     score += arch_hit
    if (os_hit > 0 && arch_hit < 0)                   score += HARD_CONFLICT
    if (os_hit < 0 && arch_hit > 0)                   score += WRONG_PLATFORM

    if      (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) score += ARCHIVE_BONUS
    else if (lname ~ /\.pyz$/)                                     score += PYZ_BONUS
    else if (lname ~ /\.(deb|rpm)$/)                               score += PKG_PENALTY

    if (!filter_match(lname, target_filt)) next

    if (size ~ /^[0-9]+$/ && size + 0 > 0 && size + 0 < SIZE_BONUS_MAX) score += SIZE_BONUS

    if (target_repo != "" && index(lname, target_repo) > 0)            score += REPO_BONUS

    if (verbose) printf "  %-55s score=%d\n", name, score > "/dev/stderr"

    if (score > best_score) {
        best_score = score
        best_line  = name "\t" url "\t" size "\t" digest
    }
}

END {
    if (best_score >= THRESHOLD) {
        printf "%s\n", best_line
        exit 0
    }
    exit 1
}

# Standard naming: {repo}[-_]<anything>[-_]<os>[-_]<arch>.<ext>
function stdname_match(lname,    re) {
    re = "^" target_repo "[-_][^_/-]*[-_]" target_os "[-_]" target_arch "\\."
    return (lname ~ re)
}
