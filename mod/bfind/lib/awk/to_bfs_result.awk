# BFS depth sort + next-level probe
#
# Variables expected (passed via -v):
#   base  - normalized root path (no trailing /), used to compute base_nf
#   min   - min depth to output
#   max   - max depth to output
#   peek  - if non-empty, also probe depth max+1 and write summary to stderr
#
# Reads paths from stdin, outputs depths min..max in order.
# When peek is on, writes a stderr summary block:
#   ---
#   next-level: <expandable dirs at max>
#   next-level-count: <total child entries at max+1>
#   ---

BEGIN { base_nf = split(base, _a, "/") }
{
    d = split($0, _a, "/") - base_nf
    buf[d] = buf[d] $0 ORS
    if (peek && d == max + 1) {
        _n = split($0, _p, "/")
        parent = _p[1]
        for (j = 2; j < _n; j++) parent = parent "/" _p[j]
        chd[parent]++
    }
}
END {
    for (d = min; d <= max; d++) printf "%s", buf[d]
    if (peek) {
        n = split(buf[max], _l, "\n")
        nl = 0; nlc = 0
        for (i = 1; i <= n; i++) if (_l[i] != "" && chd[_l[i]] > 0) { nl++; nlc += chd[_l[i]] }
        printf "---\nnext-level: %d\nnext-level-count: %d\n---\n", nl, nlc > "/dev/stderr"
    }
}
