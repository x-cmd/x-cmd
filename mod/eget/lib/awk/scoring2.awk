#!/usr/bin/awk -f
# eget scoring2 — BISCORING (bidirectional cross-platform scoring).
#
# Run as: awk -f share.awk -f scoring2.awk [<system>]
#
# Differs from scoring.awk:
#   scoring.awk picks, for the user's current system, the asset
#   with the highest score (single-platform weighted). It can
#   surface a score=5 "fallback" that isn't actually designed
#   for the target (e.g. h5i on darwin/amd64 picking a
#   Windows .zip because every asset is hard-conflict).
#
#   scoring2.awk scores every asset against each of the 6
#   platforms in one pass, picks each platform's best candidate
#   using the BISCORING rule:
#       asset counts as candidate for P iff
#       (a) score on P >= THRESHOLD
#       (b) score on P == asset's max across all 6 platforms
#           (the asset was DESIGNED for P — not a fallback)
#       (c) asset isn't arch-neutral (no OS/arch token hit,
#           e.g. py3-none-any .whl would otherwise masquerade
#           as a match for every platform because its
#           cross-platform max is itself).
#
#   Then selects the row for the user's current system and
#   prints its best-candidate line (or empty if P has no
#   designed-for asset).
#
# Reuses share.awk's tokens + helpers; OS_HIT / OS_MISS /
# ARCH_HIT / ARCH_MISS / STD_NAME_BONUS / HARD_CONFLICT /
# ARCHIVE_BONUS / SIZE_BONUS / REPO_BONUS / THRESHOLD are
# duplicated here so the algo is self-contained (share.awk
# only carries tokens + lowercase helpers).

BEGIN {
    target_os    = ENVIRON["AWK_OS"]
    target_arch  = ENVIRON["AWK_ARCH_NORM"]
    target_repo  = tolower(ENVIRON["AWK_REPO"])
    target_filt  = ENVIRON["AWK_FILTERS"]
    verbose      = (ENVIRON["AWK_VERBOSE"] == "1")

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
    THRESHOLD = 5
}

$1 == "tag" || NF == 0 { next }

{
    read_columns($0)
    name  = name
    lname = tolower(name)

    if (ends_with_any(lname, arr_skip, n_skip)) next
    if (target_filt != "" && !filter_match(lname, target_filt)) next

    # .exe: Windows PE binary. PAR::Packer projects (cloc,
    # copyparty, ssh-audit, …) ship only this form with no OS
    # token; without skipping, the +5 size / +3 repo bonus
    # would pass threshold across platforms. Same skip as
    # scoring.awk — keep the two algorithms aligned here.
    if (lname ~ /\.exe$/ && plat_os != "win") next

    line = name "\t" url "\t" size

    # Score this asset against each platform; track max across
    # platforms and per-(platform, asset) score for the END pass.
    for (p = 1; p <= n_platforms; p++) {
        split(platforms[p], parts, "/")
        plat_os   = parts[1]
        plat_arch = parts[2]

        if (is_skippable_source(lname, plat_os))    next

        score = 0
        if (stdname_match_for(lname, plat_os, plat_arch, target_repo)) \
            score += STD_NAME_BONUS

        os_hit   = os_score_for(lname, plat_os);   score += os_hit
        arch_hit = arch_score_for(lname, plat_arch); score += arch_hit
        if (os_hit > 0 && arch_hit < 0) score += HARD_CONFLICT
        if (os_hit < 0 && arch_hit > 0) score += WRONG_PLATFORM

        if      (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) score += ARCHIVE_BONUS
        else if (lname ~ /\.pyz$/)                                     score += PYZ_BONUS
        else if (lname ~ /\.(deb|rpm)$/)                               score += PKG_PENALTY

        if (size ~ /^[0-9]+$/ && size + 0 > 0 && size + 0 < SIZE_BONUS_MAX) score += SIZE_BONUS
        if (target_repo != "" && index(lname, target_repo) > 0)            score += REPO_BONUS

        # Composite key avoids 2D associative array (some
        # awk builds handle inconsistently).
        key = platforms[p] SUBSEP name
        ps_score[key] = score
        ps_line[key]  = line

        # Initialize on first hit. awk treats `unset > 35` as 0 (false),
        # so without `(name in asset_max)` the first comparison fails
        # silently and the slot is never seeded.
        if (!(name in asset_max) || score > asset_max[name]) \
            asset_max[name] = score

        # Mark arch-neutral assets (no OS or arch token hit).
        # These can't be "designed for" any specific platform,
        # so the bidirectional check would let them
        # masquerade as a match everywhere via the equal-max
        # condition. Exclude.
        if (os_hit == 0 && arch_hit == 0) asset_neutral[name] = 1
    }
}

END {
    # Walk every platform, find the asset with the highest
    # score on P where:
    #   - score[P][asset] == THRESHOLD
    #   - score[P][asset] == asset_max[asset]  (designed for P)
    #   - asset isn't arch-neutral
    # For target_os / target_arch, print its best line (or
    # nothing if P has no designed-for asset).

    best_score = -999999
    best_line  = ""
    for (name in asset_max) {
        if (asset_neutral[name]) continue
        # Match ps_score key format (platforms[p] uses "/" — not "\t").
        key = target_os "/" target_arch SUBSEP name
        s = ps_score[key]
        if (s >= THRESHOLD && s == asset_max[name] && s > best_score) {
            best_score = s
            best_line  = ps_line[key]
        }
    }

    if (best_score >= THRESHOLD && best_line != "") {
        printf "%s\n", best_line
        exit 0
    }

    # No designed-for asset on the target platform. Cross-arch
    # emulation (arm64 host running amd64 binary via Rosetta 2 /
    # WoA / qemu-user) is handled by the caller in shell, not here.

    if (best_score >= THRESHOLD && best_line != "") {
        printf "%s\n", best_line
        exit 0
    }

    # No designed-for asset on the target platform, and no
    # Rosetta-friendly fallback either.
    exit 1
}
