# shellcheck shell=awk
# top.awk - Top process listing for x free
# Input: x ps --tsv ax -o rss,etime,pid,command  (TSV with header)
# Variables: top_n, group (auto|cmd|none), format, header, NO_COLOR, filter, mem_col, physfp_cmd
#
# mem_col: "rss" (default) or "mem" (macOS phys_footprint via proc_pid_rusage)
# physfp_cmd: command to run for phys_footprint data (e.g. python3 top_physfp.py)

BEGIN {
    FS = "\t"
    total = 0
    NO_COLOR = NO_COLOR + 0
    top_n = top_n + 0
    header = header + 0
    filter = filter ""
    mem_col = mem_col ""
    physfp_cmd = physfp_cmd ""

    # Load phys_footprint data via pipe (macOS: proc_pid_rusage)
    if (mem_col == "mem" && physfp_cmd != "") {
        while ((physfp_cmd | getline) > 0) {
            pf_kb[$1 + 0] = $2 + 0
        }
        close(physfp_cmd)
    }
}

# Skip header line
NR == 1 { next }

# Skip empty lines
/^$/ { next }

{
    rss = $1 + 0
    etime = $2
    pid = $3 + 0
    cmdline = $4
    if (cmdline == "") next
    if (filter != "" && cmdline !~ filter) next

    # Use phys_footprint if available, else fall back to RSS
    mem = (mem_col == "mem" && pid in pf_kb) ? pf_kb[pid] : rss

    key = get_group_key(cmdline)

    if (group == "none") {
        total++
        items_mem[total]     = mem
        items_cmdline[total] = cmdline
        items_etime[total]   = etime
        items_pid[total]     = pid
    } else {
        g_mem[key]   += mem
        g_count[key] += 1
        if (!(key in g_etime) || etime_to_secs(etime) > etime_to_secs(g_etime[key])) {
            g_etime[key] = etime
        }
        if (!(key in g_display)) {
            g_display[key] = get_group_display(cmdline)
        }
        g_pids[key] = (key in g_pids) ? g_pids[key] "|" pid : pid
    }
}

END {
    init_colors(NO_COLOR)

    if (group == "none") {
        sort_ungrouped()
        n = total
    } else {
        sort_grouped()
    }

    # --precise mode: call footprint CLI for multi-process groups to get
    # accurate cross-process deduped Summary Footprint
    if (use_fp + 0 == 1 && mem_col == "mem" && group != "none") {
        fp_limit = top_n * 2
        if (fp_limit > n) fp_limit = n
        for (i = 1; i <= fp_limit; i++) {
            if (s_count[i] > 1) {
                fp = get_group_footprint(s_pids[i])
                if (fp > 0) s_mem[i] = fp
            }
        }
        # Re-sort after footprint correction
        for (i = 1; i <= n; i++) {
            for (j = i + 1; j <= n; j++) {
                if (s_mem[j] > s_mem[i]) {
                    tmp = s_mem[i]; s_mem[i] = s_mem[j]; s_mem[j] = tmp
                    tmp = s_key[i]; s_key[i] = s_key[j]; s_key[j] = tmp
                    tmp = s_count[i]; s_count[i] = s_count[j]; s_count[j] = tmp
                    tmp = s_etime[i]; s_etime[i] = s_etime[j]; s_etime[j] = tmp
                    tmp = s_display[i]; s_display[i] = s_display[j]; s_display[j] = tmp
                    tmp = s_pids[i]; s_pids[i] = s_pids[j]; s_pids[j] = tmp
                }
            }
        }
    }

    if (top_n > 0 && top_n < n) n = top_n

    if (format == "csv") {
        print_csv()
    } else if (format == "tsv") {
        print_tsv()
    } else {
        print_table()
    }
}

# --- Sorting ---

