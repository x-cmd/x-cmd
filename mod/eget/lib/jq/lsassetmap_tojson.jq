# eget fit — TSV → JSON reshape.
#
# Input: raw-input TSV stream from ___x_cmd_eget_subcmd_fit___tsv.
#   Header line:  platform\tname\turl\tsize\tscore
#   Data rows, three shapes:
#     - native:   "native/<os>/<arch>" or "native/<type>/<os>/<arch>"
#                 → goes under .native
#     - package:  "package/<type>/<arch>"
#                 → goes under .package
#     - runtime:  "runtime/<type>" or "runtime/<type>/<arch>"
#                 → goes under .runtime
#   Empty asset rows have only the platform column set.
#
# Output: a single JSON object with three top-level keys:
#   .native   — platform-compiled machine code binary slots
#               (tar.gz / zip / .exe / AppImage etc.)
#   .package  — system packages (.rpm / .deb / .dmg / .msi /
#               .apk / .pkg.tar.zst / .flatpak / .snap)
#   .runtime  — interpreter / VM packages (.whl / .jar / .pex /
#               .pyz / .js / .py / .ts / .wasm / .node / .gem /
#               .nupkg / .vsix / .crate / .cosmo)
# Each value is {name, url, size, score, sig?, sha256?, sha1?,
# sha512?, md5?}. Pair sig/hash URLs are looked up from
# --argjson release (a {assets: [{name, browser_download_url}]}
# object) by appending the known pair suffix to the asset name.
#
# Run as: jq -Rrs --argjson release "$RELEASE_JSON" -f lib/jq/lsassetmap_tojson.jq

(($release.assets // []) | map({(.name): .browser_download_url}) | add // {}) as $by_name
| split("\n")
| .[1:]                                       # drop header
| map(select(length > 0))
| map(split("\t") | . + ["","","","","",""] | .[0:5])
| map(.[0] as $plat | .[1] as $name | {
    ($plat): (
        if .[1] == "" then null
        else {
            name:  .[1],
            url:   .[2],
            size:  (if .[3] == "" then null else (.[3] | tonumber) end),
            score: (if .[4] == "" then null else (.[4] | tonumber) end),
            sig:    ($by_name[$name + ".sig"]               // $by_name[$name + ".asc"]
                  // $by_name[$name + ".minisig"]           // $by_name[$name + ".minisig.json"]
                  // $by_name[$name + ".pem"]               // null),
            sha256: ($by_name[$name + ".sha256"]            // $by_name[$name + ".sha256sum"] // null),
            sha512: ($by_name[$name + ".sha512"]            // $by_name[$name + ".sha512sum"] // null),
            sha1:   ($by_name[$name + ".sha1"]              // null),
            md5:    ($by_name[$name + ".md5"]               // $by_name[$name + ".sum"]      // null)
        } | with_entries(select(.value != null))
        end
    )
})
| (add // {})
| to_entries
| map(select(.key != null and (.key | split("/") | length) > 1))
| group_by(.key | split("/")[0]) as $groups
| (reduce $groups[] as $g (
    {};
    ($g[0].key | split("/")[0]) as $bucket
    | .[$bucket] = (
        reduce $g[] as $e ({}; . + {($e.key | sub("^" + $bucket + "/"; "")): $e.value})
    )
)) as $buckets
# Always emit all three bucket keys (native / package / runtime)
# even when empty, so consumers can rely on the shape.
| {native: ($buckets.native // {}), package: ($buckets.package // {}), runtime: ($buckets.runtime // {})}
# Old buggy code: reuses the same key across rows in the same
# group, so `+` would always error. The fix is above — within one
# group the keys are unique after the per-bucket prefix is stripped.
