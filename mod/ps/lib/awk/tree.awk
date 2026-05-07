# tree.awk — BFS traversal of process tree
# Supports multiple input modes and output formats
#
# Variables:
#   mode     - "ps" (default) or "proc"
#   order    - "bfs" (default) or "reverse"
#   output   - "pid" (default), "csv", or "tsv"
#
# Input (ps mode):  ps output with fields: user,ppid,pid,tty,pcpu,pmem,vsz,rss,stat,time,command
# Input (proc mode): "/proc/<pid>/" directory lines

BEGIN {
    visited[root] = 1
    queue[0] = root
    head = 0
    tail = 1

    L = "\001"
    result_count = 0

    if (mode == "")  mode = "ps"
    if (order == "") order = "bfs"
    if (output == "") output = "pidlist"

    if (output == "csv" || output == "tsv") {
        need_info = 1
        sep = (output == "csv") ? "," : "\t"
    } else {
        need_info = 0
    }
}

# ============ PS MODE ============
mode == "ps" && need_info == 1 {
    # Skip header line
    if (NR == 1) next

    pid = $3 + 0
    ppid = $2 + 0

    child_list[ppid, child_list[ppid, L]++] = pid

    proc_info[pid, "user"]    = $1
    proc_info[pid, "ppid"]    = $2
    proc_info[pid, "pid"]     = pid
    proc_info[pid, "tty"]     = $4
    proc_info[pid, "pcpu"]    = $5
    proc_info[pid, "pmem"]    = $6
    proc_info[pid, "vsz"]     = $7
    proc_info[pid, "rss"]     = $8
    proc_info[pid, "stat"]    = $9
    proc_info[pid, "time"]    = $10
    command = ""
    for (i = 11; i <= NF; i++) {
        if (command != "") command = command " "
        command = command $i
    }
    proc_info[pid, "command"] = command
    next
}

mode == "ps" && need_info == 0 {
    pid = $1 + 0
    ppid = $2 + 0
    if (ppid == "") ppid = 0
    child_list[ppid, child_list[ppid, L]++] = pid
    next
}

# ============ PROC MODE ============
mode == "proc" && /^[0-9]+$/ {
    pid = $0
    fname = "/proc/" pid "/stat"
    ppid = 0
    comm = ""

    while ((getline line < fname) > 0) {
        idx = index(line, ")")
        if (idx > 0) {
            rest = substr(line, idx + 1)
            gsub(/^[[:space:]]+/, "", rest)
            n = split(rest, fields, /[[:space:]]+/)
            ppid = (n >= 2) ? fields[2] + 0 : 0
            start = index(line, "(")
            end = index(line, ")")
            if (start > 0 && end > start) {
                comm = substr(line, start + 1, end - start - 1)
            }
        }
        break
    }
    close(fname)

    child_list[ppid, child_list[ppid, L]++] = pid + 0

    if (need_info) {
        uid = 0
        fname = "/proc/" pid "/status"
        while ((getline line < fname) > 0) {
            if (sub(/^Uid:/, "", line)) {
                gsub(/^[[:space:]]+/, "", line)
                split(line, fields, /[[:space:]]+/)
                uid = fields[1] + 0
                break
            }
        }
        close(fname)

        proc_info[pid, "user"]    = uid
        proc_info[pid, "ppid"]    = ppid
        proc_info[pid, "pid"]     = pid + 0

        pss_kb = 0
        fname = "/proc/" pid "/smaps_rollup"
        while ((getline line < fname) > 0) {
            if (sub(/^Pss:/, "", line)) {
                gsub(/^[[:space:]]+/, "", line)
                gsub(/[[:space:]]+.*$/, "", line)
                pss_kb = line + 0
                break
            }
        }
        close(fname)
        proc_info[pid, "pss"]     = pss_kb
        proc_info[pid, "command"] = comm
    }
    next
}

# ============ OUTPUT FUNCTIONS ============
function print_sep(data) {
    printf("%s%s", data, sep)
}

function print_ln(pid) {
    printf("%s\n", proc_info[pid, "command"])
}

function print_all(pid) {
    print_sep(proc_info[pid, "user"])
    print_sep(proc_info[pid, "ppid"])
    print_sep(proc_info[pid, "pid"])
    print_sep(proc_info[pid, "tty"])
    print_sep(proc_info[pid, "pcpu"])
    print_sep(proc_info[pid, "pmem"])
    print_sep(proc_info[pid, "vsz"])
    print_sep(proc_info[pid, "rss"])
    print_sep(proc_info[pid, "pss"])
    print_sep(proc_info[pid, "stat"])
    print_sep(proc_info[pid, "time"])
    print_ln(pid)
}

function print_title() {
    print_sep("USER")
    print_sep("PPID")
    print_sep("PID")
    print_sep("TTY")
    print_sep("%CPU")
    print_sep("%MEM")
    print_sep("VSZ")
    print_sep("RSS")
    print_sep("PSS")
    print_sep("STAT")
    print_sep("TIME")
    print_ln("COMMAND")
}

# ============ TRAVERSAL ============
END {
    while (head < tail) {
        p = queue[head++]
        for (i = 0; i < child_list[p, L]; i++) {
            pid = child_list[p, i]
            if (!visited[pid]) {
                visited[pid] = 1
                queue[tail++] = pid
                result_list[result_count++] = pid
            }
        }
    }

    # ============ OUTPUT ============
    if (output == "pidlist") {
        if (order == "reverse") {
            for (i = result_count - 1; i >= 0; i--) {
                printf "%s\n", result_list[i]
            }
            printf "%s\n", root
        } else {
            for (i = 0; i < result_count; i++) {
                printf "%s\n", result_list[i]
            }
            printf "%s\n", root
        }
    } else if (output == "pidline") {
        line = ""
        if (order == "reverse") {
            for (i = result_count - 1; i >= 0; i--) {
                if (line != "") line = line " "
                line = line result_list[i]
            }
        } else {
            for (i = 0; i < result_count; i++) {
                if (line != "") line = line " "
                line = line result_list[i]
            }
        }
        if (line != "") line = line " "
        line = line root
        print line
    } else if (output == "csv" || output == "tsv") {
        print_title()
        for (i = 0; i < result_count; i++) {
            print_all(result_list[i])
        }
    }
}