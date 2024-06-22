
BEGIN{
    L = "\003"
}

BEGIN{
    cmd = "ps -eo tty,pid,ppid,%mem,%cpu,command"
    l = 0
    while (cmd | getline) {
        if ((l ++) == 1) continue
        tty = $1

        ps[ tty L ] = data_l = ps[ tty L ] + 1
        ps[ tty, data_l, "pid"  ] = $2
        ps[ tty, data_l, "ppid"  ] = $3
        ps[ tty, data_l, "mem"  ] = $4
        ps[ tty, data_l, "cpu"  ] = $5

        $1 = $2 = $3 = $4 = $5 = ""
        command = $0
        gsub(/(^[ ]+)|([ ]+$)/, "", command)
        ps[ tty, data_l, "cmd"  ] = command
    }
}

{
    if ( (regex != "") && (! match($0, regex)))     next
    # $0 = substr($0, 1, RSTART-1)
    user = $1
    tty  = $2
    $1 = ""
    $2 = ""
    printf("%s\t%s\t%s :\n", user, tty, $0)

    if (tty == "console")  tty = "ttys001"
    data_l = ps[ tty L ]
    for (i=1; i<=data_l; ++i) {
        printf("  - %s\t%s\n", ps[ tty, i, "pid" ], ps[ tty, i, "cmd" ])
    }

    close(cmd)
}
