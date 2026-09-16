
# eget assetfit — per-asset fit label view.
#
# Sibling of map.awk: map.awk scores (asset, platform) pairs and
# emits the best asset per slot. This script scores (asset, platform)
# pairs and emits the slots each asset fits in, joining them into
# a single fit string per asset.
#
# Run as: awk -f share.awk -f assetfit.awk
#
# Algorithm:
#   1. For every asset × platform, compute the same score map.awk
#      uses (per-(platform, asset) score, max-across-platforms,
#      neutral flag — all reused from share.awk).
#   2. For each asset, find every platform P where the asset's
#      score on P equals its max across all 6 platforms (i.e. the
#      asset was DESIGNED for P). Collect all such P's into a
#      list of fit labels ("native/darwin/arm64+native/linux/x64").
#      If the asset is a runtime/package format, also emit
#      "runtime/<type>[/<arch>]" for each arch bucket the asset
#      matches (cross-platform: one label; OS-bound: universal +
#      arch-specific, since picking "the" one would be lossy).
#   3. For neutral assets (no OS/arch token) with a runtime
#      suffix, the runtime label IS the fit; platform labels
#      are empty.
#
# Output TSV (one row per asset that survived skip/filter):
#   name\turl\tsize\tlabel\tscores
# where:
#   label  = "+"-joined fit labels (e.g. "native/darwin/arm64")
#   scores = "+"-joined "<platform>=<score>" pairs (so the user
#            can see how strong the fit is on each platform)
#
# The header is added by the shell caller (lib/main) so the awk
# output here is body-only.

