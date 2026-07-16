BEGIN { first = 1 }
{
    if (first) { first = 0; next }
    name = $1
    if (name == "") next

    print "  - name: " name
    print "    expr: " $2
    if ($3 != "") print "    desc: " $3
    if ($4 != "") print "    once: " $4

    last_start = $5
    if (last_start != "" && last_start > 0) {
        last_start_iso = date_timestamp_to_iso(last_start)
        if (last_start_iso != "") {
            print "    last_start: " last_start_iso

            last_end = $6
            if (last_end != "" && last_end > 0) {
                last_end_iso = date_timestamp_to_iso(last_end)
                if (last_end_iso != "") print "    last_end: " last_end_iso
            }

            if ($7 != "") print "    last_status: " $7
            if ($8 != "") print "    last_exit_code: " $8
        }
    }
}
