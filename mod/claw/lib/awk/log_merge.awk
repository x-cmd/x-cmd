BEGIN {
    color = ENVIRON["CLAW_LOG_COLOR"]
    if (color) {
        c_reset = "\033[0m"
        c_ts    = "\033[90m"
        c_debug = "\033[2;35m"
        c_info  = "\033[32m"
        c_warn  = "\033[1;33m"
        c_error = "\033[1;31m"
    }

    n = split(ENVIRON["filelist"], file, "\n")

    active = 0
    for (i = 1; i <= n; i++) {
        if (read_entry(i) > 0) active++
    }

    while (active > 0) {
        min = find_min()
        printf "%s", entries[min]
        if (read_entry(min) <= 0) active--
    }

    exit(0)
}

function colorize_entry(ts_iso, msg,    level, c_level) {
    if (!color) return "- " ts_iso " " msg "\n"
    if (match(msg, /^[IEWD]\|[^:]*: /)) {
        level = substr(msg, 1, 1)
        if (level == "D") c_level = c_debug
        else if (level == "I") c_level = c_info
        else if (level == "W") c_level = c_warn
        else if (level == "E") c_level = c_error
        return "- " c_ts ts_iso c_reset " " c_level substr(msg, 1, RLENGTH - 2) c_reset substr(msg, RLENGTH) "\n"
    }
    return "- " c_ts ts_iso c_reset " " msg "\n"
}

function colorize_line(line,    level, c_level, mstart, mlen) {
    if (!color) return line
    if (match(line, /^[ ]*-?[ ]*[0-9]*[ ]*[IEWD][|][a-zA-Z]+: /)) {
        mstart = RSTART
        mlen = RLENGTH
        match(substr(line, mstart, mlen), /[IEWD][|][a-zA-Z]+/)
        level = substr(line, mstart + RSTART - 1, 1)
        if (level == "D") c_level = c_debug
        else if (level == "I") c_level = c_info
        else if (level == "W") c_level = c_warn
        else if (level == "E") c_level = c_error
        return substr(line, 1, mstart + RSTART - 2) c_level substr(line, mstart + RSTART - 1, RLENGTH) c_reset substr(line, mstart + RSTART + RLENGTH - 1)
    }
    return line
}

function read_entry(idx,    line, first) {
    entries[idx] = ""
    ts[idx] = 0

    if (pending[idx] != "") {
        first = pending[idx]
        pending[idx] = ""
    } else if ((getline line < file[idx]) <= 0) {
        return 0
    } else {
        first = line
    }

    if (match(first, /^- ([0-9]+) /) == 0) {
        return read_entry(idx)
    }

    ts[idx] = substr(first, 3, RLENGTH - 3) + 0
    entries[idx] = colorize_entry(date_timestamp_to_iso(ts[idx]), substr(first, RLENGTH + 1))

    while ((getline line < file[idx]) > 0) {
        if (match(line, /^- [0-9]+ /) > 0) {
            pending[idx] = line
            break
        }
        entries[idx] = entries[idx] colorize_line(line) "\n"
    }
    return 1
}

function find_min(    i, min_idx) {
    for (i = 1; i <= n; i++) {
        if (entries[i] != "") {
            min_idx = i
            break
        }
    }
    for (i = min_idx + 1; i <= n; i++) {
        if (entries[i] != "" && ts[i] < ts[min_idx]) {
            min_idx = i
        }
    }
    return min_idx
}
