
END {
    if (PANIC_EXIT != 0) exit( PANIC_EXIT )
    result = table[ jqu(PKG_NAME), jqu("hook"), jqu(SCRIPT) ]
    if (result != "") {
        print PKG_RAWPATH "/" PKG_NAME "/.x-cmd/" juq(result)
        exit(0)
    }
}
