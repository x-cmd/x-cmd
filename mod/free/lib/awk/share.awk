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
        UI_MAGENTA = "\033[1;35m"   # Bold magenta - pressure indicator
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
    if (kb == 0) return "0"
    if (kb >= 1073741824) { val = kb / 1048576 / 1024; unit = "Ti" }
    else if (kb >= 1048576) { val = kb / 1048576; unit = "Gi" }
    else if (kb >= 1024) { val = kb / 1024; unit = "Mi" }
    else { val = kb; unit = "K" }
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
    printf(UI_HDR "%-6s %9s %9s %9s" UI_DIM "%10s" UI_END UI_HDR "%12s" UI_DIM "%11s" UI_END "\n", "", "total", "used", "free", "shared", "buff/cache", "available")
}

function print_mem_row(label, total, used, free, shared, buff, avail,   human_readable_mode) {
    if (human_readable_mode) {
        printf(UI_KEY "%-6s" UI_END " " UI_HDR "%9s" UI_END " " UI_BOLD_RED "%9s" UI_END " " UI_BOLD_GREEN "%9s" UI_END " " UI_DIM "%9s" UI_END " " UI_MED "%11s" UI_END " " UI_DIM "%10s" UI_END "\n",
            label,
            fmt_human_val(total),
            fmt_human_val(used),
            fmt_human_val(free),
            fmt_human_val(shared),
            fmt_human_val(buff),
            fmt_human_val(avail))
    } else {
        printf(UI_KEY "%-6s" UI_END " " UI_HDR "%9s" UI_END " " UI_BOLD_RED "%9s" UI_END " " UI_BOLD_GREEN "%9s" UI_END " " UI_DIM "%9s" UI_END " " UI_MED "%11s" UI_END " " UI_DIM "%10s" UI_END "\n",
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
        printf(UI_KEY "%-6s" UI_END " " UI_HDR "%9s" UI_END " " UI_BOLD_RED "%9s" UI_END " " UI_BOLD_GREEN "%9s" UI_END " " UI_DIM "%9s %12s %14s" UI_END "\n",
            label,
            fmt_human_val(total),
            fmt_human_val(used),
            fmt_human_val(free),
            "", "", "(≈ free + reclaimable)")
    } else {
        printf(UI_KEY "%-6s" UI_END " " UI_HDR "%9s" UI_END " " UI_BOLD_RED "%9s" UI_END " " UI_BOLD_GREEN "%9s" UI_END " " UI_DIM "%9s %12s %14s" UI_END "\n",
            label,
            total,
            used,
            free,
            "", "", "(≈ free + reclaimable)")
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

# ===== Detail layer output functions =====

function fv(val, human_mode) {
    # Format value for detail rows
    if (human_mode) return fmt_human_val(val)
    return val
}

function print_swapcached(val, human_mode) {
    printf(UI_DIM "%21s %s" UI_END "\n", "",
        val == 0 ? "0" : fv(val, human_mode) " (swapcached)")
}

function print_used_row(used_anon, used_slab_un, used_mlocked, used_other, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s" UI_END "\n",
        "", "anon", "slab_un", "mlocked", "other")
    # data row
    printf(UI_KEY "  %-7s" UI_END " " \
        UI_BOLD_RED "%10s" UI_END " " \
        UI_RED "%10s" UI_END " " \
        UI_RED_DIM "%10s" UI_END " " \
        UI_RED_DIM "%10s" UI_END "\n",
        "used:",
        fv(used_anon, human_mode),
        fv(used_slab_un, human_mode),
        fv(used_mlocked, human_mode),
        fv(used_other, human_mode))
}

function print_cache_row(buffers, slab_recl, mapped, unmapped, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s" UI_END "\n",
        "", "buffers", "slab_recl", "mapped", "unmapped")
    # data row: buffers=GREEN+U, slab_recl=GREEN_DIM, mapped=YEL+U, unmapped=GREEN+U
    printf(UI_KEY "  %-7s" UI_END " " \
        UI_GREEN UI_UNDERLINE "%10s" UI_UNDERLINE_OFF UI_END " " \
        UI_GREEN_DIM "%10s" UI_END " " \
        UI_MED UI_UNDERLINE "%10s" UI_UNDERLINE_OFF UI_END " " \
        UI_GREEN UI_UNDERLINE "%10s" UI_UNDERLINE_OFF UI_END "\n",
        "cache:",
        fv(buffers, human_mode),
        fv(slab_recl, human_mode),
        fv(mapped, human_mode),
        fv(unmapped, human_mode))
}

function print_kernel_row(slab_total, pagetable, kstack, vmalloc, percpu, kern_other, human_mode) {
    printf "\n"
    # header row: 1 label col + 6 value cols = "  %-7s %10s %10s %10s %10s %10s %10s"
    printf(UI_DIM "  %-7s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "slab_total", "pagetable", "kstack", "vmalloc", "percpu", "kern_other")
    # data row: same structure
    printf(UI_KEY "  %-7s" UI_END " " UI_DIM "%10s %10s %10s %10s %10s %10s" UI_END "\n",
        "kernel:",
        fv(slab_total, human_mode),
        fv(pagetable, human_mode),
        fv(kstack, human_mode),
        fv(vmalloc, human_mode),
        fv(percpu, human_mode),
        fv(kern_other, human_mode))
}

function print_lru_row(act_anon, inact_anon, act_file, inact_file, lru_total, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s" UI_END "\n",
        "", "act_anon", "inact_anon", "act_file", "inact_file")
    # data row: act_anon=BOLD_RED, inact_anon=RED, act_file=YEL+U, inact_file=BOLD_GREEN+U
    printf(UI_KEY "  %-7s" UI_END " " \
        UI_BOLD_RED "%10s" UI_END " " \
        UI_RED "%10s" UI_END " " \
        UI_MED UI_UNDERLINE "%10s" UI_UNDERLINE_OFF UI_END " " \
        UI_BOLD_GREEN UI_UNDERLINE "%10s" UI_UNDERLINE_OFF UI_END "\n",
        "lru:",
        fv(act_anon, human_mode),
        fv(inact_anon, human_mode),
        fv(act_file, human_mode),
        fv(inact_file, human_mode))
}

function print_thp_row(thp_anon, shmem_huge, shmem_pmd, file_huge, file_pmd,
                       hp_total, hp_free, hp_rsvd, hp_surp, hugetlb, hp_size, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "thp_anon", "shmem_huge", "shmem_pmd", "file_huge", "file_pmd",
        "hp_total", "hp_free", "hp_rsvd", "hp_surp", "hugetlb", "hp_size")
    # data row - all DIM
    printf(UI_KEY "  %-7s" UI_END " " UI_DIM "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "thp:",
        fv(thp_anon, human_mode),
        fv(shmem_huge, human_mode),
        fv(shmem_pmd, human_mode),
        fv(file_huge, human_mode),
        fv(file_pmd, human_mode),
        hp_total + 0,
        hp_free + 0,
        hp_rsvd + 0,
        hp_surp + 0,
        fv(hugetlb, human_mode),
        fv(hp_size, human_mode))
}

