#!/usr/bin/awk -f
# eget recommend — diagnostic fallback when strict scoring2 has no
# designed-for asset for the target platform.
#
# Run as: awk -f share.awk -f recommend.awk
#
# Computes for every asset (post-skip, post-filter):
#   - score_target: scoring weights against the user's current target
#     platform (STD_NAME_BONUS + OS_HIT/MISS + ARCH_HIT/MISS +
#     HARD_CONFLICT/WRONG_PLATFORM + ARCHIVE_BONUS + SIZE_BONUS +
#     REPO_BONUS). Same arithmetic as scoring.awk.
#   - max_platform / max_score: which of the 6 standard platforms
#     this asset scores highest on (the platform it was "designed for",
#     in scoring terms). Same per-(platform, asset) scoring as
#     scoring2.awk. Reused here not to enforce BISCORING — just to
#     tell the user what each top candidate was built for, so they
#     can decide whether their environment can run it (Rosetta 2 /
#     WoA / qemu-user, etc.).
#
# Output: one TSV line per surviving asset, sorted isn't done here:
#   score_target \t name \t max_platform \t max_score \t size
#
# The shell caller sorts by score_target desc and emits the top 3
# as copy-paste `x eget download` commands. The diagnostic is
# informational — it never auto-picks an asset, the user chooses.

BEGIN {
    target_os    = ENVIRON["AWK_OS"]
    target_arch  = ENVIRON["AWK_ARCH_NORM"]
    target_repo  = tolower(ENVIRON["AWK_REPO"])
    target_filt  = ENVIRON["AWK_FILTERS"]

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
    WRONG_PLATFORM = -50
    ARCHIVE_BONUS = 5
    PYZ_BONUS = 3
    PKG_PENALTY = -5
    SIZE_BONUS = 2; SIZE_BONUS_MAX = 50000000
    REPO_BONUS = 3
}

$1 == "tag" || NF == 0 { next }

{
    read_columns($0)
    name  = name
    lname = tolower(name)

    if (ends_with_any(lname, arr_skip, n_skip)) next
    if (target_filt != "" && !filter_match(lname, target_filt)) next

    # Same .exe skip as scoring.awk / scoring2.awk / map.awk —
    # keep all four aligned.
    if (lname ~ /\.exe$/ && target_os != "win") next

    # ---- score on target platform (single-platform scoring) ----
    score_target = 0
    if (stdname_match_for(lname, target_os, target_arch, target_repo)) \
        score_target += STD_NAME_BONUS

    os_hit_t   = os_score_for(lname, target_os);   score_target += os_hit_t
    arch_hit_t = arch_score_for(lname, target_arch); score_target += arch_hit_t
    if (os_hit_t > 0 && arch_hit_t < 0) score_target += HARD_CONFLICT
    if (os_hit_t < 0 && arch_hit_t > 0) score_target += WRONG_PLATFORM

    if      (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) score_target += ARCHIVE_BONUS
    else if (lname ~ /\.pyz$/)                                     score_target += PYZ_BONUS
    else if (lname ~ /\.(deb|rpm)$/)                               score_target += PKG_PENALTY

    if (size ~ /^[0-9]+$/ && size + 0 > 0 && size + 0 < SIZE_BONUS_MAX) score_target += SIZE_BONUS
    if (target_repo != "" && index(lname, target_repo) > 0)            score_target += REPO_BONUS

    # ---- max-platform (which platform was this asset designed for?) ----
    # Per-(platform, asset) scoring, same as scoring2.awk's pass-1.
    # Don't enforce BISCORING here — emit all surviving assets so
    # the shell caller can sort by score_target and pick top 3.
    #
    # IMPORTANT: a platform only "claims" this asset if it has a real
    # signal (OS or arch token hit/miss). Otherwise the asset is neutral
    # across all platforms (e.g. .apk / .deb / .rpm / .pkg.tar.zst —
    # platform-independent packages), and we leave max_plat="neutral"
    # instead of falsely attributing it to a random platform just
    # because its sp happened to exceed the initial -999999 floor
    # (those files get archive/size/repo bonuses that any platform
    # would credit equally).
    max_score = -999999
    max_plat  = "neutral"

    for (p = 1; p <= n_platforms; p++) {
        split(platforms[p], parts, "/")
        plat_os   = parts[1]
        plat_arch = parts[2]

        if (is_skippable_source(lname, plat_os)) continue

        oh = os_score_for(lname, plat_os)
        ah = arch_score_for(lname, plat_arch)
        # Signal: stdname match, or any OS/arch token hit/miss.
        has_signal = stdname_match_for(lname, plat_os, plat_arch, target_repo) \
                     || oh != 0 || ah != 0
        if (!has_signal) continue

        sp = 0
        if (stdname_match_for(lname, plat_os, plat_arch, target_repo)) sp += STD_NAME_BONUS
        sp += oh
        sp += ah
        if (oh > 0 && ah < 0) sp += HARD_CONFLICT
        if (oh < 0 && ah > 0) sp += WRONG_PLATFORM

        if      (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) sp += ARCHIVE_BONUS
        else if (lname ~ /\.pyz$/)                                     sp += PYZ_BONUS
        else if (lname ~ /\.(deb|rpm)$/)                               sp += PKG_PENALTY

        if (size ~ /^[0-9]+$/ && size + 0 > 0 && size + 0 < SIZE_BONUS_MAX) sp += SIZE_BONUS
        if (target_repo != "" && index(lname, target_repo) > 0)            sp += REPO_BONUS

        if (sp > max_score) { max_score = sp; max_plat = platforms[p] }
    }

    printf "%d\t%s\t%s\t%d\t%s\n", score_target, name, max_plat, max_score, size
}
