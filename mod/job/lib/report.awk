BEGIN{
    if (LOG_LEVEL == "") LOG_LEVEL = 2
}
$1=="start:"{
    $1=""
    if (LOG_LEVEL <= 1) {
        log_debug("job", "Start: " $0)
    }
    next
}

$1=="exit:"{
    code=$2;            $1=$2=""
    if (code == 0) {
        if (LOG_LEVEL <= 2) log_info("job", "Success: " $0)
        success ++
    } else {
        if (LOG_LEVEL <= 3) log_warn("job", sprintf("Fail: [code=%s] %s", code, $0))
        failure ++
    }
    next
}

{
    print $0
}

END{
    if (failure > 0) {
        total = success + failure
        if (LOG_LEVEL <= 3) log_warn( "job", sprintf( "Total: %s  Pass: %s   Fail: %s", total, success, failure ) )
        exit( 1 )
    } else {
        if (LOG_LEVEL <= 2) log_info( "job", sprintf( "Total: %s  All Passed!", total ) )
        exit( 0 )
    }

}
