# shellcheck shell=awk
# top_linux.awk — Read /proc directly for free module's top process list
# Input:  list of /proc/[0-9]* directories, one per line
# Output: TSV (RSS\tELAPSED\tPID\tCOMMAND) — same format as "x ps --tsv ax -o rss,etime,pid,command"
#
# Reads only what free needs: stat (rss, starttime), cmdline, smaps_rollup (pss)
# Skips: uid, %cpu, %mem, vsz, tty, stat, started (not needed by free)

BEGIN {
    page_size = 4096
    clk_tck = 100
    boot_time = 0
    proc_count = 0

    # Read boot time (once)
    while ((getline < "/proc/stat") > 0) {
        if ($1 == "btime") { boot_time = $2; break }
    }
    close("/proc/stat")

    # Print TSV header (compatible with top.awk NR==1 skip)
    print "RSS\tELAPSED\tPID\tCOMMAND"
}

{
    dir = $0
    sub(/\/$/, "", dir)

    pid = dir
    sub(/.*\//, "", pid)
    if (pid !~ /^[0-9]+$/) next

    # --- Read /proc/<pid>/stat ---
    stat_line = ""
    fname = dir "/stat"
    while ((getline < fname) > 0) { stat_line = $0 }
    close(fname)
    if (stat_line == "") next

    # Parse: pid (comm) state ppid pgrp session tty_nr tpgid ...
    rest = stat_line
    sub(/^[0-9]+[ \t]+/, "", rest)
    # Skip comm (in parentheses, may contain spaces)
    if (match(rest, /\([^)]+\)/)) {
        rest = substr(rest, RSTART + RLENGTH + 1)
    }

    n = split(rest, f, /[ \t]+/)

    # f[12]=utime f[13]=stime f[20]=starttime f[21]=vsize f[22]=rss(pages)
    rss_pages = (n >= 22) ? f[22] + 0 : 0
    starttime = (n >= 20) ? f[20] + 0 : 0

    rss_kb = int(rss_pages * page_size / 1024)

    # --- Read /proc/<pid>/cmdline ---
    cmdline = ""
    fname = dir "/cmdline"
    while ((getline line < fname) > 0) {
        gsub(/\0/, " ", line)
        if (cmdline != "") cmdline = cmdline " "
        cmdline = cmdline line
    }
    close(fname)
    if (cmdline == "") next       # skip kernel threads
    sub(/[ \t]+$/, "", cmdline)

    # --- Read /proc/<pid>/smaps_rollup for PSS ---
    pss_kb = 0
    fname = dir "/smaps_rollup"
    while ((getline < fname) > 0) {
        if ($1 == "Pss:") { pss_kb = $2 + 0 }
    }
    close(fname)

    # Use PSS if available, else RSS
    mem_kb = (pss_kb > 0) ? pss_kb : rss_kb

    # --- Compute etime ---
    etime_str = ""
    if (boot_time > 0 && clk_tck > 0) {
        elapsed_ticks = (systime() - boot_time) * clk_tck - starttime
        if (elapsed_ticks < 1) elapsed_ticks = 1
        elapsed_s = int(elapsed_ticks / clk_tck)
        ed = int(elapsed_s / 86400)
        eh = int((elapsed_s % 86400) / 3600)
        em = int((elapsed_s % 3600) / 60)
        es = int(elapsed_s % 60)
        if (ed > 0)       etime_str = sprintf("%02d-%02d:%02d:%02d", ed, eh, em, es)
        else if (eh > 0)  etime_str = sprintf("%02d:%02d:%02d", eh, em, es)
        else              etime_str = sprintf("%02d:%02d", em, es)
    }

    # --- Output TSV ---
    printf "%d\t%s\t%d\t%s\n", mem_kb, etime_str, pid + 0, cmdline
}
