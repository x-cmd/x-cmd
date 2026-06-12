# table.awk — invoked by ___x_cmd_column___table from lib/main.
#
# Variables (set with -v by the shell wrapper):
#   delim_re       regex char class like "[:]" or "" for whitespace mode
#   delim_was_set  "1" if -s was given, "0" if whitespace mode
#   outsep         output column separator (default "  ")
#   squeeze        "1" to collapse runs of delimiters, "0" to keep empties
#   color          "1" to wrap title row (r==1) with ANSI reverse video (7m)
#   colcolors      colon-separated per-column ANSI SGR codes, e.g. "31:32:33"
#   every_n        "N" -> underline every Nth line (1-based: r % N == 1)
#                  "0" / unset -> no underline
#   use_csi        "1" -> use CSI Horizontal Absolute to jump to next column
#                  start (tty mode; CJK-safe). "0" / unset -> space-pad.
#
# Implementation note: do NOT accumulate the row in a local string and
# then `print` it. Instead, mutate $1..$N in place with the padded /
# colored cells, then use awk's natural $0 rebuild + print. OFS is the
# variable separator (outsep for pure, "" for tty), and the row-level
# decoration (REVERSE / UNDERLINE) wraps the rebuilt $0.

BEGIN {
    nrows = 0
    ncols = 0
    if (delim_was_set == "1") {
        FS = delim_re
    } else if (squeeze == "1") {
        FS = "[ \t]+"
    } else {
        FS = "[ \t]"
    }

    ESC = sprintf("%c", 27)
    RESET = ESC "[0m"
    REVERSE = ESC "[7m"
    UNDERLINE = ESC "[4m"

    # Byte-value lookup for UTF-8 lead-byte classification.
    for (_i = 0; _i < 256; _i++) _bv[sprintf("%c", _i)] = _i

    # Parse colcolors: "31:32:33" -> ccol[1]="31", ccol[2]="32", ...
    ncc = 0
    if (colcolors != "") {
        nt = split(colcolors, tmp, ":")
        for (i = 1; i <= nt; i++) {
            if (tmp[i] != "") {
                ncc++
                ccol[ncc] = ESC "[" tmp[i] "m"
            }
        }
    }
    if (every_n == "") every_n = 0
    every_n = every_n + 0
    if (use_csi == "") use_csi = 0
    use_csi = use_csi + 0
}

function _ord(c) { return _bv[c] + 0 }

# cellwidth(s) — count display cells of a UTF-8 string.
# Heuristic: 1B=1cell, 2B=1cell, 3B=2cell, 4B=2cell.
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

# pack_cell(s, i, is_last) -> build the cell string with padding and
# any per-column color. Caller assigns result to $i. For is_last==1
# (last column) padding is 0 (no trailing whitespace needed).
function pack_cell(s, i, is_last,    vlen, target, pad) {
    vlen = cellwidth(s)
    if (is_last) {
        target = vlen
    } else {
        target = maxw[i]
    }
    pad = target - vlen
    if (pad < 0) pad = 0
    while (pad-- > 0) s = s " "
    if (i <= ncc) s = ccol[i] s RESET
    return s
}

{
    line = $0
    if (delim_was_set == "0") {
        sub(/^[ \t]+/, "", line)
        sub(/[ \t]+$/, "", line)
    } else {
        sub(/[ \t]+$/, "", line)
    }

    nf = (line == "" ? 0 : split(line, parts, FS))
    nrows++
    if (nf > ncols) ncols = nf
    for (i = 1; i <= nf; i++) {
        w = cellwidth(parts[i])
        if (w + 0 > maxw[i] + 0) maxw[i] = w
        cell[nrows, i] = parts[i]
    }
}
END {
    if (nrows == 0) exit 0
    gap = length(outsep)
    if (gap < 1) { outsep = "  "; gap = 2 }

    # Pre-compute column start positions (1-based, in cells) for CSI mode.
    if (use_csi == 1) {
        colstart[1] = 1
        for (i = 1; i < ncols; i++) {
            colstart[i + 1] = colstart[i] + maxw[i] + gap
        }
    }

    for (r = 1; r <= nrows; r++) {
        # How many cells does this row actually have? (ps-style input
        # often has rows with varying NF — GNU column's "correct" behavior
        # is to truncate trailing empty cells and not pad them out to the
        # global ncols.)
        row_nf = 0
        for (i = 1; i <= ncols; i++) {
            if ((r, i) in cell) row_nf = i
        }
        # Mutate $1..$row_nf: set to the padded + colored cell.
        for (i = 1; i <= row_nf; i++) {
            v = cell[r, i]
            $i = pack_cell(v, i, i == row_nf)
        }
        # Set NF = row_nf so the rebuilt $0 ends at the row's last real
        # cell. Without this, $0 would carry the last input line's NF
        # and emit trailing OFS separators + empty cells.
        NF = row_nf

        if (use_csi == 1) {
            # tty mode: walk $i..$row_nf, emit each cell then a CSI
            # jump to the next column start. $0 still has OFS glue
            # which we set to "" so cells just abut.
            OFS = ""
            $1 = $1   # force $0 rebuild (visually no-op since OFS="")
            line = ""
            for (i = 1; i <= row_nf; i++) {
                line = line $i
                if (i < row_nf) line = line ESC "[" colstart[i + 1] "G"
            }
        } else {
            # pure mode: set OFS to the gap first, THEN rebuild $0.
            # (Order matters: $1=$1 only picks up the current OFS, not
            # the one set after the assignment.)
            OFS = outsep
            $1 = $1
            line = $0
        }

        # Row-level decorations wrap the rebuilt line.
        if (color == "1" && r == 1) line = REVERSE line RESET
        if (every_n > 0 && r % every_n == 1) line = UNDERLINE line RESET

        print line
    }
}
