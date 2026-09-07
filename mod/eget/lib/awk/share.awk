#!/usr/bin/awk -f
# eget detect — shared infrastructure.
#
# Loaded first via `awk -f share.awk -f <algo>.awk`. Provides:
#   - ENV reading: target_os, target_arch, target_repo, target_filt, verbose
#   - Token tables: os_tokens[], arch_tokens[] (single source of truth
#     so adding a new OS or arch needs to change only this file)
#   - Length-sorted arch flattening: arch_tok[], arch_tok_grp[], n_arch_tok
#     — needed because awk's `for (k in array)` order isn't stable
#     across groups; without length-first matching, the short token
#     `x86` (group 386) substring-matches `x86_64` (group amd64) and
#     routes an amd64 asset to the wrong group
#   - Skip suffixes: arr_skip[], n_skip
#   - Helpers: read_columns, os_score, arch_score, filter_match,
#     ends_with_any
#
# Scoring tables are read from caller-set globals (OS_HIT, OS_MISS,
# ARCH_HIT, ARCH_MISS); callers set these in their own BEGIN block
# BEFORE calling the score helpers. Defaults: 20 / -20 / 15 / -15.

BEGIN {
    target_os    = ENVIRON["AWK_OS"]
    target_arch  = ENVIRON["AWK_ARCH_NORM"]
    target_repo  = tolower(ENVIRON["AWK_REPO"])
    target_filt  = ENVIRON["AWK_FILTERS"]
    verbose      = (ENVIRON["AWK_VERBOSE"] == "1")

    # OS token groups. Substrings within a group never cross routes
    # to another group, so per-group substring scan is safe here.
    os_tokens["darwin"]  = "darwin macos mac-os osx sonoma ventura monterey catalina mojave sequoia tahoe"
    os_tokens["linux"]   = "linux ubuntu debian fedora centos rhel alpine amzn archlinux manjaro suse opensuse gentoo nixos linux-gnu linux-musl"
    os_tokens["win"]     = "windows win32 win64 mingw"
    os_tokens["freebsd"] = "freebsd"
    os_tokens["openbsd"] = "openbsd"
    os_tokens["netbsd"]  = "netbsd"

    # Arch token groups — cross-group substring hazard (x86 vs x86_64,
    # arm vs armv7 vs aarch64), so we flatten and sort by length below.
    arch_tokens["amd64"] = "x86_64 amd64 x64"
    arch_tokens["arm64"] = "aarch64 armv8 arm64"
    arch_tokens["386"]   = "i686 i386 x86 386"
    arch_tokens["arm"]   = "armv7l armv7 armhf armv6 arm"

    n_arch_tok = 0
    for (k in arch_tokens) {
        n = split(arch_tokens[k], tokens, " ")
        for (i = 1; i <= n; i++) {
            n_arch_tok++
            arch_tok[n_arch_tok]     = tokens[i]
            arch_tok_grp[n_arch_tok] = k
        }
    }
    # Bubble sort — n_arch_tok is tiny (~20 tokens total).
    for (i = 1; i <= n_arch_tok; i++) {
        for (j = i + 1; j <= n_arch_tok; j++) {
            if (length(arch_tok[i]) < length(arch_tok[j])) {
                tt = arch_tok[i]; arch_tok[i] = arch_tok[j]; arch_tok[j] = tt
                tg = arch_tok_grp[i]; arch_tok_grp[i] = arch_tok_grp[j]; arch_tok_grp[j] = tg
            }
        }
    }

    # Non-binary suffixes: checksums, signatures, manifests, SBOMs.
    # Compounded at end-of-name (e.g. ".tar.xz.md5", ".zip.minisig").
    skip_suffixes = ".sha256 .sha256sum .sha1 .sha384 .sha512 .sha512sum .md5 .sig .asc .pem .minisig .minisig.json .sum .txt .md .json .jsonl .sbom .bundle .bsdiff .provenance .intoto."
    n_skip = split(skip_suffixes, arr_skip, " ")

    # Default scoring tables (callers may override in their own BEGIN).
    if (OS_HIT  == "") OS_HIT  = 20
    if (OS_MISS == "") OS_MISS = -20
    if (ARCH_HIT  == "") ARCH_HIT  = 15
    if (ARCH_MISS == "") ARCH_MISS = -15
}

# ---- helpers ----

# Parse an asset line into the global vars name/url/size/digest,
# tolerating both column orders (select_ vs seatrial).
function read_columns(line,    n, f2, f3, f4) {
    n = split(line, parts, "\t")
    name = parts[1]
    f2 = parts[2]; f3 = parts[3]; f4 = (n >= 4 ? parts[4] : "")
    if (f2 ~ /^[0-9]+$/) {
        size = f2; url = f3; digest = f4
    } else {
        url = f2; size = f3; digest = f4
    }
}

# Returns OS_HIT / OS_MISS / 0 (depending on caller-set globals).
function os_score(lname,    k, tokens, n, i) {
    for (k in os_tokens) {
        n = split(os_tokens[k], tokens, " ")
        for (i = 1; i <= n; i++) {
            if (index(lname, tokens[i]) > 0) return (k == target_os ? OS_HIT : OS_MISS)
        }
    }
    return 0
}

