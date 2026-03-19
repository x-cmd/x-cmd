# shellcheck shell=awk
# macOS memory info parser - reads from vm_stat output and sysctl data via env
#
# Memory Conservation Law:
# wired + active + inactive + speculative + throttled + free + occupied = total

BEGIN {
    page_kb = 4096 / 1024
    total_kb = 0
    swap_line = ""

    sysctl_data = ENVIRON["___X_CMD_FREE_SYSCTL_DATA"]
    n = split(sysctl_data, lines, "\n")
    for (i = 1; i <= n; i++) {
        if (match(lines[i], /^hw\.pagesize: /)) {
            val = substr(lines[i], RLENGTH + 1)
            if (val > 0) page_kb = val / 1024
        } else if (match(lines[i], /^hw\.memsize: /)) {
            val = substr(lines[i], RLENGTH + 1)
            if (val > 0) total_kb = val / 1024
        } else if (match(lines[i], /^vm\.swapusage: /)) {
            swap_line = substr(lines[i], RLENGTH + 1)
        }
    }
}

/^Mach Virtual Memory Statistics/ {
    if (match($0, /page size of [0-9]+/)) {
        val = substr($0, RSTART + 12, RLENGTH - 12)
        if (val > 0) page_kb = val / 1024
    }
}

/Pages free/                    { pages_free = $3 }
/Pages active/                  { pages_active = $3 }
/Pages inactive/                { pages_inactive = $3 }
/Pages wired down/              { pages_wired = $4 }
/Pages purgeable/               { pages_purgeable = $3 }
/Pages speculative/             { pages_speculative = $3 }
/Pages throttled/               { pages_throttled = $3 }
/File-backed pages/             { pages_filebacked = $3 }
/Anonymous pages/               { pages_anonymous = $3 }
/Pages stored in compressor/    { compress_stored = $5 }
/Pages occupied by compressor/  { compress_occupied = $5 }

