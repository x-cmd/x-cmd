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
        } else if (match(lines[i], /^hw\.memsize_usable: /)) {
            # Hardware reserved memory (firmware/GPU/EFI)
            val = substr(lines[i], RLENGTH + 1)
            if (val > 0) usable_kb = val / 1024
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
    available_kb = free_kb + throttled_kb  # true available, excluding speculative
    
    # Hardware reserved memory (if hw.memsize_usable is available)
    hardware_kb = 0
    if (usable_kb > 0 && total_kb > usable_kb) {
        hardware_kb = total_kb - usable_kb
    }

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

    # Calculate derived metrics for CSV/TSV
    reusable_kb = purgeable_kb + cache_kb + available_kb
    mem_used_kb = total_kb - reusable_kb
    
    # Output
    if (format == "csv") {
        if (header == 1) print "used,reusable,wired,compressed,app,purgeable,cache,available,vm-wired,vm-compressed,vm-active,vm-inactive,vm-spec,vm-free,vm-throt,swap-total,swap-used,swap-free,compress-stored,compress-occupied,compress-saved"
        printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
            mem_used_kb, reusable_kb,
            wired_kb, compress_occupied_kb, app_kb, purgeable_kb, cache_kb, available_kb,
            wired_kb, compress_occupied_kb, active_kb, inactive_kb, speculative_kb, free_kb, throttled_kb,
            swap_total_kb, swap_used_kb, swap_free_kb,
            compress_stored_kb, compress_occupied_kb, compress_saved_kb
    } else if (format == "tsv") {
        if (header == 1) print "used\treusable\twired\tcompressed\tapp\tpurgeable\tcache\tavailable\tvm-wired\tvm-compressed\tvm-active\tvm-inactive\tvm-spec\tvm-free\tvm-throt\tswap-total\tswap-used\tswap-free\tcompress-stored\tcompress-occupied\tcompress-saved"
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
            mem_used_kb, reusable_kb,
            wired_kb, compress_occupied_kb, app_kb, purgeable_kb, cache_kb, available_kb,
            wired_kb, compress_occupied_kb, active_kb, inactive_kb, speculative_kb, free_kb, throttled_kb,
            swap_total_kb, swap_used_kb, swap_free_kb,
            compress_stored_kb, compress_occupied_kb, compress_saved_kb
    } else {
        # Table format - Linux free style: Mem and Swap at top
        # Aligned with Detail (6 columns)
        
        # Calculate reusable = purgeable + cache + available (for Mem free column)
        reusable_kb = purgeable_kb + cache_kb + available_kb
        mem_used_kb = total_kb - reusable_kb
        
        # Leading empty line
        print ""
        
        # Header row (aligned with Detail: 6 columns) - no bold
        printf("  " UI_HDR_OFF "%-8s %10s %10s %10s %10s %10s %10s" UI_END "\n",
            "", "total", "used", "reusable", "", "", "")
        
        # Mem row
        if (NO_COLOR == 1) {
            printf("  %-8s %10s %10s %10s (=purgeable + cache + available)\n",
                "Mem:",
                fmt_human_val(total_kb),
                fmt_human_val(mem_used_kb),
                fmt_human_val(reusable_kb))
        } else {
            # Color Mem: label (cyan), total (bold), used (bold red), reusable (bold green)
            printf("  %s%-8s%s %s%10s%s %s%10s%s %s%10s%s" UI_DIM " (=purgeable + cache + available)" UI_END "\n",
                UI_KEY, "Mem:", UI_END,
                UI_HDR, fmt_human_val(total_kb), UI_END,
                UI_BOLD_RED, fmt_human_val(mem_used_kb), UI_END,
                UI_BOLD_GREEN, fmt_human_val(reusable_kb), UI_END)
        }
        
        # Swap row (same alignment)
        swap_str = sprintf("%-8s %10s %10s %10s %10s %10s %10s",
            "Swap:",
            fmt_human_val(swap_total_kb),
            fmt_human_val(swap_used_kb),
            fmt_human_val(swap_free_kb),
            "", "", "")
        gsub(/Swap:/, UI_KEY "Swap:" UI_END, swap_str)
        print "  " swap_str
        
        # Separator line
        print ""
        
        # Identity: app + purgeable + cache = active + inactive + spec
        # Logic Layer (primary view) - 7 columns (including hardware)
        print ""
        if (NO_COLOR == 1) {
            printf("  %-8s %10s %10s %10s %10s %10s %10s %10s\n",
                "", "hardware", "wired", "compressed", "app", "purgeable", "cache", "available")
            printf("  %-8s %10s %10s %10s %10s %10s %10s %10s (=free + throt)\n",
                "Detail:",
                fmt_human_val(hardware_kb),
                fmt_human_val(kernel_kb),
                fmt_human_val(compressed_kb),
                fmt_human_val(app_kb),
                fmt_human_val(purgeable_kb),
                fmt_human_val(cache_kb),
                fmt_human_val(available_kb))
        } else {
            printf("  %s%-8s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s\n",
                UI_DIM, "", UI_END,
                UI_DIM, "hardware", UI_END,
                UI_DIM, "wired", UI_END,
                UI_DIM, "compressed", UI_END,
                UI_DIM UI_UNDERLINE, "app", UI_UNDERLINE_OFF UI_END,
                UI_DIM UI_UNDERLINE, "purgeable", UI_UNDERLINE_OFF UI_END,
                UI_DIM UI_UNDERLINE, "cache", UI_UNDERLINE_OFF UI_END,
                UI_DIM, "available", UI_END)
            printf("  %s%-8s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s" UI_DIM " (=free + throt)" UI_END "\n",
                UI_KEY, "Detail:", UI_END,
                UI_RED_DIM, fmt_human_val(hardware_kb), UI_END,
                UI_RED, fmt_human_val(kernel_kb), UI_END,
                UI_RED, fmt_human_val(compressed_kb), UI_END,
                UI_RED, fmt_human_val(app_kb), UI_END,
                UI_GREEN, fmt_human_val(purgeable_kb), UI_END,
                UI_GREEN, fmt_human_val(cache_kb), UI_END,
                UI_GREEN, fmt_human_val(available_kb), UI_END)
        }
        
        # Physical Layer (reference - vm_stat raw counters) - 8 columns
        # spec aligns with cache (column 6), free with available (column 7)
        print ""
        if (NO_COLOR == 1) {
            printf("  %-8s %10s %10s %10s %10s %10s %10s %10s %10s\n",
                "", "hardware", "wired", "compressed", "active", "inactive", "spec", "free", "throt")
            printf("  %-8s %10s %10s %10s %10s %10s %10s %10s %10s\n",
                "vm_stat",
                fmt_human_val(hardware_kb),
                fmt_human_val(wired_kb),
                fmt_human_val(compress_occupied_kb),
                fmt_human_val(active_kb),
                fmt_human_val(inactive_kb),
                fmt_human_val(speculative_kb),
                fmt_human_val(free_kb),
                fmt_human_val(throttled_kb))
        } else {
            printf("  %s%-8s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s\n",
                UI_DIM, "", UI_END,
                UI_DIM, "hardware", UI_END,
                UI_DIM, "wired", UI_END,
                UI_DIM, "compressed", UI_END,
                UI_DIM UI_UNDERLINE, "active", UI_UNDERLINE_OFF UI_END,
                UI_DIM UI_UNDERLINE, "inactive", UI_UNDERLINE_OFF UI_END,
                UI_DIM UI_UNDERLINE, "spec", UI_UNDERLINE_OFF UI_END,
                UI_DIM, "free", UI_END,
                UI_DIM, "throt", UI_END)
            printf("  %s%-8s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s %s%10s%s\n",
                UI_DIM, "vm_stat", UI_END,
                UI_DIM, fmt_human_val(hardware_kb), UI_END,
                UI_DIM, fmt_human_val(wired_kb), UI_END,
                UI_DIM, fmt_human_val(compress_occupied_kb), UI_END,
                UI_DIM, fmt_human_val(active_kb), UI_END,
                UI_DIM, fmt_human_val(inactive_kb), UI_END,
                UI_DIM, fmt_human_val(speculative_kb), UI_END,
                UI_GREEN, fmt_human_val(free_kb), UI_END,
                UI_GREEN, fmt_human_val(throttled_kb), UI_END)
        }

        # Compress info (dimmed) - aligned with 7 columns
        if (NO_COLOR == 1) {
            printf("  %-8s %10s %10s %10s %10s %10s %10s %10s\n",
                "", "", "", "compressed", "original", "ratio", "saved", "")
            compress_str = sprintf("%-8s %10s %10s %10s %10s %10s %10s %10s",
                "",
                "",
                "",
                fmt_human_val(compress_occupied_kb),
                fmt_human_val(compress_stored_kb),
                "0%",
                fmt_human_val(compress_saved_kb),
                "")
            print "  " compress_str
        } else {
            ratio_str = "0%"
            if (compress_stored_kb > 0) {
                ratio = (compress_occupied_kb / compress_stored_kb) * 100
                ratio_str = sprintf("%.0f%%", ratio)
            }
            printf("  " UI_DIM "%-8s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
                "", "", "", "compressed", "original", "ratio", "saved", "")
            printf("  " UI_DIM "%-8s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
                "",
                "",
                "",
                fmt_human_val(compress_occupied_kb),
                fmt_human_val(compress_stored_kb),
                ratio_str,
                fmt_human_val(compress_saved_kb),
                "")
        }
        # Add empty line for separation in repeat mode (-c)
        print ""
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