function print_io_row(dirty, writeback, wb_tmp, nfs_unstable, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s" UI_END "\n",
        "", "dirty", "writeback", "wb_tmp", "nfs_unstable")
    # data row - all DIM
    printf(UI_KEY "  %-7s" UI_END " " UI_DIM "%10s %10s %10s %10s" UI_END "\n",
        "io:",
        fv(dirty, human_mode),
        fv(writeback, human_mode),
        fv(wb_tmp, human_mode),
        fv(nfs_unstable, human_mode))
}

function print_vm_row(committed, commit_lim, kreclaim, zswap, zswapped,
                     vmalloc_total, vmalloc_chunk, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "committed", "commit_lim", "kreclaim", "zswap", "zswapped", "vmalloc_T", "vmalloc_C")
    # data row - all DIM
    printf(UI_KEY "  %-7s" UI_END " " UI_DIM "%10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "vm:",
        fv(committed, human_mode),
        fv(commit_lim, human_mode),
        fv(kreclaim, human_mode),
        fv(zswap, human_mode),
        fv(zswapped, human_mode),
        fv(vmalloc_total, human_mode),
        fv(vmalloc_chunk, human_mode))
}

function print_hw_row(bounce, sec_pagetbl, hw_corrupted, cma_total, cma_free,
                      dmap_4k, dmap_2m, dmap_1g, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-7s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "bounce", "sec_pagtbl", "hw_corrupt", "cma_total", "cma_free", "dmap_4k", "dmap_2M", "dmap_1G")
    # data row - all DIM
    printf(UI_KEY "  %-7s" UI_END " " UI_DIM "%10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "hw:",
        fv(bounce, human_mode),
        fv(sec_pagetbl, human_mode),
        fv(hw_corrupted, human_mode),
        fv(cma_total, human_mode),
        fv(cma_free, human_mode),
        fv(dmap_4k, human_mode),
        fv(dmap_2m, human_mode),
        fv(dmap_1g, human_mode))
}

# ===== macOS Expert layer output functions =====

