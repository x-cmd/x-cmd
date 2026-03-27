# shellcheck shell=awk
# Shared functions for free module - output formatting

# Color codes for TTY output
function init_colors(NO_COLOR) {
    if (NO_COLOR != 1) {
        UI_HDR  = "\033[1;37m"    # Bold white - headers
        UI_HDR_OFF = "\033[22;37m" # Normal intensity white - non-bold headers
        UI_KEY  = "\033[36m"      # Cyan - labels (Mem:, Swap:)
        UI_LOW  = "\033[32m"      # Green - low usage (<50%)
        UI_MED  = "\033[33m"      # Yellow - medium usage (50-80%)
        UI_HIGH = "\033[31m"      # Red - high usage (>80%)
        UI_DIM  = "\033[22;90m"   # Gray normal intensity - dim/secondary info
        UI_END  = "\033[0m"       # Reset
        # New styles
        UI_ITALIC = "\033[3m"     # Italic - sum relationship
        UI_GREEN = "\033[32m"     # Green - reclaimable memory
        UI_GREEN_DIM = "\033[2;32m"  # Dim green - cache (less reclaimable)
        UI_UNDERLINE = "\033[4m"   # Underline - related columns
        UI_UNDERLINE_OFF = "\033[24m"  # Cancel underline
        UI_RED = "\033[31m"       # Red - used/non-reclaimable memory
        UI_RED_DIM = "\033[2;31m"   # Dim red - hardware reserved (not OS managed)
        UI_BOLD_RED = "\033[1;31m"  # Bold red - used (emphasized)
        UI_BOLD_GREEN = "\033[1;32m" # Bold green - free (emphasized)
        UI_REVERSE = "\033[7m"      # Reverse video - highlight columns
        UI_REVERSE_OFF = "\033[27m" # Cancel reverse
    }
}

# Get color based on usage percentage
function usage_color(used, total,    pct) {
    if (total <= 0) return UI_LOW
    pct = (used / total) * 100
    if (pct > 80) return UI_HIGH
    if (pct > 50) return UI_MED
    return UI_LOW
}

# Format human readable value (returns plain value, color applied separately)
function fmt_human_val(kb,    val, unit) {
    if (kb >= 1073741824) { val = kb / 1048576 / 1024; unit = "Ti" }
    else if (kb >= 1048576) { val = kb / 1048576; unit = "Gi" }
    else if (kb >= 1024) { val = kb / 1024; unit = "Mi" }
    else { val = kb; unit = "Ki" }
    if (unit == "Ki") return sprintf("%.0f %s", val, unit)
    return sprintf("%.1f %s", val, unit)
}

function human_readable(kb) {
    if (kb >= 1073741824) return sprintf("%.1fTi", kb / 1048576 / 1024)
    else if (kb >= 1048576) return sprintf("%.1fGi", kb / 1048576)
    else if (kb >= 1024) return sprintf("%.1fMi", kb / 1024)
    else return sprintf("%.0fKi", kb)
}

# Standard table format functions (Linux style)
function print_header() {
    printf(UI_HDR "%-10s %10s %10s %10s %10s %10s %10s" UI_END "\n", "", "total", "used", "free", "shared", "buff/cache", "available")
}

function print_mem_row(label, total, used, free, shared, buff, avail,   human_readable_mode) {
    if (human_readable_mode) {
        printf(UI_KEY "%-10s" UI_END " " UI_HDR "%10s" UI_END " " usage_color(used, total) "%10s" UI_END " " usage_color(free, total) "%10s" UI_END " %10s " UI_LOW "%10s" UI_END " " UI_LOW "%10s" UI_END "\n",
            label,
            fmt_human_val(total),
            fmt_human_val(used),
            fmt_human_val(free),
            shared,
            fmt_human_val(buff),
            fmt_human_val(avail))
    } else {
        printf(UI_KEY "%-10s" UI_END " " UI_HDR "%10s" UI_END " " usage_color(used, total) "%10s" UI_END " " usage_color(free, total) "%10s" UI_END " %10s " UI_LOW "%10s" UI_END " " UI_LOW "%10s" UI_END "\n",
            label,
            total,
            used,
            free,
            shared,
            buff,
            avail)
    }
}

function print_swap_row(label, total, used, free,   human_readable_mode) {
    if (human_readable_mode) {
        printf(UI_KEY "%-8s" UI_END " " UI_HDR "%10s" UI_END " " usage_color(used, total) "%10s" UI_END " " usage_color(free, total) "%10s" UI_END " %10s %10s %10s %10s %10s\n",
            label,
            fmt_human_val(total),
            fmt_human_val(used),
            fmt_human_val(free),
            "", "", "", "", "")
    } else {
        printf(UI_KEY "%-8s" UI_END " " UI_HDR "%10s" UI_END " " usage_color(used, total) "%10s" UI_END " " usage_color(free, total) "%10s" UI_END " %10s %10s %10s %10s %10s\n",
            label,
            total,
            used,
            free,
            "", "", "", "", "")
    }
}

function print_compress_header() {
    printf "%-10s %10s %10s %10s\n", "", "stored", "occupied", "saved"
}

function print_compress_row(label, stored, occupied, saved,   human_readable_mode) {
    if (human_readable_mode) {
        printf "%-10s %10s %10s %10s  ← Compress\n", label, human_readable(stored), human_readable(occupied), human_readable(saved)
    } else {
        printf "%-10s %10s %10s %10s  ← Compress\n", label, stored, occupied, saved
    }
}

# Flat format (csv/tsv) - single line output for streaming
function print_flat_header_csv() {
    printf "mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_avail,swap_total,swap_used,swap_free,compress_stored,compress_occupied,compress_saved\n"
}

function print_flat_row_csv(mem_total, mem_used, mem_free, mem_shared, mem_buff, mem_avail, swap_total, swap_used, swap_free, compress_stored, compress_occupied, compress_saved) {
    printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", mem_total, mem_used, mem_free, mem_shared, mem_buff, mem_avail, swap_total, swap_used, swap_free, compress_stored, compress_occupied, compress_saved
}

function print_flat_header_tsv() {
    printf "mem_total\tmem_used\tmem_free\tmem_shared\tmem_buff\tmem_avail\tswap_total\tswap_used\tswap_free\tcompress_stored\tcompress_occupied\tcompress_saved\n"
}

function print_flat_row_tsv(mem_total, mem_used, mem_free, mem_shared, mem_buff, mem_avail, swap_total, swap_used, swap_free, compress_stored, compress_occupied, compress_saved) {
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", mem_total, mem_used, mem_free, mem_shared, mem_buff, mem_avail, swap_total, swap_used, swap_free, compress_stored, compress_occupied, compress_saved
}
