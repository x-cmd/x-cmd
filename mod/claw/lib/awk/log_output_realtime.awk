BEGIN {
    color = ENVIRON["CLAW_LOG_COLOR"]
    claw_log_debug = ENVIRON["CLAW_LOG_DEBUG"]
    if (color) {
        c_reset = "\033[0m"
        c_ts    = "\033[90m"
        c_debug = "\033[2;35m"
        c_info  = "\033[32m"
        c_warn  = "\033[1;33m"
        c_error = "\033[1;31m"
    }
    ts = ""; entry = ""; count = 0; skip = 0
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

function is_log_entry(line) {
    return match(line, /^[ ]*- ([0-9]+ )?[IEWD][|][^:]*: /)
}

function is_claw_debug(line,    mstart) {
    if (claw_log_debug) return 0
    mstart = is_log_entry(line)
    if (!mstart) return 0
    match(substr(line, mstart), /[IEWD]\|[^:]*:/)
    return substr(line, mstart + RSTART - 1, RLENGTH) == "D|claw:"
}

function entry_has_timestamp(line) {
    return match(line, /^[ ]*- [0-9]+ /)
}

{
    if (is_log_entry($0)) {
        # extract the leading timestamp only, not digits inside the message
        if (match($0, /^[ ]*- [0-9]+ /) > 0) {
            tmp = substr($0, RSTART, RLENGTH)
            gsub(/[^0-9]/, "", tmp)
            ts = tmp
        }

        if (is_claw_debug($0)) {
            skip = 1
        } else {
            skip = 0
            if (match($0, /^[ ]*- [0-9]+ /) > 0) {
                printf("%s\n", colorize_entry(date_timestamp_to_iso(ts), substr($0, RSTART + RLENGTH)))
            } else {
                # module line without its own timestamp (2-space older format or
                # 4-space nested format): promote to a standalone log entry
                match($0, /^[ ]*- ([0-9]+ )?/)
                printf("%s\n", colorize_entry(date_timestamp_to_iso(ts), substr($0, RSTART + RLENGTH)))
            }
        }
    } else {
        if (!skip) {
            printf("%s\n", colorize_line($0))
        }
    }
    fflush()
}
