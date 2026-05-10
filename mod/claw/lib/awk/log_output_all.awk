BEGIN { ts = ""; entry = ""; count = 0 }

{
    if (match($0, /^- [0-9]+ /)) {
        if (ts != "" && entry != "") {
            key = ts "_" count
            entries[key] = entry
            keys[count] = key
            ts_vals[count] = ts + 0
            count++
        }
        ts = substr($0, 3, RLENGTH - 3)
        entry = "- " date_timestamp_to_iso(ts) " " substr($0, RLENGTH + 1) "\n"
        # entry = $0 "\n"
    } else {
        if (entry != "") {
            entry = entry $0 "\n"
        }
    }
}

END {
    if (ts != "" && entry != "") {
        key = ts "_" count
        entries[key] = entry
        keys[count] = key
        ts_vals[count] = ts + 0
        count++
    }
    for (i = 0; i < count - 1; i++) {
        for (j = i + 1; j < count; j++) {
            if (ts_vals[i] > ts_vals[j]) {
                tmp_key = keys[i]
                keys[i] = keys[j]
                keys[j] = tmp_key
                tmp_ts = ts_vals[i]
                ts_vals[i] = ts_vals[j]
                ts_vals[j] = tmp_ts
            }
        }
    }
    for (i = 0; i < count; i++) {
        printf "%s", entries[keys[i]]
    }
}
