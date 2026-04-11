# linuxps.awk — Read /proc/[pid] files to produce ps-compatible output
# Input:  list of /proc/[0-9]* directories, one per line
# Output: whitespace-aligned table (for downstream tocsv)
#
# Variable: fields="rss,etime,pid,command"  (comma-separated output field list)
#   If empty, defaults to: user,pid,pcpu,pmem,vsz,rss,tty,stat,started,time,command
#
# Available fields:
#   user ppid pid tty pcpu pmem vsz rss pss stat started time etime command

BEGIN {
    page_size = 4096
    clk_tck = 100
    boot_time = 0
    total_mem = 0
    proc_count = 0

    # Read boot time from /proc/stat
    while ((getline < "/proc/stat") > 0) {
        if ($1 == "btime") { boot_time = $2; break }
    }
    close("/proc/stat")

    # Read total memory from /proc/meminfo
    while ((getline < "/proc/meminfo") > 0) {
        if ($1 == "MemTotal:") { total_mem = $2; break }
    }
    close("/proc/meminfo")

    # Parse fields variable into output_fields array
    if (fields == "") {
        fields = "user,pid,pcpu,pmem,vsz,rss,tty,stat,started,time,command"
    }
    n_out = split(fields, out_fields, /,/)

    # Map field names to header display names
    hdr["user"]    = "USER"
    hdr["ppid"]    = "PPID"
    hdr["pid"]     = "PID"
    hdr["tty"]     = "TT"
    hdr["pcpu"]    = "%CPU"
    hdr["pmem"]    = "%MEM"
    hdr["vsz"]     = "VSZ"
    hdr["rss"]     = "RSS"
    hdr["pss"]     = "PSS"
    hdr["stat"]    = "STAT"
    hdr["started"] = "STARTED"
    hdr["time"]    = "TIME"
    hdr["etime"]   = "ELAPSED"
    hdr["command"] = "COMMAND"
}