# Returns ARCH_HIT / ARCH_MISS / 0 (depending on caller-set globals).
# Iterates the pre-sorted (length-desc) token list so longer tokens
# (x86_64, aarch64) match before their substrings route to wrong groups.
function arch_score(lname,    i) {
    for (i = 1; i <= n_arch_tok; i++) {
        if (index(lname, arch_tok[i]) > 0) {
            return (arch_tok_grp[i] == target_arch ? ARCH_HIT : ARCH_MISS)
        }
    }
    return 0
}

# Parameterized variants for callers that score an asset against
# multiple platforms in one pass (map.awk, scoring2.awk). Read
# caller-set globals for the score values so scoring.awk / original.awk
# can override the defaults. Defaults: 20 / -20 / 15 / -15 (same as
# the global-only versions above).
function os_score_for(lname, target,    k, tokens, n, i) {
    for (k in os_tokens) {
        n = split(os_tokens[k], tokens, " ")
        for (i = 1; i <= n; i++) {
            if (index(lname, tokens[i]) > 0) \
                return (k == target ? OS_HIT : OS_MISS)
        }
    }
    return 0
}

function arch_score_for(lname, target,    i) {
    for (i = 1; i <= n_arch_tok; i++) {
        if (index(lname, arch_tok[i]) > 0) {
            return (arch_tok_grp[i] == target ? ARCH_HIT : ARCH_MISS)
        }
    }
    return 0
}

# Pipe-separated include / ^exclude patterns against already-lowercased
# lname. Caller passes target_filt directly.
function filter_match(lname, filters,    n, i, f, lf, excl) {
    if (filters == "") return 1
    n = split(filters, arr, "|")
    for (i = 1; i <= n; i++) {
        f = arr[i]
        lf = tolower(f)
        if (substr(lf, 1, 1) == "^") {
            excl = substr(lf, 2)
            if (index(lname, excl) > 0) return 0
        } else {
            if (index(lname, lf) == 0) return 0
        }
    }
    return 1
}

# True if lname ends with any suffix in arr[].
function ends_with_any(lname, arr, n,    i, s, ls, ll) {
    ll = length(lname)
    for (i = 1; i <= n; i++) {
        s = arr[i]
        ls = length(s)
        if (ll >= ls && substr(lname, ll - ls + 1) == s) return 1
    }
    return 0
}

# Standard naming pattern: {repo}[-_]<anything>[-_]<os>[-_]<arch>.<ext>
# Returns 1 if lname matches the standard pattern for the given
# os + arch (no globals — used by map.awk which scores multiple
# platforms in one pass).
function stdname_match_for(lname, os, arch, repo,    re) {
    if (repo == "") return 0
    re = "^" repo "[-_][^_/-]*[-_]" os "[-_]" arch "\\."
    return (lname ~ re)
}

# Returns 1 if lname looks like a non-platform-binary asset that
# scoring would still pick because of its archive extension:
#
#   .zsh                                       (single-file shell
#                                              frameworks — never
#                                              a real binary)
#   source.tar.gz / source.zip                 (GitHub auto-source
#                                              bare archives)
#   Source code (zip|tar.gz)                   (display name)
#   *.tar.gz / *.tar.xz / *.zip / *.tar / etc. that
#     contain NO OS or arch token              (likely auto source
#                                              archive named after
#                                              repo-version)
#
# Without this, scoring picks e.g. julia-1.12.6.tar.gz on
# darwin/arm64 (score 45: archive+5, size+2, repo+3, darwin OS
# match +20, arm64 arch match +15) — clearly wrong, that's the
# Julia source archive, not a binary.
function is_skippable_source(lname, target_os) {
    # Hardcode skip is a small adjustment on top of scoring —
    # reserved for cases we're 100% sure aren't platform
    # binaries. Anything else falls through to scoring.

    # GitHub auto source archives: GitHub adds these to every
    # release with a fixed name. Never a platform binary.
    if (lname == "source.tar.gz" || lname == "source.zip") return 1
    if (lname ~ /^[Ss]ource[ ]code[ ]*\(/) return 1

    # Archive extension with NO OS / arch token — likely a
    # GitHub auto-source archive (e.g. "julia-1.12.6.tar.gz",
    # "zig-bootstrap-0.15.1.tar.xz", "trident-installer-26.02.1.tar.gz").
    # The archive bonus in scoring (+5) would push these past
    # THRESHOLD=5 on their own (no real OS/arch match), but
    # they can't actually run on any platform. Real platform
    # archives always have a token (linux, darwin, amd64,
    # x86_64, freebsd, ...) in the name.
    if (lname ~ /\.(tar\.gz|tgz|tar\.bz2|tar\.xz|tar|zip)$/) {
        for (k in os_tokens)   if (os_score_for(lname, k)   != 0) return 0
        for (k in arch_tokens) if (arch_score_for(lname, k) != 0) return 0
        return 1
    }

    return 0
}
