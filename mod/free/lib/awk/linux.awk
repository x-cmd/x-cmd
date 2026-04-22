# shellcheck shell=awk
# Linux memory info parser - reads from /proc/meminfo

# ===== Summary =====
/^MemTotal:/     { total = $2 }
/^MemFree:/      { free = $2 }
/^MemAvailable:/ { available = $2 }
/^Buffers:/      { buffers = $2 }
/^Cached:/       { cached = $2 }
/^Shmem:/        { shared = $2 }
/^SwapTotal:/    { swap_total = $2 }
/^SwapFree:/     { swap_free = $2 }

# ===== Swap detail =====
/^SwapCached:/   { swap_cached = $2 }

# ===== Used row =====
/^AnonPages:/    { anon = $2 }
/^SUnreclaim:/   { slab_un = $2 }
/^Unevictable:/  { unevict = $2 }

# ===== Cache row =====
/^SReclaimable:/ { slab_recl = $2 }
/^Mapped:/       { mapped = $2 }

# ===== Kernel row =====
/^Slab:/         { slab_total = $2 }
/^PageTables:/   { pagetable = $2 }
/^KernelStack:/  { kstack = $2 }
/^VmallocUsed:/  { vmalloc = $2 }
/^Percpu:/       { percpu = $2 }

# ===== LRU row =====
/^Active\(anon\):/    { act_anon = $2 }
/^Inactive\(anon\):/  { inact_anon = $2 }
/^Active\(file\):/    { act_file = $2 }
/^Inactive\(file\):/  { inact_file = $2 }

# ===== THP row =====
/^AnonHugePages:/     { thp_anon = $2 }
/^ShmemHugePages:/    { shmem_huge = $2 }
/^ShmemPmdMapped:/    { shmem_pmd = $2 }
/^FileHugePages:/     { file_huge = $2 }
/^FilePmdMapped:/     { file_pmd = $2 }
/^HugePages_Total:/   { hp_total = $2 }
/^HugePages_Free:/    { hp_free = $2 }
/^HugePages_Rsvd:/    { hp_rsvd = $2 }
/^HugePages_Surp:/    { hp_surp = $2 }
/^Hugetlb:/           { hugetlb = $2 }
/^Hugepagesize:/      { hp_size = $2 }

# ===== IO row =====
/^Dirty:/             { dirty = $2 }
/^Writeback:/         { writeback = $2 }
/^WritebackTmp:/      { wb_tmp = $2 }
/^NFS_Unstable:/      { nfs_unstable = $2 }

# ===== VM row =====
/^Committed_AS:/      { committed = $2 }
/^CommitLimit:/       { commit_lim = $2 }
/^KReclaimable:/      { kreclaimable = $2 }
/^Zswap:/             { zswap = $2 }
/^Zswapped:/          { zswapped = $2 }
/^VmallocTotal:/      { vmalloc_total = $2 }
/^VmallocChunk:/      { vmalloc_chunk = $2 }

# ===== HW row =====
/^Bounce:/            { bounce = $2 }
/^SecPageTables:/     { sec_pagetbl = $2 }
/^HardwareCorrupted:/ { hw_corrupted = $2 }
/^CmaTotal:/          { cma_total = $2 }
/^CmaFree:/           { cma_free = $2 }
/^DirectMap4k:/       { dmap_4k = $2 }
/^DirectMap2M:/       { dmap_2m = $2 }
/^DirectMap1G:/       { dmap_1g = $2 }

END {
    # Fix buff_cache formula to include SReclaimable (matches standard free command)
    buff_cache = buffers + (cached + 0) + (slab_recl + 0)
    used = total - free - buff_cache
    swap_used = swap_total - swap_free
    if (shared + 0 == 0) shared = 0

    init_colors(NO_COLOR)

    if (format == "csv") {
        if (header == 1) print_flat_header_csv()
        print_flat_row_csv(total, used, free, shared, buff_cache, available,
                          swap_total, swap_used, swap_free, 0, 0, 0)
    } else if (format == "tsv") {
        if (header == 1) print_flat_header_tsv()
        print_flat_row_tsv(total, used, free, shared, buff_cache, available,
                          swap_total, swap_used, swap_free, 0, 0, 0)
    } else {
        # === Summary ===
        print_header()
        print_mem_row("Mem:", total, used, free, shared, buff_cache, available, human)
        print_swap_row("Swap:", swap_total, swap_used, swap_free, human)
        print_swapcached(swap_cached + 0, human)

        # === Detail (always shown) ===
        used_anon    = anon + 0
        used_slab_un = slab_un + 0
        used_mlocked = unevict + 0
        used_other   = used - used_anon - used_slab_un - used_mlocked
        cache_unmapped = (cached + 0) - (mapped + 0)

        print_used_row(used_anon, used_slab_un, used_mlocked, used_other, human)
        print_cache_row(buffers + 0, slab_recl + 0, mapped + 0, cache_unmapped, human)

        # === Expert (-e only) ===
        if (expert == 1) {
            # kernel row
            kern_pagetable = pagetable + 0
            kern_kstack = kstack + 0
            kern_vmalloc = vmalloc + 0
            kern_percpu = percpu + 0
            kern_other = used_other - kern_pagetable - kern_kstack - kern_vmalloc - kern_percpu
            if (kern_other < 0) kern_other = 0
            print_kernel_row(slab_total + 0, kern_pagetable, kern_kstack, kern_vmalloc, kern_percpu, kern_other, human)

            # lru row
            lru_act_anon = act_anon + 0
            lru_inact_anon = inact_anon + 0
            lru_act_file = act_file + 0
            lru_inact_file = inact_file + 0
            lru_total = lru_act_anon + lru_inact_anon + lru_act_file + lru_inact_file
            print_lru_row(lru_act_anon, lru_inact_anon, lru_act_file, lru_inact_file, lru_total, human)

            # thp row
            print_thp_row(thp_anon + 0, shmem_huge + 0, shmem_pmd + 0, file_huge + 0, file_pmd + 0,
                hp_total + 0, hp_free + 0, hp_rsvd + 0, hp_surp + 0, hugetlb + 0, hp_size + 0, human)

            # io row
            print_io_row(dirty + 0, writeback + 0, wb_tmp + 0, nfs_unstable + 0, human)

            # vm row
            print_vm_row(committed + 0, commit_lim + 0, kreclaimable + 0, zswap + 0, zswapped + 0,
                vmalloc_total + 0, vmalloc_chunk + 0, human)

            # hw row
            print_hw_row(bounce + 0, sec_pagetbl + 0, hw_corrupted + 0, cma_total + 0, cma_free + 0,
                dmap_4k + 0, dmap_2m + 0, dmap_1g + 0, human)
        }
    }
}