BEGIN {
    target_repo = tolower(ENVIRON["AWK_REPO"])
    target_filt = ENVIRON["AWK_FILTERS"]

    n_platforms = 6
    platforms[1] = "darwin/arm64"
    platforms[2] = "darwin/x64"
    platforms[3] = "linux/arm64"
    platforms[4] = "linux/x64"
    platforms[5] = "win/arm64"
    platforms[6] = "win/x64"

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
    lname = tolower(name)

    if (ends_with_any(lname, arr_skip, n_skip)) next
    if (target_filt != "" && !filter_match(lname, target_filt)) next

    # Pair assets (sig/hashsum) are NOT routed to a slot — they're
    # attached as fields to the main asset by the yml/json formatter
    # (lib/main: it re-queries the release JSON to look up the pair
    # URL for each selected asset). In tsv/yml we just drop them;
    # the per-asset detail shows up only when the formatter does
    # its own pair-lookup pass.
    if (pair_field_of(lname) != "") next

    # .exe skip mirrors map.awk.
    if (lname ~ /\.exe$/ && target_os != "win") next

    # Runtime / package-format classification. If the asset has a
    # runtime suffix, it's never a native binary candidate; it
    # routes purely to runtime/<type>[/<arch>].
    rtype = runtime_of(lname)
    is_runtime_asset = (rtype != "")

    # Per-(platform, asset) score table. Even for runtime assets
    # we still need os_score/arch_score for the runtime_arch_of
    # helper to identify x64 vs arm64 within the runtime name.
    asset_max[name]   = -999999
    asset_neutral[name] = 0

    if (! is_runtime_asset) {
        for (p = 1; p <= n_platforms; p++) {
            split(platforms[p], parts, "/")
            plat_os   = parts[1]
            plat_arch = parts[2]
            if (is_skippable_source(lname, plat_os)) continue

            score = 0
            if (stdname_match_for(lname, plat_os, plat_arch, target_repo)) \
                score += STD_NAME_BONUS
            os_hit   = os_score_for(lname, plat_os);    score += os_hit
            arch_hit = arch_score_for(lname, plat_arch); score += arch_hit
            if (os_hit > 0 && arch_hit < 0) score += HARD_CONFLICT
            if (os_hit < 0 && arch_hit > 0) score += WRONG_PLATFORM

            if      (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) score += ARCHIVE_BONUS
            else if (lname ~ /\.pyz$/)                                     score += PYZ_BONUS
            else if (lname ~ /\.(deb|rpm)$/)                               score += PKG_PENALTY

            if (size ~ /^[0-9]+$/ && size + 0 > 0 && size + 0 < SIZE_BONUS_MAX) score += SIZE_BONUS
            if (target_repo != "" && index(lname, target_repo) > 0)            score += REPO_BONUS

            key = platforms[p] SUBSEP name
            ps_score[key] = score
            if (score > asset_max[name]) asset_max[name] = score
            if (os_hit == 0 && arch_hit == 0) asset_neutral[name] = 1
        }
    }

    # Build this asset's fit label set.
    n_labels = 0

    if (! is_runtime_asset) {
        # Native binary candidate: ONE asset → ONE label. Three
        # explicit universal triggers, in priority order:
        #   1. Filename contains the literal token "universal"
        #      (Apple's lipo convention: foo-universal-macos.zip).
        #   2. Filename contains BOTH arch tokens of an OS
        #      ("-aarch64-...-x86_64-" or similar pair), proving
        #      the asset ships for both arches.
        #   3. Pick the single best-scoring platform — don't
        #      synthesize a "universal" label from tied scores,
        #      because BISCORING ties can be a false positive
        #      (e.g. qjs-linux-riscv64 has no arch token in our
        #      tables, so its tied score across arm64/x64 isn't a
        #      genuine fat binary — it's a single-arch riscv64
        #      binary that we can't classify precisely).
        # A genuine fat binary declares itself; trust the name.

        # Universal trigger 1: explicit "universal" token in name.
        if (lname ~ /(^|[-_.])(universal|anyarch|allarch|multiarch)([-_.]|$)/) {
            # Identify which OS it claims to be universal for by
            # looking at OS tokens in the name; fall back to the
            # best-scoring OS.
            for (k in os_tokens) {
                tokens = os_tokens[k]
                n = split(tokens, t, " ")
                for (i = 1; i <= n; i++) {
                    if (index(lname, t[i]) > 0) {
                        n_labels++
                        fit_label[n_labels] = "native/" k "/universal"
                        fit_score[n_labels] = 0
                        break
                    }
                }
                if (n_labels > 0) break
            }
        }

        if (n_labels == 0) {
            # Universal trigger 2: contains both arch tokens of
            # the same OS (e.g. arm64 AND x86_64 both in name).
            for (k in os_tokens) {
                if (k == "win" || k == "linux" || k == "darwin" || \
                    k == "freebsd" || k == "openbsd" || k == "netbsd") {
                    if (lname_has_both_arches(lname, k)) {
                        n_labels++
                        fit_label[n_labels] = "native/" k "/universal"
                        fit_score[n_labels] = 0
                        break
                    }
                }
            }
        }

        if (n_labels == 0) {
            # Default: single best-scoring platform. Pick the
            # platform with the highest score that equals the
            # asset's max — there will be at most one such
            # platform unless both arch tokens tied (which
            # triggers the universal check above, not this).
            best_plat  = ""
            best_score = 0
            for (p = 1; p <= n_platforms; p++) {
                plat = platforms[p]
                s = ps_score[plat SUBSEP name]
                if (asset_neutral[name]) continue
                if (s >= THRESHOLD && s == asset_max[name] && s > 0) {
                    if (s > best_score) {
                        best_score = s
                        best_plat  = plat
                    }
                }
            }
            if (best_plat != "") {
                n_labels++
                fit_label[n_labels]  = "native/" best_plat
                fit_score[n_labels]  = best_score
            }
        }
    }

    if (is_runtime_asset) {
        # Runtime / package-format asset. The fit label is
        # "runtime/<type>[/<arch>]". For cross-platform types
        # (pex/whl/...) there's only one label. For OS-bound
        # types (rpm/deb/...) we emit both the universal slot
        # (noarch) and any arch-specific slot the asset matches.
        # Callers can pick the one they want; we don't pick here.
        # share.awk's runtime_arch_of strips the runtime suffix
        # internally, so pass the full lname.
        rarch = runtime_arch_of(lname, rtype)
        if (rarch == "") {
            n_labels++
            fit_label[n_labels] = "runtime/" rtype
            fit_score[n_labels] = 0
        } else {
            n_labels++
            fit_label[n_labels] = "runtime/" rtype "/" rarch
            fit_score[n_labels] = 0
            # OS-bound with arch tag — also surface the universal
            # slot so callers see the noarch alternative exists.
            if (is_os_bound_runtime(rtype)) {
                n_labels++
                fit_label[n_labels] = "runtime/" rtype
                fit_score[n_labels] = 0
            }
        }
    }

    if (n_labels == 0) next   # no fit — skip row

    # Build joined label string. (Score was dropped — one asset
    # has a single fit label, so the score is implied by the
    # label and redundant in this view.)
    lab = ""
    for (i = 1; i <= n_labels; i++) {
        if (i > 1) lab = lab "+"
        lab = lab fit_label[i]
    }

    printf "%s\t%s\t%s\t%s\n", name, url, size, lab
}

# True if lname contains arch tokens of BOTH x64 and arm64
# (after lowercasing). The function is OS-agnostic; callers
# check the OS first via os_score_for or similar.
function lname_has_both_arches(lname,    has_x64, has_arm64, i) {
    has_x64   = 0
    has_arm64 = 0
    for (i = 1; i <= n_arch_tok; i++) {
        if (index(lname, arch_tok[i]) == 0) continue
        if (arch_tok_grp[i] == "x64")   has_x64   = 1
        if (arch_tok_grp[i] == "arm64") has_arm64 = 1
    }
    return (has_x64 && has_arm64)
}
