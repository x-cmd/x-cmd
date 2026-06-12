# fill.awk — invoked by ___x_cmd_column___fill from lib/main.
#
# Variables (set with -v by the shell wrapper):
#   width      output width in columns (used to choose side-by-side count).
#              Defaults to 80 when unset / invalid.
#   color      "1" to wrap first row with reverse video (highlighted title)
#   colcolors  colon-separated per-column ANSI SGR codes, e.g. "36:33:35"
#              empty/0 entries are uncolored. Past-end cols also uncolored.
#
# Each input line is one entry. We compute the widest entry (in DISPLAY
# CELLS, so CJK = 2 cells), decide how many side-by-side columns fit in
# `width`, then fill column-first (matches GNU `column` without -x):
# the first N lines go in column 1, the next N in column 2, etc.
#
# No per-row state survives between lines; padding is recomputed in
# the END block from the full list.
#
# fill mode is simpler than table mode: no CSI column jumps, no row
# underline. Just space-padding + per-column color (tty only) +
# title-row reverse for the first row. tty only because that's where
# ANSI escape codes are useful; pure mode stays zero-decoration.

BEGIN {
    if (width == "" || width + 0 < 1) width = 80
    nlines = 0
    maxw = 0

    ESC = sprintf("%c", 27)
    RESET = ESC "[0m"
    REVERSE = ESC "[7m"

    for (_i = 0; _i < 256; _i++) _bv[sprintf("%c", _i)] = _i

    ncc = 0
    if (colcolors != "") {
        nt = split(colcolors, tmp, ":")
        for (i = 1; i <= nt; i++) {
            if (tmp[i] != "") { ncc++; ccol[ncc] = ESC "[" tmp[i] "m" }
        }
    }
}

function _ord(c) { return _bv[c] + 0 }

function cellwidth(s,    i, n, b, w) {
    w = 0
    n = length(s)
    i = 1
    while (i <= n) {
        b = _ord(substr(s, i, 1))
        if (b < 128)        { w += 1; i += 1 }
        else if (b < 192)   { i += 1 }
        else if (b < 224)   { w += 1; i += 2 }
        else if (b < 240)   { w += 2; i += 3 }
        else                { w += 2; i += 4 }
    }
    return w
}

{
    nlines++
    lines[nlines] = $0
    w = cellwidth($0)
    if (w > maxw) maxw = w
}
END {
    if (nlines == 0) exit 0
    gap = 2
    col_w = maxw + gap
    if (col_w < 1) col_w = 1
    ncols = int((width + gap) / col_w)
    if (ncols < 1) ncols = 1
    if (ncols > nlines) ncols = nlines
    rows_per_col = int((nlines + ncols - 1) / ncols)
    if (rows_per_col < 1) rows_per_col = 1

    for (r = 1; r <= rows_per_col; r++) {
        out = ""
        for (c = 1; c <= ncols; c++) {
            idx = (c - 1) * rows_per_col + r
            if (idx > nlines) break
            cell = lines[idx]
            vlen = cellwidth(cell)
            if (c < ncols) {
                target = maxw + gap
            } else {
                target = vlen
            }
            pad = target - vlen
            if (pad < 0) pad = 0
            # Build padded cell first
            padded = cell
            while (pad-- > 0) padded = padded " "
            if (c == ncols) sub(/[ \t]+$/, "", padded)
            # Wrap with per-column color (if any)
            if (c <= ncc) {
                out = out ccol[c] padded RESET
            } else {
                out = out padded
            }
        }
        sub(/[ \t]+$/, "", out)
        # First row gets reverse video highlight (title)
        if (color == "1" && r == 1) out = REVERSE out RESET
        print out
    }
}