# First pass: collect all process data into arrays
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

    rest = stat_line
    sub(/^[0-9]+[ \t]+/, "", rest)
    comm = ""
    if (match(rest, /\([^)]+\)/)) {
        comm = substr(rest, RSTART + 1, RLENGTH - 2)
        rest = substr(rest, RSTART + RLENGTH + 1)
    }

    n = split(rest, f, /[ \t]+/)

    state     = (n >= 1)  ? f[1]  : "?"
    ppid_v    = (n >= 2)  ? f[2]  : 0
    tty_nr    = (n >= 5)  ? f[5]  : 0
    utime     = (n >= 12) ? f[12] + 0 : 0
    stime     = (n >= 13) ? f[13] + 0 : 0
    starttime = (n >= 20) ? f[20] + 0 : 0
    vsize     = (n >= 21) ? f[21] + 0 : 0
    rss_pages = (n >= 22) ? f[22] + 0 : 0

    rss_kb = int(rss_pages * page_size / 1024)
    vsz_kb = int(vsize / 1024)

    # --- Read /proc/<pid>/status for UID ---
    uid = 0
    fname = dir "/status"
    while ((getline < fname) > 0) {
        if ($1 == "Uid:") { uid = $2 + 0; break }
    }
    close(fname)

    # --- Read /proc/<pid>/cmdline ---
    cmdline = ""
    fname = dir "/cmdline"
    while ((getline line < fname) > 0) {
        gsub(/\0/, " ", line)
        if (cmdline != "") cmdline = cmdline " "
        cmdline = cmdline line
    }
    close(fname)
    if (cmdline == "") cmdline = "[" comm "]"
    sub(/[ \t]+$/, "", cmdline)

    # --- Read /proc/<pid>/smaps_rollup for PSS ---
    pss_kb = 0
    fname = dir "/smaps_rollup"
    while ((getline < fname) > 0) {
        if ($1 == "Pss:") { pss_kb = $2 + 0 }
    }
    close(fname)
    if (pss_kb == 0) pss_kb = rss_kb

    # --- Derived fields ---
    if (tty_nr == 0) {
        tty = "?"
    } else {
        major = int(tty_nr / 256)
        minor = tty_nr % 256
        if (major == 136)      tty = "pts/" minor
        else if (major == 4)   tty = "tty" minor
        else                   tty = sprintf("%d,%d", major, minor)
    }

    elapsed_ticks = 0
    if (boot_time > 0 && clk_tck > 0) {
        elapsed_ticks = systime() * clk_tck - starttime
        if (elapsed_ticks < 1) elapsed_ticks = 1
    }
    total_ticks = utime + stime
    pcpu = (elapsed_ticks > 0) ? (total_ticks * 100.0 / elapsed_ticks) : 0
    pmem = (total_mem > 0) ? (rss_kb * 100.0 / total_mem) : 0

    started = ""
    if (boot_time > 0 && clk_tck > 0) {
        start_epoch = boot_time + int(starttime / clk_tck)
        started = strftime("%b%d", start_epoch)
    }

    total_time_s = total_ticks / clk_tck
    time_h = int(total_time_s / 3600)
    time_m = int((total_time_s % 3600) / 60)
    time_s_v = int(total_time_s % 60)
    time_str = sprintf("%d:%02d:%02d", time_h, time_m, time_s_v)

    etime_str = ""
    if (elapsed_ticks > 0) {
        elapsed_s = int(elapsed_ticks / clk_tck)
        ed = int(elapsed_s / 86400)
        eh = int((elapsed_s % 86400) / 3600)
        em = int((elapsed_s % 3600) / 60)
        es_v = int(elapsed_s % 60)
        if (ed > 0)       etime_str = sprintf("%d-%02d:%02d:%02d", ed, eh, em, es_v)
        else if (eh > 0)  etime_str = sprintf("%02d:%02d:%02d", eh, em, es_v)
        else              etime_str = sprintf("%02d:%02d", em, es_v)
    }

    proc_count++
    p_user[proc_count]    = uid
    p_ppid[proc_count]    = ppid_v
    p_pid[proc_count]     = pid + 0
    p_tty[proc_count]     = tty
    p_pcpu[proc_count]    = pcpu
    p_pmem[proc_count]    = pmem
    p_vsz[proc_count]     = vsz_kb
    p_rss[proc_count]     = rss_kb
    p_pss[proc_count]     = pss_kb
    p_stat[proc_count]    = state
    p_started[proc_count] = started
    p_time[proc_count]    = time_str
    p_etime[proc_count]   = etime_str
    p_command[proc_count] = cmdline
}

END {
    if (proc_count == 0) exit 0

    # Print header (column-aligned, matches ps output style)
    for (i = 1; i <= n_out; i++) {
        if (i > 1) printf "  "
        fn = out_fields[i]
        if (fn == "command")       printf "%-60s", hdr[fn]
        else if (fn == "user")     printf "%-8s", hdr[fn]
        else if (fn == "etime")    printf "%-16s", hdr[fn]
        else                       printf "%-8s", hdr[fn]
    }
    printf "\n"

    # Print data rows (column-aligned for tocsv compatibility)
    for (p = 1; p <= proc_count; p++) {
        for (i = 1; i <= n_out; i++) {
            if (i > 1) printf "  "
            fn = out_fields[i]

            if (fn == "command")       printf "%s", p_command[p]
            else if (fn == "user")     printf "%-8s", p_user[p]
            else if (fn == "ppid")     printf "%-8d", p_ppid[p]
            else if (fn == "pid")      printf "%-8d", p_pid[p]
            else if (fn == "tty")      printf "%-5s", p_tty[p]
            else if (fn == "pcpu")     printf "%-8.1f", p_pcpu[p]
            else if (fn == "pmem")     printf "%-8.1f", p_pmem[p]
            else if (fn == "vsz")      printf "%-8d", p_vsz[p]
            else if (fn == "rss")      printf "%-8d", p_rss[p]
            else if (fn == "pss")      printf "%-8d", p_pss[p]
            else if (fn == "stat")     printf "%-5s", p_stat[p]
            else if (fn == "started")  printf "%-8s", p_started[p]
            else if (fn == "time")     printf "%-8s", p_time[p]
            else if (fn == "etime")    printf "%-16s", p_etime[p]
        }
        printf "\n"
    }
}
