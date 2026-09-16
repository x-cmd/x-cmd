
# eget fit — bidirectional-match per-bucket best candidate.
#
# Run as: awk -f share.awk -f map.awk
#
# 3-bucket classification. An asset goes into one of:
#
#   native/<os>/<arch>           — platform-compiled machine code
#                                  binary you can ./run directly.
#                                  .tar.gz / .zip / .exe / AppImage.
#   native/<type>/<os>/<arch>     — OS-bound native variant
#                                  (e.g. native/appimage/linux/x64).
#   package/<type>/<arch>         — system package managed by a
#                                  package manager. .rpm / .deb /
#                                  .dmg / .msi / .apk / .pkg.tar.zst /
#                                  .flatpak / .snap.
#   runtime/<type>[/<arch>]       — needs an interpreter or VM.
#                                  .whl / .jar / .pex / .pyz / .js /
#                                  .py / .ts / .wasm / .node / .gem /
#                                  .nupkg / .vsix / .crate / .cosmo
#                                  (and the project-runtime keyword
#                                  labels for repos like
#                                  jart/cosmopolitan).
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
# Output: one TSV row per filled slot, in fixed order:
#   6 native/<os>/<arch> + native/appimage/linux/x64 (if any) +
#   N package/<type>/<arch> + N runtime/<type>[/<arch>].
# Empty slots are dropped (no "runtime/deb: no asset" rows).

BEGIN {
    target_repo = tolower(ENVIRON["AWK_REPO"])
    target_filt = ENVIRON["AWK_FILTERS"]

    # 12 platform slots: 2 darwin (no libc split on macOS), 4 linux
    # (x64/arm64 × gnu/musl), 4 win (x64/arm64 × msvc/gnu = MSVC/MinGW),
    # 2 fallback linux/win for assets without a libc tag.
    n_platforms = 12
    platforms[1]  = "darwin/arm64"
    platforms[2]  = "darwin/x64"
    platforms[3]  = "linux/x64/gnu"
    platforms[4]  = "linux/x64/musl"
    platforms[5]  = "linux/x64"           # fallback: linux binary with no libc tag
    platforms[6]  = "linux/arm64/gnu"
    platforms[7]  = "linux/arm64/musl"
    platforms[8]  = "linux/arm64"
    platforms[9]  = "win/x64/msvc"
    platforms[10] = "win/x64/gnu"         # MinGW-built
    platforms[11] = "win/x64"
    platforms[12] = "win/arm64/msvc"

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

    if (lname ~ /\.exe$/ && target_os != "win") next

    # Pair assets (sig/hashsum) don't get a slot of their own.
    # The yml/json formatter in lib/main does a separate
    # release-JSON lookup to attach pair URLs to the main asset
    # they decorate; tsv stays clean (5 cols, no pair rows).
    if (pair_field_of(lname) != "") next

    line = name "\t" url "\t" size
    name_to_url[name] = url

    # Three-way bucket routing. rtype is the runtime pattern
    # match (suffix). bucket is the parent key:
    #   "native"  : appimage (OS-bound native)
    #   "package" : rpm / deb / dmg / msi / apk / pkg.tar.zst /
    #               flatpak / snap (system packages)
    #   "runtime" : everything else (whl / jar / pex / pyz / js /
    #               py / ts / wasm / .node / gem / nupkg / vsix /
    #               crate / cosmo)
    # We keep the old single-table os_bound_types around (built
    # in share.awk from the union of the three) so we can decide
    # "OS-bound vs cross-platform" with one check, then reclassify
    # into the right parent key below.
    rtype = runtime_of(lname)
    if (rtype != "") {
        size_of[name]            = size
        rt_line_of[name]         = line
        asset_runtime[name]      = rtype
        asset_runtime_arch[name] = runtime_arch_of(lname, rtype)
        # Pick the parent bucket.
        if (is_in_list(rtype, arr_native_os_bound, n_native_os_bound))
            asset_bucket[name] = "native"
        else if (is_in_list(rtype, arr_package, n_package))
            asset_bucket[name] = "package"
        else
            asset_bucket[name] = "runtime"
        next
    }

    # Project-specific runtime keyword (e.g. jart/cosmopolitan
    # ships "*-cosmo-*.zip"). The asset is also eligible for
    # OS+arch routing — the keyword label is additive.
    prtype = project_runtime_of(lname)
    if (prtype != "") {
        if (! (name in project_runtime)) {
            size_of[name]            = size
            rt_line_of[name]         = line
            project_runtime[name]    = prtype
        }
    }

    # Score this asset against each of the 6 platforms.
    for (p = 1; p <= n_platforms; p++) {
        split(platforms[p], parts, "/")
        target_os   = parts[1]
        target_arch = parts[2]
        # 3-segment slots like `linux/x64/gnu` use parts[1]+"-"+parts[3]
        # as the OS key (so os_score_for routes to the linux-gnu
        # bucket, not the generic linux bucket). 2-segment slots
        # use parts[1] directly.
        if (parts[3] != "") target_os_key = parts[1] "-" parts[3]
        else                target_os_key = parts[1]

        if (is_skippable_source(lname, target_os_key)) continue

        # Fallback slots (2-segment) only match assets that carry
        # the bare OS token (no libc sub-slot). libc-tagged assets
        # (linux-gnu, linux-musl, windows-msvc, windows-gnu) are
        # already routed to a specific 3-segment slot — letting
        # them also fill the fallback would duplicate the same
        # asset in two rows.
        if (parts[3] == "" && libc_of(lname) != "") continue

        score = 0
        if (stdname_match_for(lname, target_os_key, target_arch, target_repo)) \
            score += STD_NAME_BONUS

        os_hit   = os_score_for(lname, target_os_key);  score += os_hit
        arch_hit = arch_score_for(lname, target_arch); score += arch_hit
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

        key = platforms[p] SUBSEP name
        ps_score[key] = score
        ps_line[key]  = line

        if (!(name in asset_max) || score > asset_max[name]) \
            asset_max[name] = score

        if (os_hit == 0 && arch_hit == 0) asset_neutral[name] = 1
    }
}

