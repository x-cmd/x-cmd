# shellcheck shell=awk
# Linux memory info parser - reads from /proc/meminfo

/^MemTotal:/     { total = $2 }
/^MemFree:/      { free = $2 }
/^MemAvailable:/ { available = $2 }
/^Buffers:/      { buffers = $2 }
/^Cached:/       { cached = $2 }
/^SwapTotal:/    { swap_total = $2 }
/^SwapFree:/     { swap_free = $2 }

END {
    used = total - free
    buff_cache = buffers + cached
    swap_used = swap_total - swap_free

    # Initialize colors for TTY output
    init_colors(NO_COLOR)

    # Output based on format
    if (format == "csv") {
        if (header == 1) print_flat_header_csv()
        print_flat_row_csv(total, used, free, 0, buff_cache, available,
                          swap_total, swap_used, swap_free, 0, 0, 0)
    } else if (format == "tsv") {
        if (header == 1) print_flat_header_tsv()
        print_flat_row_tsv(total, used, free, 0, buff_cache, available,
                          swap_total, swap_used, swap_free, 0, 0, 0)
    } else {
        # Default table format
        print_header()
        print_mem_row("Mem:", total, used, free, "0", buff_cache, available, human)
        print_swap_row("Swap:", swap_total, swap_used, swap_free, human)
    }
}