function print_darwin_compress_detail_row(input_kb, output_kb, pool_kb, decompress_kb, human_mode) {
    printf "\n"
    # header row - 9 cols: comp_out at col 4 (aligned "compressed"), comp_in at col 5 (aligned "original")
    # empty col 6, decompress at col 7, pool_limit at col 8
    printf(UI_DIM "  %-8s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "", "", "acc-out", "acc-in", "acc-ratio", "", "decompress", "pool-limit")
    # data row
    ratio_str = "0%"
    if (input_kb > 0) {
        ratio = (output_kb / input_kb) * 100
        ratio_str = sprintf("%.0f%%", ratio)
    }
    printf(UI_KEY "  %-8s" UI_END " " UI_DIM "%10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "comp:",
        "", "",
        fv(output_kb, human_mode),
        fv(input_kb, human_mode),
        ratio_str,
        "",
        fv(decompress_kb, human_mode),
        fv(pool_kb, human_mode))
}

function print_darwin_io_row(pageins, pageouts, swapins, swapouts, human_mode) {
    printf "\n"
    # header row - all cumulative
    printf(UI_DIM "  %-8s %10s %10s %10s %10s" UI_END "\n",
        "", "page-in", "page-out", "swap-in", "swap-out")
    # data row - all DIM
    printf(UI_KEY "  %-8s" UI_END " " UI_DIM "%10s %10s %10s %10s" UI_END "\n",
        "disk:",
        fv(pageins, human_mode),
        fv(pageouts, human_mode),
        fv(swapins, human_mode),
        fv(swapouts, human_mode))
}

function print_darwin_pageq_row(pageable_int, reusable, cleaned, cache_min, free_target, free_wanted, human_mode) {
    printf "\n"
    # 9 cols: pageable_I/reusable/cleaned at cols 2-4, empty cols 5-6,
    # cache_min at col 7 (aligned with Detail "cache"),
    # free_target at col 8 (aligned with "available"), free_wanted at col 9
    printf(UI_DIM "  %-8s %10s %10s %10s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "pageable-I", "reusable", "cleaned", "", "", "cache-min", "fre-target", "fre-want")
    printf(UI_KEY "  %-8s" UI_END " " UI_DIM "%10s %10s %10s %10s %10s" UI_END " " \
        UI_GREEN "%10s %10s" UI_END " " UI_MAGENTA "%10s" UI_END "\n",
        "pageq:",
        fv(pageable_int, human_mode),
        fv(reusable, human_mode),
        fv(cleaned, human_mode),
        "", "",
        fv(cache_min, human_mode),
        fv(free_target, human_mode),
        free_wanted + 0)
}

function print_darwin_misc_row(shared_reg, realtime, reactivated, purged, human_mode) {
    printf "\n"
    # 6 cols: shared_reg(2), realtime(3), empty(4), reactivated(5 aligns with "active"), purged(6 aligns with "purgeable")
    printf(UI_DIM "  %-8s %10s %10s %10s %10s %10s" UI_END "\n",
        "", "shared-reg", "realtime", "", "reactiv", "purged")
    # data row - reactivated=dim red, purged=dim green
    printf(UI_KEY "  %-8s" UI_END " " UI_DIM "%10s %10s %10s" UI_END " " \
        UI_RED_DIM "%10s" UI_END " " UI_GREEN_DIM "%10s" UI_END "\n",
        "misc:",
        fv(shared_reg, human_mode),
        fv(realtime, human_mode),
        "",
        fv(reactivated, human_mode),
        fv(purged, human_mode))
}

function print_darwin_faults_row(tfaults, cow, zero_filled, human_mode) {
    printf "\n"
    # header row
    printf(UI_DIM "  %-8s %10s %10s %10s" UI_END "\n",
        "", "tfault", "cow", "zero-fill")
    # data row - all DIM, show as page counts (not memory amounts)
    if (human_mode) {
        printf(UI_KEY "  %-8s" UI_END " " UI_DIM "%10s %10s %10s" UI_END "\n",
            "faults:",
            fmt_count(tfaults),
            fmt_count(cow),
            fmt_count(zero_filled))
    } else {
        printf(UI_KEY "  %-8s" UI_END " " UI_DIM "%10s %10s %10s" UI_END "\n",
            "faults:",
            tfaults + 0,
            cow + 0,
            zero_filled + 0)
    }
}

function fmt_count(n,    val, unit) {
    if (n >= 1073741824) { val = n / 1073741824; unit = "G" }
    else if (n >= 1048576) { val = n / 1048576; unit = "M" }
    else if (n >= 1024) { val = n / 1024; unit = "K" }
    else { val = n; unit = "" }
    if (unit == "") return sprintf("%.0f", val)
    return sprintf("%.1f %s", val, unit)
}