# Computes the key used to index a platform slot in ps_score[]
# / asset_max[]. The key is `os/arch` — including any libc/toolchain
# sub-slot (e.g. "linux/amd64/gnu" → "linux/amd64/gnu", not
# "linux/amd64"). The libc sub-slot is part of the slot identity,
# not a separate dimension.
function slot_key(plat,    parts, n) {
    n = split(plat, parts, "/")
    return parts[1] "/" parts[2] (parts[3] != "" ? "/" parts[3] : "")
}

END {
    # --- native: 6 platform slots + OS-bound native variants ---
    # Pre-scan: figure out which fallback slots (e.g. linux/x64)
    # should be skipped because a more-specific slot in the same
    # OS+arch group already filled (linux/x64/gnu or linux/x64/musl).
    # The skip decision is made before the emit loop because awk
    # array iteration order isn't guaranteed — we can't rely on
    # `linux/x64/gnu` being processed before `linux/x64`.
    for (p = 1; p <= n_platforms; p++) {
        plat = platforms[p]
        n_parts = split(plat, pp, "/")
        if (n_parts > 2 && pp[3] == "") {
            # This is a fallback slot. Look at specific (non-
            # fallback) peer slots in the same os/arch group.
            fb_key = pp[1] "/" pp[2]
            for (q = 1; q <= n_platforms; q++) {
                if (q == p) continue
                split(platforms[q], qq, "/")
                if (qq[1] != pp[1] || qq[2] != pp[2]) continue
                if (qq[3] == "") continue   # skip fallback peers
                # q is a specific slot. Does any asset hit max
                # there? The same asset that fills the specific
                # slot would also fill the fallback, so the
                # fallback is redundant.
                plat_key_q = slot_key(platforms[q])
                specific_filled = 0
                for (name in asset_max) {
                    if (asset_neutral[name]) continue
                    if (name in asset_runtime) continue
                    s = ps_score[plat_key_q SUBSEP name]
                    if (s >= THRESHOLD && s == asset_max[name]) {
                        specific_filled = 1
                        break
                    }
                }
                if (specific_filled) {
                    skip_fallback[fb_key] = 1
                    break
                }
            }
        }
    }

    for (p = 1; p <= n_platforms; p++) {
        plat = platforms[p]
        # Asset_max is indexed by the SAME key the per-platform
        # scorer used. Both use `slot_key(plat)`. Without this
        # normalization, the cross-platform max lookup for a
        # 3-segment slot like `linux/amd64/gnu` would compare
        # against the bare `linux/amd64` max from the fallback
        # slot and over-penalize libc-specific assets.
        plat_key = slot_key(plat)
        # Fallback slots like `linux/x64` (3rd segment empty)
        # are emitted ONLY when no specific slot in the same
        # OS+arch group (e.g. `linux/x64/gnu`, `linux/x64/musl`)
        # was filled. Pre-scan above populated `skip_fallback`.
        n_parts = split(plat, pp, "/")
        is_fallback = (n_parts > 2 && pp[3] == "")
        if (is_fallback) {
            fb_key = pp[1] "/" pp[2]
            if (fb_key in skip_fallback) {
                printf "native/%s\t\t\t\n", plat
                continue
            }
        }
        best_score = -999999
        best_line  = ""

        for (name in asset_max) {
            if (asset_neutral[name]) continue
            if (name in asset_runtime) continue
            key = plat_key SUBSEP name
            s = ps_score[key]
            if (s >= THRESHOLD && s == asset_max[name] && s > best_score) {
                best_score = s
                best_line  = ps_line[key]
            }
        }

        if (best_score >= THRESHOLD && best_line != "") {
            printf "native/%s\t%s\t%d\n", plat, best_line, best_score
        } else {
            # Emit empty row so consumers (yml/json) see a
            # consistent 6-platform shape even when nothing fits.
            printf "native/%s\t\t\t\n", plat
        }
    }

    # OS-bound native slots (e.g. native/appimage/linux/x64).
    for (i = 1; i <= n_native_os_bound; i++) {
        rt = arr_native_os_bound[i]
        if (seen[rt, ""]++    == 0 && slot_has_asset(rt, ""))    emit_bucket_slot("native", rt, "")
        if (seen[rt, "x64"]++ == 0 && slot_has_asset(rt, "x64"))   emit_bucket_slot("native", rt, "x64")
        if (seen[rt, "arm64"]++ == 0 && slot_has_asset(rt, "arm64")) emit_bucket_slot("native", rt, "arm64")
    }

    # --- package: rpm/deb/dmg/msi/apk/pkg.tar.zst/flatpak/snap ---
    for (i = 1; i <= n_package; i++) {
        rt = arr_package[i]
        if (seen_pkg[rt, ""]++    == 0 && slot_has_asset(rt, ""))    emit_bucket_slot("package", rt, "")
        if (seen_pkg[rt, "x64"]++ == 0 && slot_has_asset(rt, "x64"))   emit_bucket_slot("package", rt, "x64")
        if (seen_pkg[rt, "arm64"]++ == 0 && slot_has_asset(rt, "arm64")) emit_bucket_slot("package", rt, "arm64")
    }

    # --- runtime: whl/jar/pex/pyz/js/py/ts/wasm/.node/gem/nupkg/vsix/crate/cosmo ---
    # Cross-platform runtime types — one row per type.
    # Build the unique set: take all rtypes we saw, then skip those
    # in the native_os_bound / package tables (already emitted
    # above).
    for (i = 1; i <= n_rt_seen; i++) {
        rt = rt_type[i]
        if (is_in_list(rt, arr_native_os_bound, n_native_os_bound)) continue
        if (is_in_list(rt, arr_package, n_package))                 continue
        if (seen_rt[rt, ""]++) continue
        if (slot_has_asset(rt, "")) emit_bucket_slot("runtime", rt, "")
    }
    # OS-bound runtime types (e.g. .node) — one row per arch.
    for (i = 1; i <= n_runtime_os_bound; i++) {
        rt = substr(arr_runtime_os_bound[i], 2)   # strip leading "."
        if (seen_rt[rt, ""]++    == 0 && slot_has_asset(rt, ""))    emit_bucket_slot("runtime", rt, "")
        if (seen_rt[rt, "x64"]++ == 0 && slot_has_asset(rt, "x64"))   emit_bucket_slot("runtime", rt, "x64")
        if (seen_rt[rt, "arm64"]++ == 0 && slot_has_asset(rt, "arm64")) emit_bucket_slot("runtime", rt, "arm64")
    }

    # Project-specific runtime labels (e.g. runtime/cosmo from
    # jart/cosmopolitan). One row per unique project_kw type.
    for (i = 1; i <= n_pr_seen; i++) {
        if (project_slot_has_asset(pr_type[i])) emit_project_slot(pr_type[i])
    }
}