END {
    # Convert to KB
    free_kb = pages_free * page_kb
    active_kb = pages_active * page_kb
    inactive_kb = pages_inactive * page_kb
    wired_kb = pages_wired * page_kb
    speculative_kb = pages_speculative * page_kb
    throttled_kb = pages_throttled * page_kb
    purgeable_kb = pages_purgeable * page_kb
    filebacked_kb = pages_filebacked * page_kb
    anonymous_kb = pages_anonymous * page_kb
    compress_stored_kb = compress_stored * page_kb
    compress_occupied_kb = compress_occupied * page_kb

    # Logic layer calculations
    kernel_kb = wired_kb
    compressed_kb = compress_occupied_kb
    app_kb = anonymous_kb - purgeable_kb
    cache_kb = filebacked_kb
    available_kb = speculative_kb + throttled_kb + free_kb

    # Parse swap info from sysctl output
    swap_total_kb = 0
    swap_used_kb = 0
    if (swap_line != "") {
        swap_total_kb = parse_swap(swap_line, "total")
        swap_used_kb = parse_swap(swap_line, "used")
    }
    swap_free_kb = swap_total_kb - swap_used_kb

    # Compressor savings
    compress_saved_kb = compress_stored_kb - compress_occupied_kb

    # Colors
    init_colors(NO_COLOR)

    # Output
    if (format == "csv") {
        if (header == 1) print "total,wired,occupied,active,inactive,speculative,throttled,free,kernel,compressed,app,purgeable,cache,available,swap_total,swap_used,compress_stored,compress_occupied,compress_saved"
        printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
            total_kb, wired_kb, compress_occupied_kb, active_kb, inactive_kb, speculative_kb, throttled_kb, free_kb,
            kernel_kb, compressed_kb, app_kb, purgeable_kb, cache_kb, available_kb,
            swap_total_kb, swap_used_kb, compress_stored_kb, compress_occupied_kb, compress_saved_kb
    } else if (format == "tsv") {
        if (header == 1) print "total\twired\toccupied\tactive\tinactive\tspeculative\tthrottled\tfree\tkernel\tcompressed\tapp\tpurgeable\tcache\tavailable\tswap_total\tswap_used\tcompress_stored\tcompress_occupied\tcompress_saved"
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
            total_kb, wired_kb, compress_occupied_kb, active_kb, inactive_kb, speculative_kb, throttled_kb, free_kb,
            kernel_kb, compressed_kb, app_kb, purgeable_kb, cache_kb, available_kb,
            swap_total_kb, swap_used_kb, compress_stored_kb, compress_occupied_kb, compress_saved_kb
    } else {
        # Table format - use fixed-width format for proper alignment
        
        # Phys row header
        printf(UI_HDR "%-8s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
            "", "wired", "occupied", "active", "inactive", "", "spec", "throt", "free")
        
        # Phys row data - build string with colors embedded
        phys_str = sprintf("%-8s %10s %10s %10s %10s %10s %10s %10s %10s",
            "Phys:",
            fmt_human_val(wired_kb),
            fmt_human_val(compress_occupied_kb),
            fmt_human_val(active_kb),
            fmt_human_val(inactive_kb),
            "-",
            fmt_human_val(speculative_kb),
            fmt_human_val(throttled_kb),
            fmt_human_val(free_kb))
        # Apply colors after sprintf to avoid width issues
        gsub(/Phys:/, UI_KEY "Phys:" UI_END, phys_str)
        print phys_str

        # Logic row header
        printf(UI_HDR "%-8s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
            "", "kernel", "compressed", "app", "purgeable", "cache", "", "", "available")
        
        # Logic row data
        logic_str = sprintf("%-8s %10s %10s %10s %10s %10s %10s %10s %10s",
            "Logic:",
            fmt_human_val(kernel_kb),
            fmt_human_val(compressed_kb),
            fmt_human_val(app_kb),
            fmt_human_val(purgeable_kb),
            fmt_human_val(cache_kb),
            "",
            "",
            fmt_human_val(available_kb))
        gsub(/Logic:/, UI_KEY "Logic:" UI_END, logic_str)
        print logic_str

        # Compress (before Swap) - compressed aligns with Logic.compressed (column 2)
        # Use dim color for secondary info
        printf(UI_DIM "%-8s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
            "", "", "compressed", "original", "ratio", "saved", "", "", "")
        
        # Calculate ratio
        ratio_str = "0%"
        if (compress_stored_kb > 0) {
            ratio = (compress_occupied_kb / compress_stored_kb) * 100
            ratio_str = sprintf("%.0f%%", ratio)
        }
        
        compress_str = sprintf("%-8s %10s %10s %10s %10s %10s %10s %10s %10s",
            "",
            "",
            fmt_human_val(compress_occupied_kb),
            fmt_human_val(compress_stored_kb),
            ratio_str,
            fmt_human_val(compress_saved_kb),
            "", "", "")
        # Apply dim color
        if (NO_COLOR != 1) {
            compress_str = UI_DIM compress_str UI_END
        }
        print compress_str

        # Swap
        printf(UI_HDR "%-8s %10s %10s %10s" UI_END "\n",
            "", "total", "used", "free")
        print_swap_row("Swap:", swap_total_kb, swap_used_kb, swap_free_kb, human)
    }
}

function parse_swap(line, key,   i, n, arr, val, matched, num_len, j, c, num, unit) {
    n = split(line, arr, " ")
    for (i = 1; i <= n; i++) {
        if (arr[i] == key && arr[i+1] == "=") {
            val = arr[i+2]
            if (match(val, /^[0-9.]+[KMGT]/)) {
                matched = substr(val, RSTART, RLENGTH)
                num_len = 0
                for (j = 1; j <= length(matched); j++) {
                    c = substr(matched, j, 1)
                    if ((c >= "0" && c <= "9") || c == ".") {
                        num_len++
                    } else {
                        break
                    }
                }
                num = substr(matched, 1, num_len)
                unit = substr(matched, num_len + 1, 1)
                if (unit == "K") return int(num)
                else if (unit == "M") return int(num * 1024)
                else if (unit == "G") return int(num * 1024 * 1024)
                else if (unit == "T") return int(num * 1024 * 1024 * 1024)
            }
        }
    }
    return 0
}
