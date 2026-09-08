# eget lsassetmap — TSV → JSON reshape.
#
# Input: raw-input TSV stream from ___x_cmd_eget_subcmd_lsassetmap___tsv.
#   Header line:  platform\tname\turl\tsize\tscore
#   6 data rows. Empty asset rows have only the platform column set.
#
# Output: a single JSON object keyed by `platform` (singular), with
# the 6 standard platform keys (darwin/{arm64,amd64}, linux/{arm64,amd64},
# win/{arm64,amd64}) as nested objects. Each value has name/url/size/score
# with `null` for unset fields. `size` and `score` are emitted as
# numbers (not strings) when set, so callers can do arithmetic.
#
# Schema matches lib/awk/lsassetmap_yml.awk's YAML output — the
# yml output wraps `eget:` → `platform:` around this same shape; the
# JSON output skips the eget wrapper (caller composes that key if
# they want it) and emits the platform mapping directly.
#
# Run as: jq -Rrs -f lib/jq/lsassetmap_tojson.jq

split("\n")
| map(select(length > 0))
| .[1:]                                       # drop header row
| map(split("\t") | . + ["","","","","",""] | .[0:5])
| map({
    (.[0]): {
        name:  (if .[1] == "" then null else .[1] end),
        url:   (if .[2] == "" then null else .[2] end),
        size:  (if .[3] == "" then null else (.[3] | tonumber) end),
        score: (if .[4] == "" then null else (.[4] | tonumber) end)
    }
}) | add