# Collect the per-asset runtime/ package data into flat arrays
# for the END-block slot picker. Populated in the main record
# block right after the bucket is decided.
function bucket_collect(name, rtype, bucket) {
    n_rt_seen++
    rt_type[n_rt_seen]    = rtype
    rt_name[n_rt_seen]    = name
    rt_size[n_rt_seen]    = (size_of[name] == "" ? 0 : size_of[name] + 0)
    rt_line[n_rt_seen]    = rt_line_of[name]
    rt_arch[n_rt_seen]    = asset_runtime_arch[name]
}

# Returns 1 if any asset in n_rt_seen has the given (rtype, slot)
# combination, 0 otherwise.
function slot_has_asset(rtype, slot,  i) {
    for (i = 1; i <= n_rt_seen; i++) {
        if (rt_type[i] == rtype && rt_arch[i] == slot) return 1
    }
    return 0
}

# Returns 1 if value appears in arr[] (length n). Used to decide
# whether a rtype belongs to native_os_bound / package / runtime.
function is_in_list(value, arr, n,  i) {
    for (i = 1; i <= n; i++) {
        if (arr[i] == value) return 1
    }
    return 0
}

# Emit one bucket/<type>[/<arch>] TSV row. Selection: smallest
# size wins, name tie-breaks. Callers must pre-check via
# slot_has_asset() to avoid emitting empty rows.
function emit_bucket_slot(bucket, rtype, slot,  best_name, best_size, best_line, \
                          i, sz) {
    best_size = 999999999999
    best_name = ""
    best_line = ""
    for (i = 1; i <= n_rt_seen; i++) {
        if (rt_type[i] != rtype) continue
        if (rt_arch[i] != slot)  continue
        sz = rt_size[i] + 0
        if (sz < best_size || (sz == best_size && rt_name[i] < best_name)) {
            best_size = sz
            best_name = rt_name[i]
            best_line = rt_line[i]
        }
    }
    key = bucket "/" rtype (slot == "" ? "" : "/" slot)
    printf "%s\t%s\t0\n", key, best_line
}

# Project-specific runtime label emit. Same selection rule.
function project_slot_has_asset(prtype,  i) {
    for (i = 1; i <= n_pr_seen; i++) {
        if (pr_type[i] == prtype) return 1
    }
    return 0
}

function emit_project_slot(prtype,  best_name, best_size, best_line,  \
                           i, sz) {
    best_size = 999999999999
    best_name = ""
    best_line = ""
    for (i = 1; i <= n_pr_seen; i++) {
        if (pr_type[i] != prtype) continue
        sz = pr_size[i] + 0
        if (sz < best_size || (sz == best_size && pr_name[i] < best_name)) {
            best_size = sz
            best_name = pr_name[i]
            best_line = pr_line[i]
        }
    }
    key = "runtime/" prtype
    printf "%s\t%s\t0\n", key, best_line
}
