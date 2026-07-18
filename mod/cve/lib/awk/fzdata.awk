#!/usr/bin/awk -f
#
# x-cmd cve lib/awk/fzdata.awk — TSV → ANSI-colored fzf stream.
#
# Lives in its own file so the colour rules are easy to scan and edit
# without scrolling through shell scaffolding. Called from
# ___x_cmd_cve_fz_stream in lib/fz/_index:
#
#   ... | awk -f "$___X_CMD_ROOT_MOD/cve/lib/awk/fzdata.awk" -v esc="$esc"
#
# We deliberately avoid red — many terminals render ANSI red as a hue
# that dominates the rest of the picker, and 94% of cvelistV5 rows are
# unrated (which would be red). Magenta (35) is the eye-catching
# stand-in for CRITICAL.
#
# Severity buckets (CVSS v3.x):
#   unrated (no score)   → dim grey       (90)
#   9.0–10.0  CRITICAL   → magenta        (35)
#   7.0–8.9   HIGH       → yellow         (33)
#   5.0–6.9   MEDIUM     → cyan           (36)
#   0.1–4.9   LOW        → green          (32)
#
# Input:  TSV with the 9-column layout produced by _cve_index.py.
#   $1 cve   $2 year  $3 no    $4 vp
#   $5 ghsa  $6 score $7 patched $8 cwe
#   $9 desc
#
# Output: 5 tab-delimited fields (cve, score, ghsa, vp, cwe, desc).
#   - cve id    : coloured by severity bucket so the whole id jumps out
#   - score     : same colour + bold, right-aligned
#   - ghsa      : cyan, truncated to 19 chars
#   - vp        : "<vendor>/<product>", full untruncated string
#                 (multi-affected CVEs can have dozens of vendor/product
#                 pairs; truncation hides the actually-affected stack)
#   - cwe       : "CWE-NNNN" (prefix added), green
#   - desc      : dim, full first sentence (producer caps at 240 chars)

function sev(s,    n) {
    if (s == "") return esc "[90m"    # UNRATED — dim grey
    n = s + 0
    if (n >= 9.0) return esc "[35m"   # CRITICAL magenta
    if (n >= 7.0) return esc "[33m"   # HIGH yellow
    if (n >= 5.0) return esc "[36m"   # MEDIUM cyan
    return esc "[32m"                 # LOW green
}

BEGIN { FS = "\t"; OFS = "\t" }

# Skip the manifest header. We don't actually expect one in this
# stream (the dispatcher emits its own header), but be defensive.
NR == 1 && $1 ~ /^year$/ { next }

{
    score = ($6 == "" ? "  - " : sprintf("%5s", $6))
    ghsa  = ($5 == "" ? "       " : substr($5, 1, 19))
    vp    = $4   # full vendor/product string — never truncated
    cwe   = ($8 == "" ? "" : "CWE-" $8)
    sc    = sev($6)

    # cve   score   ghsa   vp   cwe   desc
    printf "%s%s%s\t%s%s%s%s\t%s%s%s\t%s%s%s\t%s%s%s\t%s%s\n",
        sc,         $1,    esc "[0m",                    # severity-coloured cve id
        sc,         esc "[1m", score, esc "[0m",         # coloured + bold score
        esc "[36m", ghsa,  esc "[0m",                     # cyan ghsa
        esc "[33m", vp,    esc "[0m",                     # yellow vp (vendor/product)
        esc "[32m", cwe,   esc "[0m",                     # green cwe
        esc "[2m",  $9                                    # dim desc
}