function put(k, v){
    m[ k ] = v
    m[ ++ml ] = k
}

BEGIN{
    put("Pages free",               "the total number of free pages in the system.")
    put("Pages active",             "the total number of pages currently in use and pageable.")
    put("Pages inactive",           "the total number of pages on the inactive list.")
    put("Pages speculative",        "the total number of pages on the speculative list.")
    put("Pages throttled",          "the total number of pages on the throttled list (not wired but notpageable).")
    put("Pages wired down",         "the total number of pages wired down.  That is, pages that cannotbe paged out.")
    put("Pages purgeable",          "the total number of purgeable pages.")
    put("Translation faults",       "the number of times the vm_fault routine has been called.")
    put("Pages copy-on-write",      "the number of faults that caused a page to be copied (generallycaused by copy-on-write faults).")
    put("Pages zero filled",        "the total number of pages that have been zero-filled on demand.")
    put("Pages reactivated",        "the total number of pages that have been moved from the inactivelist to the active list (reactivated).")
    put("Pages purged",             "the total number of pages that have been purged.")
    put("File-backed pages",        "the total number of pages that are file-backed (non-swap)")
    put("Anonymous pages",          "the total number of pages that are anonymous")
    put("Uncompressed pages",       "the total number of pages (uncompressed) held within the compressorPages used by VM compressor:the number of pages used to store compressed VM pages.")
    put("Pages decompressed",       "the total number of pages that have been decompressed by the VMcompressor.")
    put("Pages compressed",         "the total number of pages that have been compressed by the VMcompressor.")
    put("Pageins",                  "the total number of requests for pages from a pager (such as theinode pager).")
    put("Pageouts",                 "the total number of pages that have been paged out.")
    put("Swapins",                  "the total number of compressed pages that have been swapped out todisk.")
}

NR==1{
    c = NF - 1
    page_size = $c
    print $c
    FS = ":"
}

NR>1{
    token = $1
    if (token ~ /^"/)  token = substr(token, 2, length(token)-2 )

    value = $2
    gsub("^[ ]+", "", value)
    gsub("[ .]+$", "", value)

    value2 = (value * page_size)/1024/1024

    value2 = sprintf("%10.3f", value2)
    printf("%-30s: %10s (\033[1m%15s MB\033[0m)\n", token, value, value2)

    # if (value2 > 1024) {
    #     # value2 = value2 / 1024
    #     value2 = sprintf("%10.3f", value2)
    #     # value2 = int(value2 * 1000) / 1000
    #     printf("%-30s: %10s (\033[31;1m%15s MB\033[0m)\n", token, value, value2)
    # } else {
    #     value2 = sprintf("%10.3f", value2)
    #     # value2 = int(value2 * 1000) / 1000
    #     printf("%-30s: %10s (\033[0m%15s MB\033[0m)\n", token, value, value2)
    # }

}