function sort_grouped(    i, j, tmp) {
    n = 0
    for (k in g_mem) {
        n++
        s_mem[n]     = g_mem[k]
        s_key[n]     = k
        s_count[n]   = g_count[k]
        s_etime[n]   = g_etime[k]
        s_display[n] = g_display[k]
        s_pids[n]    = g_pids[k]
    }
    for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
            if (s_mem[j] > s_mem[i]) {
                tmp = s_mem[i]; s_mem[i] = s_mem[j]; s_mem[j] = tmp
                tmp = s_key[i]; s_key[i] = s_key[j]; s_key[j] = tmp
                tmp = s_count[i]; s_count[i] = s_count[j]; s_count[j] = tmp
                tmp = s_etime[i]; s_etime[i] = s_etime[j]; s_etime[j] = tmp
                tmp = s_display[i]; s_display[i] = s_display[j]; s_display[j] = tmp
                tmp = s_pids[i]; s_pids[i] = s_pids[j]; s_pids[j] = tmp
            }
        }
    }
}

function sort_ungrouped(    i, j, tmp) {
    for (i = 1; i <= total; i++) {
        for (j = i + 1; j <= total; j++) {
            if (items_mem[j] > items_mem[i]) {
                tmp = items_mem[i]; items_mem[i] = items_mem[j]; items_mem[j] = tmp
                tmp = items_cmdline[i]; items_cmdline[i] = items_cmdline[j]; items_cmdline[j] = tmp
                tmp = items_etime[i]; items_etime[i] = items_etime[j]; items_etime[j] = tmp
                tmp = items_pid[i]; items_pid[i] = items_pid[j]; items_pid[j] = tmp
            }
        }
    }
}

# --- Output ---

function print_csv(    i) {
    if (header == 1) {
        if (group == "none") print "mem,elapsed,pid,command"
        else                 print "mem,elapsed,pids,command,count"
    }
    for (i = 1; i <= n; i++) {
        if (group == "none") {
            printf "%s,%s,%s,%s\n", items_mem[i], items_etime[i], items_pid[i], csv_escape(items_cmdline[i])
        } else {
            printf "%s,%s,%s,%s,%s\n", s_mem[i], s_etime[i], s_pids[i], csv_escape(s_display[i]), s_count[i]
        }
    }
}

function print_tsv(    i) {
    if (header == 1) {
        if (group == "none") print "mem\telapsed\tpid\tcommand"
        else                 print "mem\telapsed\tpids\tcommand\tcount"
    }
    for (i = 1; i <= n; i++) {
        if (group == "none") {
            printf "%s\t%s\t%s\t%s\n", items_mem[i], items_etime[i], items_pid[i], items_cmdline[i]
        } else {
            printf "%s\t%s\t%s\t%s\t%s\n", s_mem[i], s_etime[i], s_pids[i], s_display[i], s_count[i]
        }
    }
}

function print_table(    i, mem_str, color, mem_padded, etime_padded, pid_str, col_label) {
    col_label = (mem_col == "mem") ? "MEM" : "RSS"
    if (group == "none")
        printf("  " UI_UNDERLINE "Top %d processes by %s (ungrouped)" UI_END "\n", n, col_label)
    else
        printf("  " UI_UNDERLINE "Top %d processes by %s with --group %s" UI_END "\n", n, col_label, group)
    print ""
    if (group == "none") {
        printf("  " UI_DIM "%10s  %11s  %6s  %s" UI_END "\n", col_label, "ELAPSED", "PID", "COMMAND")
    } else {
        printf("  " UI_DIM "%10s  %11s  %5s  %-20s  %s" UI_END "\n", col_label, "ELAPSED", "CNT", "PID", "COMMAND")
    }
    for (i = 1; i <= n; i++) {
        if (group == "none") {
            mem_str = fmt_rss(items_mem[i])
            color = rss_color(items_mem[i])
            mem_padded = sprintf("%10s", mem_str)
            etime_padded = sprintf("%11s", items_etime[i])
            printf("  %s%s" UI_END "  %s  %6d  " UI_DIM "%s" UI_END "\n",
                color, mem_padded, etime_padded, items_pid[i], items_cmdline[i])
        } else {
            mem_str = fmt_rss(s_mem[i])
            color = rss_color(s_mem[i])
            mem_padded = sprintf("%10s", mem_str)
            etime_padded = sprintf("%11s", s_etime[i])
            pid_str = fmt_pids(s_pids[i], s_count[i])
            printf("  %s%s" UI_END "  %s  %5d  %-20s  %s\n",
                color, mem_padded, etime_padded, s_count[i], pid_str, fmt_display(s_display[i]))
        }
    }
    print ""
}

# --- Grouping ---

