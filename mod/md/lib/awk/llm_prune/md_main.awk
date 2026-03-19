{
    if (match($0, "^XCMD_MD_LLM_EXITCODE:")){
        HD_EXITCODE = int(substr($0, RLENGTH + 1))
        next
    }
    arr[ ++ ARR_L ] = $0
}

END{
    hd_main( arr )
    exit(HD_EXITCODE)
}
