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
    ts = ""; entry = ""; count = 0
}

function colorize_entry(ts_iso, msg,    level, c_level) {
    if (!color) return "- " ts_iso " " msg
    if (match(msg, /^[IEWD]\|[^:]*: /)) {
        level = substr(msg, 1, 1)
        if (level == "D") c_level = c_debug
        else if (level == "I") c_level = c_info
        else if (level == "W") c_level = c_warn
        else if (level == "E") c_level = c_error
        return "- " c_ts ts_iso c_reset " " c_level substr(msg, 1, RLENGTH - 2) c_reset substr(msg, RLENGTH)
    }
    return "- " c_ts ts_iso c_reset " " msg
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

{
    if (match($0, /^- [0-9]+ /)) {
        ts = substr($0, 3, RLENGTH - 3)
        entry = colorize_entry(date_timestamp_to_iso(ts), substr($0, RLENGTH + 1))
        printf("%s\n", entry)
    } else {
        printf("%s\n", colorize_line($0))
    }
    fflush()
}
