#!/usr/bin/awk -f
# eget lsassetmap — bidirectional-match per-platform best candidate.
#
# Run as: awk -f share.awk -f map.awk
#
# Algorithm:
#   1. For each asset × platform, compute the score (single pass).
#   2. Track each asset's max score across all 6 platforms
#      ("which platform was it designed for?").
#   3. For each platform, find the asset whose:
#        (a) score on this platform >= THRESHOLD
#        (b) its cross-platform max score == score on this platform
#      — i.e. bidirectional match: the asset was DESIGNED for
#      this platform. Pick the highest-scoring such asset.
#
# Output: 6 rows of TSV (one per platform, in fixed order):
#   platform\t<name>\t<url>\t<size>\t<score>
# Empty platform (no asset designed for it) emits a row with
# only the platform column populated.
#
# Why bidirectional: the previous version scored each platform
# independently and surfaced 5-score "fallbacks" — e.g. h5i on
# darwin/amd64 picked a Windows .zip because every asset was
# hard-conflict, but no asset was actually designed for that
# platform. The bidirectional check rules those out: the
# fallback's max-across-platforms is somewhere else, so it
# doesn't count as a candidate here.

BEGIN {
    target_repo = tolower(ENVIRON["AWK_REPO"])
    target_filt = ENVIRON["AWK_FILTERS"]

    n_platforms = 6
    platforms[1] = "darwin/arm64"
    platforms[2] = "darwin/amd64"
    platforms[3] = "linux/arm64"
    platforms[4] = "linux/amd64"
    platforms[5] = "win/arm64"
    platforms[6] = "win/amd64"

    OS_HIT = 20; OS_MISS = -20
    ARCH_HIT = 15; ARCH_MISS = -15
    STD_NAME_BONUS = 100
    HARD_CONFLICT = -50
    SOFT_CROSS_ARCH = -25
    WRONG_PLATFORM = -50
    ARCHIVE_BONUS = 5
    PYZ_BONUS = 3
    PKG_PENALTY = -5
    SIZE_BONUS = 2; SIZE_BONUS_MAX = 50000000
    REPO_BONUS = 3
    THRESHOLD = 5
}

$1 == "tag" || NF == 0 { next }

{
    read_columns($0)
    name  = name
    lname = tolower(name)

    if (ends_with_any(lname, arr_skip, n_skip)) next
    if (target_filt != "" && !filter_match(lname, target_filt)) next

    # .exe: Windows PE binary. PAR::Packer projects ship only
    # this form; without skipping, scoring2 would pick it
    # across non-win platforms (size + repo bonus pass threshold).
    # Same skip as scoring.awk — keep the two aligned.
    if (lname ~ /\.exe$/ && target_os != "win") next

    line = name "\t" url "\t" size

    # Score this asset against each of the 6 platforms.
    for (p = 1; p <= n_platforms; p++) {
        split(platforms[p], parts, "/")
        target_os   = parts[1]
        target_arch = parts[2]

        if (is_skippable_source(lname, target_os)) next

        score = 0
        if (stdname_match_for(lname, target_os, target_arch, target_repo)) \
            score += STD_NAME_BONUS

        os_hit   = os_score_for(lname, target_os);   score += os_hit
        arch_hit = arch_score_for(lname, target_arch); score += arch_hit
        # OS hit + arch miss is asymmetric: arm64 hosts (Apple
        # Silicon, WoA, qemu-user on Linux ARM) can emulate amd64
        # binaries; amd64 hosts can't emulate arm64. Pick the
        # penalty direction-dependent.
        if (os_hit > 0 && arch_hit < 0) {
            if (target_arch == "arm64") score += SOFT_CROSS_ARCH
            else                       score += HARD_CONFLICT
        }
        if (os_hit < 0 && arch_hit > 0) score += WRONG_PLATFORM

        if      (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) score += ARCHIVE_BONUS
        else if (lname ~ /\.pyz$/)                                     score += PYZ_BONUS
        else if (lname ~ /\.(deb|rpm)$/)                               score += PKG_PENALTY

        if (size ~ /^[0-9]+$/ && size + 0 > 0 && size + 0 < SIZE_BONUS_MAX) score += SIZE_BONUS
        if (target_repo != "" && index(lname, target_repo) > 0)            score += REPO_BONUS

        # Composite key per (platform, asset) — avoid 2D associative arrays
        # which some awk builds (mawk, BSD awk) handle inconsistently.
        key = platforms[p] SUBSEP name
        ps_score[key] = score
        ps_line[key]  = line

        # Track each asset's max score across all platforms — the
        # platform that asset was "designed for" in scoring terms.
        if (!(name in asset_max) || score > asset_max[name]) \
            asset_max[name] = score

        # An asset that hits NEITHER an OS token nor an arch token
        # (e.g. py3-none-any .whl, or a generic shell script) is
        # "neutral" — it's not designed for any specific platform.
        # Without excluding these, the bidirectional check would
        # say a .whl is "the best for darwin/amd64" simply because
        # its cross-platform max is itself (5, on every platform).
        # That defeats the diagnostic intent. Mark such assets.
        if (os_hit == 0 && arch_hit == 0) asset_neutral[name] = 1
    }
}

END {
    for (p = 1; p <= n_platforms; p++) {
        plat = platforms[p]
        best_score = -999999
        best_line  = ""

        # Walk every asset: candidate for plat only if its max
        # across platforms is on plat (asset was designed for
        # this platform) AND it clears the threshold. Exclude
        # neutral assets — they don't count as a real match for
        # any platform.
        for (name in asset_max) {
            if (asset_neutral[name]) continue
            key = plat SUBSEP name
            s = ps_score[key]
            if (s >= THRESHOLD && s == asset_max[name] && s > best_score) {
                best_score = s
                best_line  = ps_line[key]
            }
        }

        if (best_score >= THRESHOLD && best_line != "") {
            printf "%s\t%s\t%d\n", plat, best_line, best_score
        } else {
            printf "%s\t\t\t\n", plat
        }
    }
}