function get_exe_path(cmdline,    key, n, parts) {
    if (match(cmdline, /\.app\//)) {
        key = cmdline
        sub(/\.app\/.*/, ".app", key)
        return key
    }
    n = split(cmdline, parts, " ")
    return parts[1]
}

function get_group_key(cmdline,    key) {
    if (group == "cmd") return get_exe_path(cmdline)
    if (group == "none") return cmdline
    if (match(cmdline, /^\/(System\/)?Applications\//) && match(cmdline, /\.app\//)) {
        key = cmdline
        sub(/^\/(System\/)?Applications\//, "", key)
        sub(/\.app\/.*/, "", key)
        return key
    }
    return get_exe_path(cmdline)
}

function get_group_display(cmdline,    key, prefix) {
    if (group == "cmd") return get_exe_path(cmdline)
    if (group == "auto" && match(cmdline, /^\/(System\/)?Applications\//) && match(cmdline, /\.app\//)) {
        prefix = "/Applications/"
        if (match(cmdline, /^\/System\//)) prefix = "/System/Applications/"
        key = cmdline
        sub(/^\/(System\/)?Applications\//, "", key)
        sub(/\.app\/.*/, ".app", key)
        return prefix key
    }
    return get_exe_path(cmdline)
}

function fmt_pids(pids_str, cnt,    arr, m, out, shown) {
    m = split(pids_str, arr, "|")
    out = ""
    shown = (m > 2) ? 2 : m
    for (i = 1; i <= shown; i++) {
        if (out != "") out = out "|"
        out = out arr[i]
    }
    if (m > 2) out = out "|..."
    return out
}

function ai_color(    ) {
    return "\033[1;34m"  # bold blue
}

function is_ai_tool(name,    lower) {
    lower = tolower(name)
    if (match(lower, /codex /)) return 1
    if (match(lower, /claude/)) return 1
    if (match(lower, /gemini-cli/)) return 1
    if (match(lower, /openclaw/)) return 1
    if (match(lower, /opencode/)) return 1
    if (match(lower, /cursor/)) return 1
    return 0
}

function fmt_rss(kb,    val, unit) {
    if (kb >= 1073741824) { val = kb / 1048576 / 1024; unit = "Ti" }
    else if (kb >= 1048576) { val = kb / 1048576; unit = "Gi" }
    else if (kb >= 1024) { val = kb / 1024; unit = "Mi" }
    else { val = kb; unit = "Ki" }
    if (unit == "Ki") return sprintf("%.0f %s", val, unit)
    return sprintf("%.1f %s", val, unit)
}

# --- Colors ---

function rss_color(kb,    mb) {
    if (NO_COLOR == 1) return ""
    mb = kb / 1024
    if (mb >= 1024)     return UI_BOLD_RED
    if (mb >= 500)      return "\033[35m"
    if (mb >= 100)      return UI_MED
    return UI_LOW
}

# --- Helpers ---

function fmt_display(s,    n, parts, dir, base, i, c) {
    if (NO_COLOR == 1) return s
    c = is_ai_tool(s) ? ai_color() : ""
    if (match(s, /\.app$/)) {
        n = split(s, parts, "/")
        base = parts[n]
        sub(/\.app$/, "", base)
        if (c == "") c = is_ai_tool(base) ? ai_color() : ""
        dir = ""
        for (i = 1; i < n; i++)
            dir = dir parts[i] "/"
        return UI_DIM dir UI_END c base UI_END UI_DIM ".app" UI_END
    }
    if (c != "") return c s UI_END
    return UI_DIM s UI_END
}

function csv_escape(s) {
    if (index(s, ",") > 0 || index(s, "\"") > 0 || index(s, "\n") > 0) {
        gsub(/"/, "\"\"", s)
        return "\"" s "\""
    }
    return s
}

function etime_to_secs(s,    parts, n, secs, dash_parts) {
    secs = 0
    if (index(s, "-") > 0 && match(s, /^[0-9]+-/)) {
        n = split(s, dash_parts, "-")
        secs = dash_parts[1] * 86400
        s = dash_parts[2]
    }
    n = split(s, parts, ":")
    if (n == 2) {
        secs += parts[1] * 60 + parts[2]
    } else if (n == 3) {
        secs += parts[1] * 3600 + parts[2] * 60 + parts[3]
    } else {
        secs += s + 0
    }
    return secs
}
