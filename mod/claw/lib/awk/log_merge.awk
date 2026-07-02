BEGIN {
    color = ENVIRON["CLAW_LOG_COLOR"]
    claw_log_debug = ENVIRON["CLAW_LOG_DEBUG"]
    since_ts = ENVIRON["CLAW_LOG_SINCE_TS"] + 0
    limit = ENVIRON["CLAW_LOG_LIMIT"] + 0
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
        last_ts[i] = 0
        if (read_entry(i) > 0) active++
    }

    while (active > 0) {
        min = find_min()
        if (since_ts > 0 && ts[min] < since_ts) {
            if (read_entry(min) <= 0) active--
            continue
        }
        if (limit > 0) {
            buf_count++
            buf_idx = (buf_count - 1) % limit + 1
            buf[buf_idx] = entries[min]
        } else {
            printf "%s", entries[min]
        }
        if (read_entry(min) <= 0) active--
    }

    if (limit > 0 && buf_count > 0) {
        if (buf_count <= limit) {
            for (i = 1; i <= buf_count; i++) printf "%s", buf[i]
        } else {
            oldest = (buf_count % limit) + 1
            for (i = 0; i < limit; i++) {
                idx = oldest + i
                if (idx > limit) idx -= limit
                printf "%s", buf[idx]
            }
        }
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

function is_log_entry(line) {
    return match(line, /^[ ]*- ([0-9]+ )?[IEWD][|][^:]*: /)
}

function is_claw_debug_entry(line,    mstart) {
    if (claw_log_debug) return 0
    mstart = is_log_entry(line)
    if (!mstart) return 0
    match(substr(line, mstart), /[IEWD]\|[^:]*:/)
    return substr(line, mstart + RSTART - 1, RLENGTH) == "D|claw:"
}

function entry_has_timestamp(line) {
    return match(line, /^[ ]*- [0-9]+ /)
}


function read_entry(idx,    line, first, ts_, msg_, is_timestamped, tmp) {
    while (1) {
        entries[idx] = ""
        ts[idx] = 0
        is_timestamped = 0

        if (pending[idx] != "") {
            first = pending[idx]
            pending[idx] = ""
        } else if ((getline first < file[idx]) <= 0) {
            return 0
        }

        while (is_log_entry(first) == 0) {
            if ((getline first < file[idx]) <= 0) return 0
        }

        # extract the leading timestamp only, not digits inside the message
        if (match(first, /^[ ]*- [0-9]+ /) > 0) {
            tmp = substr(first, RSTART, RLENGTH)
            gsub(/[^0-9]/, "", tmp)
            ts_ = tmp + 0
            last_ts[idx] = ts_
            msg_ = substr(first, RSTART + RLENGTH)
            is_timestamped = 1
        } else if (last_ts[idx] == 0) {
            # module line before any timestamped entry; cannot assign a time
            while ((getline line < file[idx]) > 0) {
                if (is_log_entry(line) > 0) {
                    pending[idx] = line
                    break
                }
            }
            continue
        } else {
            ts_ = last_ts[idx]
        }

        if (is_claw_debug_entry(first)) {
            while ((getline line < file[idx]) > 0) {
                if (is_log_entry(line) > 0) {
                    pending[idx] = line
                    break
                }
            }
            continue
        }

        if (is_timestamped) {
            entries[idx] = colorize_entry(date_timestamp_to_iso(ts_), msg_)
        } else {
            # module line without its own timestamp (2-space older format or
            # 4-space nested format): promote to a standalone log entry
            match(first, /^[ ]*- ([0-9]+ )?/)
            msg_ = substr(first, RSTART + RLENGTH)
            entries[idx] = colorize_entry(date_timestamp_to_iso(ts_), msg_)
        }

        while ((getline line < file[idx]) > 0) {
            if (is_log_entry(line) > 0) {
                pending[idx] = line
                break
            }
            entries[idx] = entries[idx] colorize_line(line) "\n"
        }
        ts[idx] = ts_
        return 1
    }
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
