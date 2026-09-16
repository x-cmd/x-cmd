
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
    #
    # linux-gnu / linux-musl are SEPARATE groups from `linux` so the
    # platform slots `linux/x64/gnu` and `linux/x64/musl` get routed
    # only their matching binary. `linux` group is the fallback for
    # assets that carry `linux` but no libc tag.
    os_tokens["darwin"]      = "darwin macos mac-os osx sonoma ventura monterey catalina mojave sequoia tahoe"
    os_tokens["linux-gnu"]   = "linux-gnu"
    os_tokens["linux-musl"]  = "linux-musl"
    os_tokens["linux"]       = "linux ubuntu debian fedora centos rhel alpine amzn archlinux manjaro suse opensuse gentoo nixos"
    os_tokens["windows-msvc"] = "windows-msvc pc-windows-msvc msvc"
    os_tokens["windows-gnu"]  = "windows-gnu pc-windows-gnu mingw"
    # Slot naming for the `native/win/*` family uses `win-msvc` /
    # `win-gnu` as the OS key (parts[1]="win" + "-" + parts[3]),
    # so the bucket names must match the slot-name prefix.
    os_tokens["win-msvc"]     = "windows-msvc pc-windows-msvc msvc"
    os_tokens["win-gnu"]      = "windows-gnu pc-windows-gnu mingw"
    os_tokens["win"]         = "windows win32 win64"
    os_tokens["freebsd"]     = "freebsd"
    os_tokens["openbsd"]     = "openbsd"
    os_tokens["netbsd"]      = "netbsd"

    # Arch token groups — cross-group substring hazard (x86 vs x86_64,
    # arm vs armv7 vs aarch64), so we flatten and sort by length below.
    # Group key is the canonical arch name that arch_score_for returns
    # to callers; downstream scoring uses this to match against the
    # user's target system (e.g. darwin/x64 → "x64" bucket).
    arch_tokens["x64"]   = "x86_64 amd64 x64"
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

    # Non-binary suffixes: docs, manifests, SBOMs, supply-chain
    # artifacts. Checksums (.sha256/.md5/.sum) and signatures
    # (.sig/.asc/.minisig) are NOT here — they're surfaced as
    # runtime/sig and runtime/hashsum labels (see runtime_suffix_map
    # below) so callers can see "this release was signed/has
    # checksums" rather than skipping them silently.
    skip_suffixes = ".txt .md .json .jsonl .sbom .bundle .bsdiff .provenance .intoto"
    n_skip = split(skip_suffixes, arr_skip, " ")

    # Pair suffixes — signature / hash files that "decorate" their
    # main asset (e.g. `foo-1.0.tar.gz` paired with
    # `foo-1.0.tar.gz.sig` and `foo-1.0.tar.gz.sha256`). They are
    # NOT routed as runtime slots; instead, the dispatchers (map.awk
    # for fit, assetfit.awk) attach their URLs as `sig` / `sha256`
    # / etc. fields to the main asset's entry. Bare-suffix keys
    # (without leading ".") — the field name appears bare in the
    # emitted yml/json. Matched by suffix-strip on the asset name.
    pair_sig_suffixes   = ".sig .asc .minisig .minisig.json .pem"
    n_pair_sig = split(pair_sig_suffixes, arr_pair_sig, " ")
    pair_hash_suffixes  = ".sha256 .sha256sum .sha1 .sha384 .sha512 .sha512sum .md5 .sum"
    n_pair_hash = split(pair_hash_suffixes, arr_pair_hash, " ")

    # 3-bucket classification. The `runtime_patterns` list is the
    # full set of suffixes that map.awk removes from the OS+arch
    # platform pool — anything matching is "not a tar.gz-style
    # native binary you can ./run directly." The actual parent
    # bucket (native / package / runtime) is decided by which
    # of the three suffix tables below the asset's suffix appears in.
    runtime_patterns = ".pex .whl .jar .pyz .js .sh .py .crate .wasm .ts .gem .nupkg .vsix .cosmo .rpm .deb .dmg .msi .apk .appimage .flatpak .snap .pkg.tar.zst .node"
    n_runtime = split(runtime_patterns, arr_runtime, " ")

    # native_os_bound_types: suffixes that go under the `native:`
    # bucket but still need an arch slot. AppImage is a Linux ELF
    # compiled by the project's toolchain — it counts as native
    # machine code, not a system package. Output key:
    # native/appimage/linux/<arch>.
    native_os_bound_types = "appimage"
    n_native_os_bound = split(native_os_bound_types, arr_native_os_bound, " ")

    # package_types: suffixes that go under the `package:` bucket
    # and need an arch slot. These are distribution-format packages
    # installed by a system package manager (rpm/deb/apk) or
    # container-runtime install (flatpak/snap). Output key:
    # package/<type>/<arch>.
    package_types = "rpm deb dmg msi apk pkg.tar.zst flatpak snap"
    n_package = split(package_types, arr_package, " ")

    # OS-bound runtime types: cross-platform runtime types that
    # sometimes ship per-arch variants (e.g. .node native addon).
    # Output key: runtime/<type>[/<arch>]. Cross-platform types
    # without a per-arch variant just emit runtime/<type> with no
    # arch slot.
    runtime_os_bound_types = ".node"
    n_runtime_os_bound = split(runtime_os_bound_types, arr_runtime_os_bound, " ")

    # Libc/toolchain subgroups: when an asset name contains a
    # long token like `linux-gnu` / `linux-musl` / `windows-msvc` /
    # `windows-gnu`, route it to the matching sub-slot. Assets
    # containing the bare `linux` or `windows` token (no
    # toolchain tag) fall through to the generic `<os>/<arch>`
    # slot. Naming convention follows Rust's target triple
    # (e.g. zhhz, ripgrep all suffix their assets with
    # `unknown-linux-gnu` or `x86_64-pc-windows-msvc`).
    libc_subtokens = "linux-gnu linux-musl windows-msvc windows-gnu"
    n_libc_sub = split(libc_subtokens, arr_libc_sub, " ")

    # Backwards-compat shim — older code (map.awk's runtime/ emit
    # path) reads n_os_bound / arr_os_bound. We keep the union of
    # the three new tables under the old name so the runtime/
    # slot logic in map.awk still functions as "OS-bound runtime
    # asset" until the next refactor pass moves it to package/.
    os_bound_types = native_os_bound_types " " package_types " " runtime_os_bound_types
    n_os_bound = split(os_bound_types, arr_os_bound, " ")
    # Strip the leading "." that runtime_os_bound_types uses so
    # lookups against the bare type ("node" not ".node") work.
    for (i = 1; i <= n_os_bound; i++) {
        s = arr_os_bound[i]
        if (substr(s, 1, 1) == ".") arr_os_bound[i] = substr(s, 2)
    }

    # Project-specific runtime keyword triggers. A given repo can
    # publish assets under a project-specific naming convention
    # (e.g. jart/cosmopolitan ships "quickjs-cosmo-*.zip" where
    # "cosmo" denotes the Cosmopolitan runtime, not a generic
    # substring match). When target_repo matches a key here, the
    # matching asset is labeled with the project-specific runtime
    # type — IN ADDITION to its platform/<os>/<arch> label.
    #
    # Boundary check: the keyword must appear as a delimited token
    # in the asset name (separated by `-`, `_`, `.`, or
    # start/end-of-string) so we don't false-positive on similar
    # substrings.
    project_runtime_kw["jart/cosmopolitan"] = "cosmo"

    # Map arch-suffix to canonical arch key (x64 / arm64). Used to
    # route a `foo-1.0-1.x86_64.rpm` to runtime/rpm/x64 rather than
    # runtime/rpm (universal).
    runtime_arch_tokens["x86_64"] = "x64"
    runtime_arch_tokens["amd64"]   = "x64"
    runtime_arch_tokens["x64"]     = "x64"
    runtime_arch_tokens["aarch64"] = "arm64"
    runtime_arch_tokens["arm64"]   = "arm64"
    n_runtime_arch = 0
    for (tok in runtime_arch_tokens) {
        n_runtime_arch++
        runtime_arch_tok[n_runtime_arch]     = tok
        runtime_arch_key[n_runtime_arch]     = runtime_arch_tokens[tok]
    }

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
function os_score_for(lname, target,    k, tokens, n, i, hit_any) {
    # Two-pass: first try to find a bucket whose token matches
    # AND whose key is the target (i.e. asset really was built
    # for this OS). If found → OS_HIT. Otherwise, find any
    # bucket that matched and return OS_MISS. Falls back to 0
    # when no bucket matched at all (asset has no OS token at
    # all — e.g. `pex-5.0`).
    #
    # This matters for the libc sub-slots: `linux-musl.tar.xz`
    # must hit the linux-musl bucket first, not the generic
    # `linux` bucket (which would also match `linux-musl` as a
    # substring). Two-pass guarantees the libc-specific bucket
    # wins regardless of awk array iteration order.
    hit_any = 0
    for (k in os_tokens) {
        n = split(os_tokens[k], tokens, " ")
        for (i = 1; i <= n; i++) {
            if (index(lname, tokens[i]) > 0) {
                if (k == target) return OS_HIT
                hit_any = 1
            }
        }
    }
    if (hit_any) return OS_MISS
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

# Returns the runtime type for lname ("whl", "rpm", ...) or "" if
# lname is a generic archive / native binary. Match logic:
#   - For the dotted form (".pex", ".whl", ".rpm", ...): the lname
#     must end with that suffix (so `foo-1.0.whl` matches ".whl").
#   - For the no-dot form (lname == "pex", lname == "whl", ...):
#     exact-match the bare token, because some projects ship a
#     single self-contained file with no extension (Pants' `pex`
#     binary is the canonical example — a 5 MB zipapp).
# Longest dotted suffix wins so ".pkg.tar.zst" matches before any
# shorter suffix.
function runtime_of(lname,    i, s, bare, ls, ll, best_s, best_ls) {
    ll = length(lname)
    best_s = ""
    best_ls = 0
    for (i = 1; i <= n_runtime; i++) {
        s = arr_runtime[i]
        # arr_runtime entries are dotted (".pex", ".whl", ...). The
        # bare token is what we return ("pex", "whl", ...).
        bare = substr(s, 2)
        if (lname == bare) {
            # Exact bare-name match (lname == "pex" → "pex").
            if (length(bare) > best_ls) {
                best_s = bare
                best_ls = length(bare)
            }
        } else if (ll > length(s) && substr(lname, ll - length(s) + 1) == s) {
            # Dotted suffix match ("foo-1.0.whl" → "whl"). Require
            # ll > length(s) so we don't double-match the bare case
            # against the dotted form's leading dot.
            if (length(s) > best_ls) {
                best_s = bare
                best_ls = length(s)
            }
        }
    }
    return best_s
}

# True if the runtime type is OS-bound (needs an arch slot under
# runtime/<type>/<arch> in the lsassetmap output). Pure runtime
# types (whl, pex, ...) return 0.
function is_os_bound_runtime(rtype,    i) {
    for (i = 1; i <= n_os_bound; i++) {
        if (arr_os_bound[i] == rtype) return 1
    }
    return 0
}

# Returns the pair-suffix field name (e.g. "sha256", "sig",
# "minisig") if lname ends with any pair suffix, "" otherwise.
# Used to attach signature/hash files to their main asset rather
# than emitting them as standalone runtime slots.
function pair_field_of(lname,    i, s, ls, ll) {
    ll = length(lname)
    for (i = 1; i <= n_pair_sig; i++) {
        s = arr_pair_sig[i]
        ls = length(s)
        if (ll > ls && substr(lname, ll - ls + 1) == s) return substr(s, 2)
    }
    for (i = 1; i <= n_pair_hash; i++) {
        s = arr_pair_hash[i]
        ls = length(s)
        if (ll > ls && substr(lname, ll - ls + 1) == s) return substr(s, 2)
    }
    return ""
}

# Returns the project-specific runtime type for lname if
# target_repo is registered in project_runtime_kw AND the
# matching keyword appears as a delimited token in lname, "" otherwise.
# Boundary check: the keyword must be bounded by start-of-string,
# end-of-string, or one of "-_. " — so "cosmo" matches
# "quickjs-cosmo-2026.zip" but not "cosmo-something-else-with-prefix"
# or "xcosmo-1.0.zip" (where "xcosmo" is a single word, not "cosmo"
# as a standalone token). Lets projects ship under their own naming
# convention without false-positive substring matches.
function project_runtime_of(lname,    kw, pos, pre, post) {
    if (target_repo == "") return ""
    if (! (target_repo in project_runtime_kw)) return ""
    kw = project_runtime_kw[target_repo]
    pos = index(lname, kw)
    if (pos == 0) return ""
    # Check left boundary.
    if (pos > 1) {
        pre = substr(lname, pos - 1, 1)
        if (pre !~ /[-_.]/) return ""
    }
    # Check right boundary.
    if (pos + length(kw) - 1 < length(lname)) {
        post = substr(lname, pos + length(kw), 1)
        if (post !~ /[-_.]/) return ""
    }
    return kw
}

# Returns the arch slot ("x64" or "arm64") for lname if it carries
# a runtime-arch token, "" otherwise. Used to route e.g. RPMs into
# runtime/rpm/x64 vs runtime/rpm (noarch). We strip the runtime
# suffix first so .rpm/.deb tokens don't poison the match.
function runtime_arch_of(lname, rtype,    base, i, ll, ls) {
    if (rtype == "") return ""
    base = lname
    ll = length(base)
    # Strip dotted suffix (".rpm", ".whl", ...) or bare match
    # ("pex" matching rtype "pex").
    if (ll > length(rtype) && substr(base, ll - length(rtype)) == "." rtype) {
        base = substr(base, 1, ll - length(rtype) - 1)
    } else if (base == rtype) {
        base = ""
    }
    for (i = 1; i <= n_runtime_arch; i++) {
        if (index(base, runtime_arch_tok[i]) > 0) return runtime_arch_key[i]
    }
    return ""
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

# Returns the libc/toolchain sub-slot suffix for lname, or "" if
# lname carries no `linux-gnu` / `linux-musl` / `windows-msvc` /
# `windows-gnu` token. The returned string is the bare suffix
# ("gnu" / "musl" / "msvc") so callers can build slots like
# `linux/x64/<suffix>`. Cross-group substring hazard doesn't
# apply here — libc tokens are mutually exclusive (a binary
# can't be both gnu and musl).
function libc_of(lname,    i, s) {
    for (i = 1; i <= n_libc_sub; i++) {
        s = arr_libc_sub[i]
        if (index(lname, s) > 0) {
            # arr_libc_sub entries are "linux-gnu" / "windows-msvc"
            # etc.; we want just the suffix after the dash.
            return substr(s, index(s, "-") + 1)
        }
    }
    return ""
}
