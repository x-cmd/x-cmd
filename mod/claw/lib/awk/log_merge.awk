BEGIN {
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
    entries[idx] = "- " date_timestamp_to_iso(ts[idx]) " " substr(first, RLENGTH + 1) "\n"

    while ((getline line < file[idx]) > 0) {
        if (match(line, /^- [0-9]+ /) > 0) {
            pending[idx] = line
            break
        }
        entries[idx] = entries[idx] line "\n"
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
